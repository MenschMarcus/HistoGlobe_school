window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   --------------------------------------------------------------------------
  constructor: (config) ->
    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onNowChanged"
    @addCallback "onIntervalChanged"
    @addCallback "onZoom"

    defaultConfig =
      parentDiv: undefined
      timelineZoom: 1
      minYear: 1850
      maxYear: 2000
      nowYear: 1925
      speedometer: true
      epochs: []

    @_config = $.extend {}, defaultConfig, config

    #   ------------------------------------------------------------------------
    @_uiElements =
      tl:           @addUIElement "tl", "swiper-container", @_config.parentDiv
      tl_wrapper:   @addUIElement "tl_wrapper", "swiper-wrapper", tl
      tl_slide:     @addUIElement "tl_slide", "swiper-slide", tl_wrapper
      #nowMarker:    @addUIElement "now_marker", "now_marker", document.getElementById("histoglobe")
      timeBars:     []
      dateMarkers:  new HG.DoublyLinkedList()
      #epochs:  new Array()

    #   ------------------------------------------------------------------------
    @_now =
      date: @yearToDate(@_config.nowYear)
      marker: new HG.NowMarker(@, @_uiElements.nowMarker, @_config.speedometer)

    #   TRANSITION / SWIPER ----------------------------------------------------
    @_moveDelay = 0
    @_timeline_swiper ?= new Swiper '#tl',
      mode:'horizontal'
      freeMode: true
      momentumRatio: 0.5
      scrollContainer: true
      onTouchStart: =>
        @_animationTargetDate = null
        if @_play
          @_now.marker.animationSwitch()
      onTouchMove: =>
        fireCallbacks = false
        if ++@_moveDelay == 10
          @_moveDelay = 0
          fireCallbacks = true
        @_updateNowDate(fireCallbacks)
        @_updateDateMarkers(false)
    @_uiElements.tl_wrapper.addEventListener "webkitTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers(false)
    , false
    @_uiElements.tl_wrapper.addEventListener "transitionend", (e) =>
      @_updateNowDate()
      @_updateDateMarkers(false)
    , false
    @_uiElements.tl_wrapper.addEventListener "oTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers(false)
    , false

    #   TIMELINE ANIMATION  ----------------------------------------------------
    @_play = false
    @_speed = 1
    @_stopDate = @yearToDate(@_config.maxYear)
    @_nextHiventhandle = null
    setInterval @_animTimeline, 30

    #   ZOOM  ------------------------------------------------------------------
    @_uiElements.tl.addEventListener "mousewheel", (e) =>
      e.preventDefault()
      @_zoom(e.wheelDelta, e)
    @_uiElements.tl.addEventListener "DOMMouseScroll", (e) =>
      e.preventDefault()
      @_zoom(-e.detail, e)

    #   ------------------------------------------------------------------------
    $(window).resize  =>
      @_updateLayout()
      @_updateDateMarkers()
      @_updateNowDate()

    #   Start !!! ---------------------------------------------------------------
    @_updateLayout()
    @_updateDateMarkers()
    @_updateNowDate()

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.onAllModulesLoaded @, () =>
      @_hgInstance = hgInstance
      @_hiventController = @_hgInstance.hiventController
      @notifyAll "onNowChanged", @_now.date
      @notifyAll "onIntervalChanged", @_getTimeFilter()
      
      #@_HiventList = @_hgInstance
      #console.log @_HiventList

      if hgInstance.zoom_buttons_timeline
        hgInstance.zoom_buttons_timeline.onZoomIn @, () =>
          @_zoom(1)
        hgInstance.zoom_buttons_timeline.onZoomOut @, () =>
          @_zoom(-1)

  #   --------------------------------------------------------------------------
  getMinYear: =>
    @_config.minYear

  #   --------------------------------------------------------------------------
  getMaxYear: =>
    @_config.maxYear

  #   --------------------------------------------------------------------------
  addUIElement: (id, className, parentDiv, type="div") ->
    container = document.createElement(type)
    container.id = id
    container.className = className if className?
    parentDiv.appendChild container if parentDiv?
    container

  #   --------------------------------------------------------------------------
  millisPerPixel: ->
    mpp = (@yearToMillis(@_config.maxYear - @_config.minYear) / window.innerWidth) / @_config.timelineZoom
  minVisibleDate: ->
    d = new Date(@_now.date.getTime() - (@millisPerPixel() * window.innerWidth / 2))
  maxVisibleDate: ->
    d = new Date(@_now.date.getTime() + (@millisPerPixel() * window.innerWidth / 2))
  timelineLength: ->
    @yearToMillis(@_config.maxYear - @_config.minYear) / @millisPerPixel()
  timeInterval: (i) ->
    x = Math.floor(i/3)
    if i % 3 == 0
      return @yearToMillis(Math.pow(10, x))
    if i % 3 == 1
      return @yearToMillis(2 * Math.pow(10, x))
    if i % 3 == 2
      return @yearToMillis(5 * Math.pow(10, x))

    # OLD DISTANZ BETWEEN THE YEARS 5 AND 10 POTENCE
    #  if i % 2 != 0
      # HACK!
      # return @yearToMillis(5 * Math.pow(5, Math.floor(i / 2)))
      # return @yearToMillis(5 * Math.pow(10, Math.floor(i / 2)))
    #  else
      # HACK!
      # return @yearToMillis(Math.pow(5, Math.floor(i / 2)))
      # return @yearToMillis(Math.pow(10, Math.floor(i / 2)))
  dateToPosition: (date) ->
    dateDiff = date.getTime() - @yearToDate(@_config.minYear).getTime()
    pos = (dateDiff / @millisPerPixel()) + window.innerWidth/2

  #   --------------------------------------------------------------------------
  yearToDate: (year) ->
    date = new Date(0)
    date.setFullYear year
    date.setMonth 0
    date.setDate 1
    date.setHours 0
    date.setMinutes 0
    date.setSeconds 0
    date
  yearToMillis: (year) ->
    millis = year * 365.25 * 24 * 60 * 60 * 1000
  millisToYear: (millis) ->
    year = millis / 1000 / 60 / 60 / 24 / 365.25
  daysToMillis: (days) ->
    millis = days * 24 * 60 * 60 * 1000
  millisToDays: (millis) ->
    days = millis / 1000 / 60 / 60 / 24
  stringToDate: (string) ->
    res = (string + "").split(".")
    i = res.length
    d = new Date(1900, 0, 1)
    if i > 0
        d.setFullYear(res[i - 1])
    else
        alert "Error: were not able to convert string to date."
    if i > 1
        d.setMonth(res[i - 2] - 1)
    if i > 2
        d.setDate(res[i - 3])
    d

  #   --------------------------------------------------------------------------
  updateTimeBars: (activeTimeBars) ->
    for oldTimeBar in @_uiElements.timeBars
      oldTimeBar.div.style.display = "none"
      @getCanvas().removeChild oldTimeBar.div
    @_uiElements.timeBars = []
    for timeBarValues in activeTimeBars
      @_drawTimeBar timeBarValues

  #   --------------------------------------------------------------------------
  moveToDate: (date, delay=0, successCallback=undefined) ->
    if @yearToDate(@_config.minYear).getTime() > date.getTime()
      @moveToDate @yearToDate(@_config.minYear), delay, successCallback
    else if @yearToDate(@_config.maxYear).getTime() < date.getTime()
      @moveToDate @yearToDate(@_config.maxYear), delay, successCallback
    else
      dateDiff = @yearToDate(@_config.minYear).getTime() - date.getTime()
      @_uiElements.tl_wrapper.style.transition =  delay + "s"
      @_uiElements.tl_wrapper.style.transform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.webkitTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.MozTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.MsTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.oTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"

      @_animationTargetDate = date
      @_now.date = date
      @_now.marker.nowDateChanged()

      @notifyAll "onNowChanged", @_now.date
      @notifyAll "onIntervalChanged", @_getTimeFilter()
      successCallback?()

  #   --------------------------------------------------------------------------
  getLayout: ->
    @_uiElements
  getNowDate: ->
    @_now.date
  getNowMarker: ->
    @_now.marker
  getParentDiv: ->
    @_config.parentDiv
  getCanvas: ->
    @_uiElements.tl_slide
  stopTimeline: ->
    @_play = false
  playTimeline: ->
    @_play = true
  setSpeed: (speed) ->
    @_speed = speed
  getPlayStatus: ->
    @_play

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  #   --------------------------------------------------------------------------
  _updateLayout: ->
    @_uiElements.tl.style.width       = window.innerWidth + "px"
    @_uiElements.tl_slide.style.width = (@timelineLength() + window.innerWidth) + "px"
    @moveToDate(@_now.date, 0)
    @_timeline_swiper.reInit()

  #   --------------------------------------------------------------------------
  _updateNowDate: (fireCallbacks = true) ->
    if @_animationTargetDate?
      @_now.date = @_animationTargetDate
      @_animationTargetDate = null

    else
      @_now.date = new Date(@yearToDate(@_config.minYear).getTime() + (-1) * @_timeline_swiper.getWrapperTranslate("x") * @millisPerPixel())
    @_now.marker.nowDateChanged()

    if fireCallbacks
      @notifyAll "onNowChanged", @_now.date
      @notifyAll "onIntervalChanged", @_getTimeFilter()

  #   --------------------------------------------------------------------------
  _drawTimeBar: (timeBarValues) ->

    startDate = @stringToDate(timeBarValues[0])
    endDate   = @stringToDate(timeBarValues[1])

    tb_div = @addUIElement "tl_timebar_" + timeBarValues[2], "tl_timebar", @getCanvas()
    tb_div.style.left = @dateToPosition(startDate) + "px"
    tb_div.style.width = (@dateToPosition(endDate) - @dateToPosition(startDate)) + "px"

    timeBar =
      div: tb_div
      startDate: startDate
      endDate: endDate
    @_uiElements.timeBars.push timeBar

    @moveToDate startDate, 0.5
    if timeBar.endDate > @maxVisibleDate()
      while timeBar.endDate > @maxVisibleDate()
        if !@_zoom -1
            break
    else
      while timeBar.endDate < maxDate or !maxDate?
        if !@_zoom 1
          break
        else
          maxDate = new Date(@maxVisibleDate().getTime() - ((@maxVisibleDate().getTime() - timeBar.startDate.getTime()) * 0.2))

  _updateTimeBarPositions: ->
    for timeBar in @_uiElements.timeBars
      timeBar.div.style.left = @dateToPosition(timeBar.startDate) + "px"
      timeBar.div.style.width = (@dateToPosition(timeBar.endDate) - @dateToPosition(timeBar.startDate)) + "px"

  #   --------------------------------------------------------------------------
  _updateEpochs:()->
    for epoch in @_config.epochs
      #console.log @_hgInstance
      if !epoch.div?
        #Epoche wurde noch nicht dargestellt, wird hier erzeugt
        epoch.div = document.createElement("div")
        epoch.div.id = "epoch" + epoch.id
        epoch.div.className = "tl_epoch"
        epoch.div.innerHTML = epoch.name
        epoch.div.style.left = @dateToPosition(epoch.startDate) + "px"
        epoch.div.style.width = (@dateToPosition(epoch.endDate) - @dateToPosition(epoch.startDate)) + "px"
        epoch.div.style.display = "none"
        @getCanvas().appendChild epoch.div        
        $(epoch.div).on "click", value: epoch, (event) =>
          epoch_tmp = event.data.value
          diff = epoch_tmp.endDate.getTime() - epoch_tmp.startDate.getTime()
          millisec = diff / 2 + epoch_tmp.startDate.getTime()
          middleDate = new Date(millisec)
          @moveToDate middleDate, 0.5
          window.location.hash = '#categories=' + epoch_tmp.id

        $(epoch.div).fadeIn(200)
      else
        #@_hgInstance.hivent_list_module._addHiventList
        #Epoche bereits erstellt, Position wird nur aktualisiert
        epoch.div.style.left = @dateToPosition(epoch.startDate) + "px"
        epoch.div.style.width = (@dateToPosition(epoch.endDate) - @dateToPosition(epoch.startDate)) + "px"
        #Epoche highlighted
        if @dateToPosition(epoch.startDate) < @dateToPosition(@_now.date) and @dateToPosition(@_now.date) < @dateToPosition(epoch.endDate)
          epoch.div.className = "tl_epoch_highlighted"
        else
          epoch.div.className = "tl_epoch"

  _updateDateMarkers: (zoomed=true) ->
    @_updateEpochs()
    #   count possible years to show
    count = @_config.maxYear - @_config.minYear

    #   if list of datemarkers is not available
    #   fill it with nulls
    if @_uiElements.dateMarkers.getLength() == 0
      for i in [0..count]
        @_uiElements.dateMarkers.addLast(null)

    #   calculate interval between years to show
    index = 0
    while @timeInterval(index) <= window.innerWidth * @millisPerPixel()
      index++
    intervalIndex = (index - 3)
    intervalIndex = 0 if intervalIndex < 0

    dateMarkerMaxWidth = window.innerWidth / (@millisToYear(window.innerWidth * @millisPerPixel()) / @millisToYear(@timeInterval(intervalIndex)))

    maxDate = @maxVisibleDate()
    minDate = @minVisibleDate()

    #   walk through list an create, or hide datemarkers
    for i in [0..count]
      if (@_config.minYear + i) % @millisToYear(@timeInterval(intervalIndex)) == 0 && (@_config.minYear + i) >= minDate.getFullYear() && (@_config.minYear + i) <= maxDate.getFullYear()
        if @_uiElements.dateMarkers.get(i).nodeData?
          @_uiElements.dateMarkers.get(i).nodeData.updateView(true)
          element = @_uiElements.dateMarkers.get(i).nodeData.getDiv()
          element.style.maxWidth = dateMarkerMaxWidth + "px"
          if Math.round(dateMarkerMaxWidth / 2.6) <= 100
            $(element).css({'font-size':(Math.round(dateMarkerMaxWidth / 2.6)) + 'px'})
          else
            $(element).css({'font-size':'100px'})
        else
          date = new Date(@_config.minYear + i, 0, 1, 0, 0, 0)
          @_uiElements.dateMarkers.get(i).nodeData = new HG.DateMarker(date, @)
          element = @_uiElements.dateMarkers.get(i).nodeData.getDiv()
          element.style.maxWidth = dateMarkerMaxWidth + "px"
          if Math.round(dateMarkerMaxWidth / 2.6) <= 100
            $(element).css({'font-size':(Math.round(dateMarkerMaxWidth / 2.6)) + 'px'})
          else
            $(element).css({'font-size':'100px'})
      else
        if @_uiElements.dateMarkers.get(i).nodeData?
          @_uiElements.dateMarkers.get(i).nodeData.updateView(false)
          @_uiElements.dateMarkers.get(i).nodeData = null

    @_updateTimeBarPositions()

  #   --------------------------------------------------------------------------
  _zoom: (delta, e=null) =>
    zoomed = false
    if delta > 0
      if @maxVisibleDate().getFullYear() - @minVisibleDate().getFullYear() > 2
        @_config.timelineZoom *= 1.1
        zoomed = true
    else
      if @_config.timelineZoom > 1
        @_config.timelineZoom /= 1.1
        zoomed = true

    if zoomed
      @_updateLayout()
      @_updateDateMarkers()
      @notifyAll "onZoom"
    zoomed

  #   --------------------------------------------------------------------------
  _animTimeline: =>
    if @_play
      if @_now.date.getFullYear() <= @_config.maxYear
        toDate = new Date(@_now.date.getTime() + @_speed*@_speed * 5000 * 60 * 60 * 24 * 7)
        @moveToDate(toDate,0)
        @_updateNowDate()
        @_updateDateMarkers(zoomed=false)
      else
        @_now.marker.animationSwitch()

  #   --------------------------------------------------------------------------
  _getTimeFilter: ->
    timefilter = []
    timefilter.end = @maxVisibleDate()
    timefilter.now = @_now.date
    timefilter.start = @minVisibleDate()
    timefilter

  #   --------------------------------------------------------------------------
  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true
