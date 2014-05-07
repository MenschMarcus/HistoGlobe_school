window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   ---------------------------------------------------------------------
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

    #   --------------------------------------------------------------------------
    @_uiElements = @_initLayout()
    @_timeBars = []

    #   --------------------------------------------------------------------------
    @_maxZoom = @maxZoomLevel()
    @_maxIntervalIndex = @_calcMaxIntervalIndex()

    #   --------------------------------------------------------------------------
    @_nowDate = @yearToDate(@_config.nowYear)

    #   --------------------------------------------------------------------------
    #   now marker is always in middle of page and depends on nowDate of timeline
    @_nowMarker = new HG.NowMarker(@)

    #   --------------------------------------------------------------------------
    @_moveDelay = 0

    #   --------------------------------------------------------------------------
    #   Swiper for timeline
    @_timeline_swiper ?= new Swiper '#tl',
      mode:'horizontal'
      freeMode: true
      momentumRatio: 0.5
      scrollContainer: true
      # onSlideClick: (s, d) =>
        # target = new Date(@yearToDate(@_config.minYear).getTime() - (@_timeline_swiper.getWrapperTranslate("x") - d.x + window.innerWidth/2) * @millisPerPixel())
        # @moveToDate(target, 0.5)

      onTouchStart: =>
        @_animationTargetDate = null
        if @_play
          @_nowMarker.animationSwitch()

      onTouchMove: =>
        fireCallbacks = false
        if ++@_moveDelay == 10
          @_moveDelay = 0
          fireCallbacks = true

        @_updateNowDate(fireCallbacks)
        @_updateDateMarkers()
      # onSetWrapperTransition: =>
      #   console.log "huhu"
      #   @_updateNowDate()

    #   --------------------------------------------------------------------------
    @_updateLayout()

    #   --------------------------------------------------------------------------
    @_dateMarkers   = new HG.DoublyLinkedList()
    @_updateDateMarkers()

    #   --------------------------------------------------------------------------
    #   MOVE TIMELINE
    @moveToDate(@_nowDate)

    #   catch end of transition
    @_uiElements.tl_wrapper.addEventListener "webkitTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers()
    , false

    @_uiElements.tl_wrapper.addEventListener "transitionend", (e) =>
      @_updateNowDate()
      @_updateDateMarkers()
    , false

    # @_uiElements.tl_wrapper.addEventListener "MSTransitionEnd", (e) =>
    #   console.log "huhu"
    #   @_updateNowDate()
    #   @_updateDateMarkers()
    # , false

    @_uiElements.tl_wrapper.addEventListener "oTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers()
    , false

    # set animation for timeline play
    @_play = false
    @_speed = 1
    @_stopDate = @yearToDate(@_config.maxYear)
    @_nextHiventhandle = null
    setInterval @_animTimeline, 30

    @_updateNowDate()

    #   --------------------------------------------------------------------------
    #   ZOOM TIMLINE
    @_uiElements.tl.addEventListener "mousewheel", (e) =>
      e.preventDefault()
      @_zoom(e.wheelDelta)

    @_uiElements.tl.addEventListener "DOMMouseScroll", (e) =>
      e.preventDefault()
      @_zoom(-e.detail)

    #   --------------------------------------------------------------------------
    $(window).resize  =>
      @_maxZoom = @maxZoomLevel()
      @_maxIntervalIndex = @_calcMaxIntervalIndex()
      @_uiElements.tl.style.width = window.innerWidth + "px"
      @_uiElements.tl_slide.style.width = (@timelineLength() + window.innerWidth) + "px"
      @_updateNowDate()
      @_updateDateMarkers()
      @moveToDate(@_nowDate, 0)

  # ============================================================================
  hgInit: (hgInstance) ->
    #@_hiventController = hgInstance.hiventController
    hgInstance.onAllModulesLoaded @, () =>
      @_hiventController = hgInstance.hiventController
      @notifyAll "onNowChanged", @_nowDate
      @notifyAll "onIntervalChanged", @_getTimeFilter()

      if hgInstance.zoom_buttons_timeline
        hgInstance.zoom_buttons_timeline.onZoomIn @, () =>
          @_zoom(1)
        hgInstance.zoom_buttons_timeline.onZoomOut @, () =>
          @_zoom(-1)

  #   --------------------------------------------------------------------------
  _initLayout: ->

    uiElements =
      body:         document.getElementsByTagName("body")[0]
      tl:        document.createElement("div")
      tl_wrapper: document.createElement("div")
      tl_slide:   document.createElement("div")
      #dayRow:       document.createElement("div")
      #monthRow:     document.createElement("div")
      #yearRow:      document.createElement("div")
      #symbolRow:    document.createElement("div")
      nowMarker:    document.createElement("div")

    uiElements.tl.id          = "tl"
    uiElements.tl_wrapper.id  = "tl_wrapper"
    uiElements.tl_slide.id     = "tl_slide"
    #uiElements.dayRow.id        = "dayRow"
    #uiElements.monthRow.id      = "monthRow"
    #uiElements.yearRow.id       = "yearRow"
    #uiElements.symbolRow.id     = "symbolRow"

    uiElements.tl.className        = "swiper-container"
    uiElements.tl_wrapper.className = "swiper-wrapper"
    uiElements.tl_slide.className   = "swiper-slide"

    # uiElements.dayRow.className    = "tl_row"
    # uiElements.monthRow.className  = "tl_row"
    # uiElements.yearRow.className   = "tl_row"
    # uiElements.symbolRow.className = "tl_row"

    uiElements.tl.style.width = window.innerWidth + "px"
    uiElements.tl_slide.style.width = (@timelineLength() + window.innerWidth) + "px"

    @_config.parentDiv.appendChild uiElements.tl
    uiElements.tl.appendChild uiElements.tl_wrapper
    uiElements.tl_wrapper.appendChild uiElements.tl_slide
    # uiElements.tl_slide.appendChild uiElements.dayRow
    # uiElements.tl_slide.appendChild uiElements.monthRow
    # uiElements.tl_slide.appendChild uiElements.yearRow
    # uiElements.tl_slide.appendChild uiElements.symbolRow
    uiElements.tl.appendChild uiElements.nowMarker

    uiElements

  #   --------------------------------------------------------------------------
  #   various functions to calculate time intervals and degrees for the timeline
  millisPerPixel: ->
    mpp = (@yearToMillis(@_config.maxYear - @_config.minYear) / window.innerWidth) / @_config.zoom

  minVisibleDate: ->
    d = new Date(@_nowDate.getTime() - (@millisPerPixel() * window.innerWidth / 2))

  maxVisibleDate: ->
    d = new Date(@_nowDate.getTime() + (@millisPerPixel() * window.innerWidth / 2))

  timelineLength: ->
    @yearToMillis(@_config.maxYear - @_config.minYear) / @millisPerPixel()

  maxZoomLevel: ->
    f = false
    zoom = 1
    while !f
      mpp = (@yearToMillis(@_config.maxYear - @_config.minYear) / window.innerWidth) / zoom
      if @millisToDays(window.innerWidth * mpp) > 31
        zoom++
      else
        f = true
        return zoom

  _calcMaxIntervalIndex: ->
    index = 0
    while @timeInterval(index) <= window.innerWidth * @millisPerPixel()
      index++
    (index - 1)

  _updateNowDate: (fireCallbacks = true) ->
    if @_animationTargetDate?
      @_nowDate = @_animationTargetDate
      @_animationTargetDate = null

    else
      @_nowDate = new Date(@yearToDate(@_config.minYear).getTime() + (-1) * @_timeline_swiper.getWrapperTranslate("x") * @millisPerPixel())
    @_nowMarker.nowDateChanged()

    if fireCallbacks
      @notifyAll "onNowChanged", @_nowDate
      @notifyAll "onIntervalChanged", @_getTimeFilter()

  #   --------------------------------------------------------------------------
  #   TIMEBARS ON TIMELINE
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
    @_timeBars.push timeBar

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
    for timeBar in @_timeBars
      timeBar.div.style.left = @dateToPosition(timeBar.startDate) + "px"
      timeBar.div.style.width = (@dateToPosition(timeBar.endDate) - @dateToPosition(timeBar.startDate)) + "px"

  updateTimeBars: (activeTimeBars) ->
    for oldTimeBar in @_timeBars
      oldTimeBar.div.style.display = "none"
      @getCanvas().removeChild oldTimeBar.div
    @_timeBars = []
    for timeBarValues in activeTimeBars
      @_drawTimeBar timeBarValues

  #   --------------------------------------------------------------------------
  #   for i e {0,1,2,3,...} it should return 1,5,10,50,100,...
  #   needed for highlightinh timescale dates
  timeInterval: (i) ->
    if i % 2 != 0
      return @yearToMillis(5 * Math.pow(10, Math.floor(i / 2)))
    else
      return @yearToMillis(Math.pow(10, Math.floor(i / 2)))

  #   --------------------------------------------------------------------------
  #   calcluate and set height and width of timeline
  #   needed on start and on timeline zoomed
  #   depends @_config.zoom
  #
  _updateLayout: ->
    tlHeight = HGConfig.timeline_height.val
    tlHeightType = HGConfig.timeline_height.unit

    zoom = @_config.zoom * 5

    hp = 0.5 * tlHeight

    # dayRowHeight = (zoom / @_maxZoom) * (1/3)
    # monthRowHeight = (zoom / @_maxZoom) * (2/3)
    # yearRowHeight = ((@_maxZoom - zoom) / @_maxZoom)

    @_uiElements.tl_slide.style.width = (@timelineLength() + window.innerWidth) + "px"
    @moveToDate(@_nowDate, 0)

    # @_uiElements.dayRow.style.height = (dayRowHeight * hp) + tlHeightType
    # @_uiElements.dayRow.style.fontSize = (dayRowHeight * hp) + tlHeightType

    # @_uiElements.monthRow.style.height = (monthRowHeight * hp) + tlHeightType
    # @_uiElements.monthRow.style.fontSize = (monthRowHeight * hp) + tlHeightType

    # @_uiElements.yearRow.style.height = (yearRowHeight * hp) + tlHeightType
    # @_uiElements.yearRow.style.fontSize = (yearRowHeight * hp) + tlHeightType

    # @_uiElements.symbolRow.style.height = (1 * tlHeight - HGConfig.border_width.val) + tlHeightType
    # @_uiElements.symbolRow.style.fontSize = (1 * tlHeight - HGConfig.border_width.val) + tlHeightType

    @_timeline_swiper.reInit()

  #   --------------------------------------------------------------------------
  _updateDateMarkers: ->
    #   count possible years to show
    count = @_config.maxYear - @_config.minYear

    #   if list of datemarkers is not available
    #   fill it with nulls
    if @_dateMarkers.getLength() == 0
      for i in [0..count]
        @_dateMarkers.addLast(null)

    #   calculate interval between years to show
    intervalIndex = @_maxIntervalIndex - 1
    intervalIndex = 0 if intervalIndex < 0

    maxDate = @maxVisibleDate()
    minDate = @minVisibleDate()

    #   walk through list an create, or hide datemarkers
    for i in [0..count]
      if (@_config.minYear + i) % @millisToYear(@timeInterval(intervalIndex)) == 0 && (@_config.minYear + i) >= minDate.getFullYear() && (@_config.minYear + i) <= maxDate.getFullYear()
        if @_dateMarkers.get(i).nodeData?
          @_dateMarkers.get(i).nodeData.updateView(true)
        else
          date = new Date(@_config.minYear + i, 0, 1, 0, 0, 0)
          @_dateMarkers.get(i).nodeData = new HG.DateMarker(date, @)
      else
        if @_dateMarkers.get(i).nodeData?
          @_dateMarkers.get(i).nodeData.updateView(false)
          @_dateMarkers.get(i).nodeData = null

    @_updateTimeBarPositions()

  #   --------------------------------------------------------------------------
  #   left border of timeline has date value @_config.minYear
  #   so position of marker on timeline is calculated by millisPerPixel and difference between
  #   the date of the marker and the minYear
  dateToPosition: (date) ->
    dateDiff = date.getTime() - @yearToDate(@_config.minYear).getTime()
    pos = (dateDiff / @millisPerPixel()) + window.innerWidth/2

  #   --------------------------------------------------------------------------
  getLayout: ->
    @_uiElements
  getNowDate: ->
    @_nowDate
  getNowMarker: ->
    @_nowMarker
  getMaxIntervalIndex: ->
    @_maxIntervalIndex
  getParentDiv: ->
    @_config.parentDiv
  getCanvas: ->
    @_uiElements.tl_slide

  #   --------------------------------------------------------------------------
  #   move timeline to specified date and set date as new nowdate
  # moveToDate: (date) ->
  #   if @yearToDate(@_config.minYear).getTime() < date.getTime() && @yearToDate(@_config.maxYear).getTime() > date.getTime()
  #     dateDiff = @yearToDate(@_config.minYear).getTime() - date.getTime()
  #     @_timeline_swiper.setWrapperTranslate(dateDiff / @millisPerPixel(),0,0)

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
      @_nowDate = date
      @_nowMarker.nowDateChanged()

      @notifyAll "onNowChanged", @_nowDate
      @notifyAll "onIntervalChanged", @_getTimeFilter()
      successCallback?()

  #   --------------------------------------------------------------------------
  _zoom: (delta) =>
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
      @_maxIntervalIndex = @_calcMaxIntervalIndex()
      @_updateLayout()
      @_updateDateMarkers()
    zoomed

  #   --------------------------------------------------------------------------
  _animTimeline: =>

    # move timeline periodicly
    if @_play
      if @_nowDate.getFullYear() <= @_config.maxYear
        toDate = new Date(@_nowDate.getTime() + @_speed*@_speed * 5000 * 60 * 60 * 24 * 7)
        '''endDate = @_stopDate

        if (toDate >= endDate)
          toDate = endDate
          @_nowMarker.animationSwitch()'''

        @moveToDate(toDate,0)
        @_updateNowDate()
        @_updateDateMarkers()
      else
        @_nowMarker.animationSwitch()

  stopTimeline: ->
    @_play = false

  playTimeline: ->
    @_play = true
    '''@_nextHiventhandle = @_hiventController.getNextHiventHandle(@_nowDate)
    if @_nextHiventhandle
      @_stopDate = @_nextHiventhandle.getHivent().startDate'''

  setSpeed: (speed) ->
    @_speed = speed

  getPlayStatus: ->
    @_play

  #   --------------------------------------------------------------------------
  #   functions to convert data to various types (f.e. year to milliseconds)
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
  _getTimeFilter: ->
    timefilter = []
    timefilter.end = @maxVisibleDate()
    timefilter.now = @_nowDate
    timefilter.start = @minVisibleDate()
    timefilter

  _disableTextSelection : (e) ->  return false

  _enableTextSelection : () ->    return true
