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

    defaultConfig =
      parentDiv: undefined
      zoom: 1
      nowYear: 1900
      minYear: 1800
      maxYear: 2020

    @_config = $.extend {}, defaultConfig, config

    #   ------------------------------------------------------------------------
    @_uiElements        = {}
    @_initLayout()

    #   ------------------------------------------------------------------------
    @_now =
      date: @yearToDate(@_config.nowYear)
      marker: new HG.NowMarker(@)

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
        @_updateDateMarkers()
    @_uiElements.tl_wrapper.addEventListener "webkitTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers()
    , false
    @_uiElements.tl_wrapper.addEventListener "transitionend", (e) =>
      @_updateNowDate()
      @_updateDateMarkers()
    , false
    @_uiElements.tl_wrapper.addEventListener "oTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers()
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

    #   ------------------------------------------------------------------------
    @_updateLayout()
    @_updateDateMarkers()
    @_updateNowDate()

  # ============================================================================
  hgInit: (hgInstance) ->
    #@_hiventController = hgInstance.hiventController
    hgInstance.onAllModulesLoaded @, () =>
      @_hiventController = hgInstance.hiventController
      @notifyAll "onNowChanged", @_now.date
      @notifyAll "onIntervalChanged", @_getTimeFilter()

      if hgInstance.zoom_buttons_timeline
        hgInstance.zoom_buttons_timeline.onZoomIn @, () =>
          @_zoom(1)
        hgInstance.zoom_buttons_timeline.onZoomOut @, () =>
          @_zoom(-1)

  #   --------------------------------------------------------------------------
  millisPerPixel: ->
    mpp = (@yearToMillis(@_config.maxYear - @_config.minYear) / window.innerWidth) / @_config.zoom
  minVisibleDate: ->
    d = new Date(@_now.date.getTime() - (@millisPerPixel() * window.innerWidth / 2))
  maxVisibleDate: ->
    d = new Date(@_now.date.getTime() + (@millisPerPixel() * window.innerWidth / 2))
  timelineLength: ->
    @yearToMillis(@_config.maxYear - @_config.minYear) / @millisPerPixel()
  timeInterval: (i) ->
    if i % 2 != 0
      return @yearToMillis(5 * Math.pow(10, Math.floor(i / 2)))
    else
      return @yearToMillis(Math.pow(10, Math.floor(i / 2)))
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
    d = new Date(1, 0, 1900)
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
  _initLayout: ->

    @_uiElements =
      body:         document.getElementsByTagName("body")[0]
      tl:           document.createElement("div")
      tl_wrapper:   document.createElement("div")
      tl_slide:     document.createElement("div")
      nowMarker:    document.createElement("div")
      timeBars:     []
      dateMarkers:  new HG.DoublyLinkedList()

    @_uiElements.tl.id            = "tl"
    @_uiElements.tl_wrapper.id    = "tl_wrapper"
    @_uiElements.tl_slide.id      = "tl_slide"

    @_uiElements.tl.className         = "swiper-container"
    @_uiElements.tl_wrapper.className = "swiper-wrapper"
    @_uiElements.tl_slide.className   = "swiper-slide"

    @_uiElements.tl.style.width = window.innerWidth + "px"
    @_uiElements.tl_slide.style.width = (@timelineLength() + window.innerWidth) + "px"

    @_config.parentDiv.appendChild @_uiElements.tl
    @_uiElements.tl.appendChild @_uiElements.tl_wrapper
    @_uiElements.tl_wrapper.appendChild @_uiElements.tl_slide
    @_uiElements.tl.appendChild @_uiElements.nowMarker

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

    tb_div = document.createElement("div")
    tb_div.id = "tl_timebar_" + timeBarValues[2]
    tb_div.className = "tl_timebar"
    tb_div.style.left = @dateToPosition(startDate) + "px"
    tb_div.style.width = (@dateToPosition(endDate) - @dateToPosition(startDate)) + "px"
    @getCanvas().appendChild tb_div

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
  _updateDateMarkers: ->
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
    intervalIndex = (index - 2)
    intervalIndex = 0 if intervalIndex < 0

    maxDate = @maxVisibleDate()
    minDate = @minVisibleDate()

    #   walk through list an create, or hide datemarkers
    for i in [0..count]
      if (@_config.minYear + i) % @millisToYear(@timeInterval(intervalIndex)) == 0 && (@_config.minYear + i) >= minDate.getFullYear() && (@_config.minYear + i) <= maxDate.getFullYear() && !@dateMarkerOverlapps(i)
        if @_uiElements.dateMarkers.get(i).nodeData?
          @_uiElements.dateMarkers.get(i).nodeData.updateView(true)
        else
          date = new Date(@_config.minYear + i, 0, 1, 0, 0, 0)
          @_uiElements.dateMarkers.get(i).nodeData = new HG.DateMarker(date, @)
      else
        if @_uiElements.dateMarkers.get(i).nodeData?
          @_uiElements.dateMarkers.get(i).nodeData.updateView(false)
          @_uiElements.dateMarkers.get(i).nodeData = null

    @_updateTimeBarPositions()

  dateMarkerOverlapps: (index) ->
    overlapps = false
    '''count = @_uiElements.dateMarkers.getLength()
    for i in [0...count]
      if @_uiElements.dateMarkers.get(i).nodeData?
        if @_uiElements.dateMarkers.get(index).nodeData.getDiv()@_uiElements.dateMarkers.get(i).nodeData.getDiv().offsetLeft
        console.log "left: " + @_uiElements.dateMarkers.get(i).nodeData.getDiv().style.left'''
    overlapps

  #   --------------------------------------------------------------------------
  _zoom: (delta, e=null) =>
    zoomed = false
    if delta > 0
      if @maxVisibleDate().getFullYear() - @minVisibleDate().getFullYear() > 2
        @_config.zoom *= 1.2
        zoomed = true
    else
      if @_config.zoom > 1
        @_config.zoom /= 1.2
        zoomed = true

    if zoomed
      @_updateLayout()
      @_updateDateMarkers()
    zoomed

  #   --------------------------------------------------------------------------
  _animTimeline: =>
    if @_play
      if @_now.date.getFullYear() <= @_config.maxYear
        toDate = new Date(@_now.date.getTime() + @_speed*@_speed * 5000 * 60 * 60 * 24 * 7)
        @moveToDate(toDate,0)
        @_updateNowDate()
        @_updateDateMarkers()
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
