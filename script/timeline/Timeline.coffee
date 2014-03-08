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
    @_uiElements = @_createUIElements()

    #   --------------------------------------------------------------------------
    @_maxZoom = @maxZoomLevel()
    @_maxIntervalIndex = @_calcMaxIntervalIndex()

    #   --------------------------------------------------------------------------
    @_nowDate = @yearToDate(@_config.nowYear)

    #   --------------------------------------------------------------------------
    #   now marker is always in middle of page and depends on nowDate of timeline
    @_nowMarker = new HG.NowMarker(@)

    #   --------------------------------------------------------------------------
    #   Swiper for timeline
    @_timeline_swiper ?= new Swiper '#timeline',
      mode:'horizontal'
      freeMode: true
      momentumRatio: 0.5
      scrollContainer: true
      onTouchStart: =>
        @_animationTargetDate = null
        if @_play
          @_nowMarker.animationSwitch()


      onSetWrapperTransition: =>
        @_updateNowDate()

    #   --------------------------------------------------------------------------
    @_makeLayout()

    #   --------------------------------------------------------------------------
    @_dateMarkers   = new HG.DoublyLinkedList()
    @_updateDateMarkers()

    #   --------------------------------------------------------------------------
    #   MOVE TIMELINE
    @moveToDate(@_nowDate)

    #   catch end of transition
    @_uiElements.tlDivWrapper.addEventListener "webkitTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers()
    , false

    @_clicked = false
    @_uiElements.tlDiv.onmousedown = (e) =>
      @_clicked = true

    @_uiElements.body.onmousemove = (e) =>
      if @_clicked
        @_updateNowDate()
        @_updateDateMarkers()

    @_uiElements.body.onmouseup = (e) =>
      @_clicked = false if @_clicked

    # set animation for timeline play
    @_play = false
    @_speed = 1
    setInterval @_animTimeline, 16

    @_updateNowDate()

    #   --------------------------------------------------------------------------
    #   ZOOM TIMLINE
    @_uiElements.tlDiv.onmousewheel = (e) =>
      e.preventDefault()
      zoomed = false
      if e.wheelDeltaY > 0
        if @maxVisibleDate().getFullYear() - @minVisibleDate().getFullYear() > 2
          @_config.zoom *= 1.2
          zoomed = true
      else
        if @_config.zoom > 1
          @_config.zoom /= 1.2
          zoomed = true

      if zoomed
        @_maxIntervalIndex = @_calcMaxIntervalIndex()
        @_makeLayout()
        @_updateDateMarkers()

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.onAllModulesLoaded @, () =>
      @notifyAll "onNowChanged", @_nowDate
      @notifyAll "onIntervalChanged", @_getTimeFilter()

  #   --------------------------------------------------------------------------
  _createUIElements: ->

    uiElements =
      body:         document.getElementsByTagName("body")[0]
      tlDiv:        document.createElement("div")
      tlDivWrapper: document.createElement("div")
      tlDivSlide:   document.createElement("div")
      dayRow:       document.createElement("div")
      monthRow:     document.createElement("div")
      yearRow:      document.createElement("div")
      symbolRow:    document.createElement("div")
      nowMarker:    document.createElement("div")

    uiElements.tlDiv.id         = "timeline"
    uiElements.tlDivWrapper.id  = "timelineWrapper"
    uiElements.tlDivSlide.id    = "timelineSlide"
    uiElements.dayRow.id        = "dayRow"
    uiElements.monthRow.id      = "monthRow"
    uiElements.yearRow.id       = "yearRow"
    uiElements.symbolRow.id     = "symbolRow"

    uiElements.tlDiv.className        = "swiper-container"
    uiElements.tlDivWrapper.className = "swiper-wrapper"
    uiElements.tlDivSlide.className = "swiper-slide"

    uiElements.dayRow.className    = "tl_row"
    uiElements.monthRow.className  = "tl_row"
    uiElements.yearRow.className   = "tl_row"
    uiElements.symbolRow.className = "tl_row"

    uiElements.tlDiv.style.width = window.innerWidth + "px"
    uiElements.tlDivSlide.style.width = (@timelineLength() + window.innerWidth) + "px"

    @_config.parentDiv.appendChild uiElements.tlDiv
    uiElements.tlDiv.appendChild uiElements.tlDivWrapper
    uiElements.tlDivWrapper.appendChild uiElements.tlDivSlide
    uiElements.tlDivSlide.appendChild uiElements.dayRow
    uiElements.tlDivSlide.appendChild uiElements.monthRow
    uiElements.tlDivSlide.appendChild uiElements.yearRow
    uiElements.tlDivSlide.appendChild uiElements.symbolRow
    uiElements.tlDiv.appendChild uiElements.nowMarker

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

  _updateNowDate: ->
    if @_animationTargetDate?
      @_nowDate = @_animationTargetDate
      @_animationTargetDate = null
    else
      @_nowDate = new Date(@yearToDate(@_config.minYear).getTime() + (-1) * @_timeline_swiper.getWrapperTranslate("x") * @millisPerPixel())
    @_nowMarker.nowDateChanged()
    @notifyAll "onNowChanged", @_nowDate

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
  _makeLayout: ->
    tlHeight = HGConfig.timeline_height.val
    tlHeightType = HGConfig.timeline_height.unit

    zoom = @_config.zoom * 5

    hp = 0.66 * tlHeight

    dayRowHeight = (zoom / @_maxZoom) * (1/3)
    monthRowHeight = (zoom / @_maxZoom) * (2/3)
    yearRowHeight = ((@_maxZoom - zoom) / @_maxZoom)

    @_uiElements.tlDivSlide.style.width = (@timelineLength() + window.innerWidth) + "px"
    @moveToDate(@_nowDate, 0)

    @_uiElements.dayRow.style.height = (dayRowHeight * hp) + tlHeightType
    @_uiElements.dayRow.style.fontSize = (dayRowHeight * hp) + tlHeightType

    @_uiElements.monthRow.style.height = (monthRowHeight * hp) + tlHeightType
    @_uiElements.monthRow.style.fontSize = (monthRowHeight * hp) + tlHeightType

    @_uiElements.yearRow.style.height = (yearRowHeight * hp) + tlHeightType
    @_uiElements.yearRow.style.fontSize = (yearRowHeight * hp) + tlHeightType

    @_uiElements.symbolRow.style.height = (0.33 * tlHeight) + tlHeightType
    @_uiElements.symbolRow.style.fontSize = (0.33 * tlHeight) + tlHeightType

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

    @notifyAll "onIntervalChanged", @_getTimeFilter()

  #   --------------------------------------------------------------------------
  #   left border of timeline has date value @_config.minYear
  #   so position of marker on timeline is calculated by millisPerPixel and difference between
  #   the date of the marker and the minYear
  dateToPosition: (date) ->
    dateDiff = date.getTime() - @yearToDate(@_config.minYear).getTime()
    pos = (dateDiff / @millisPerPixel()) + window.innerWidth/2

  #   --------------------------------------------------------------------------
  getUIElements: ->
    @_uiElements

  getNowDate: ->
    @_nowDate

  getNowMarker: ->
    @_nowMarker

  getMaxIntervalIndex: ->
    @_maxIntervalIndex

  #   --------------------------------------------------------------------------
  #   move timeline to specified date and set date as new nowdate
  # moveToDate: (date) ->
  #   if @yearToDate(@_config.minYear).getTime() < date.getTime() && @yearToDate(@_config.maxYear).getTime() > date.getTime()
  #     dateDiff = @yearToDate(@_config.minYear).getTime() - date.getTime()
  #     @_timeline_swiper.setWrapperTranslate(dateDiff / @millisPerPixel(),0,0)

  moveToDate: (date, delay=0) ->
    if @yearToDate(@_config.minYear).getTime() < date.getTime() && @yearToDate(@_config.maxYear).getTime() > date.getTime()
      dateDiff = @yearToDate(@_config.minYear).getTime() - date.getTime()
      @_uiElements.tlDivWrapper.style.transition =  delay + "s"
      @_uiElements.tlDivWrapper.style.webkitTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"

      @_animationTargetDate = date

  #   --------------------------------------------------------------------------
  _animTimeline: =>

    # move timeline periodic
    if @_play
      if @_nowDate.getFullYear() <= @_config.maxYear
        toDate = new Date(@_nowDate.getTime() + @_speed*@_speed * 5000 * 60 * 60 * 24 * 7)
        endDate = new Date @_config.maxYear-1, 11, 31

        if (toDate >= endDate)
          toDate = endDate
          @_nowMarker.animationSwitch()

        @moveToDate(toDate,0)
        @_updateNowDate()
        @_updateDateMarkers()
      else
        @_nowMarker.animationSwitch()

  stopTimeline: ->
    @_play = false

  playTimeline: ->
    @_play = true

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
    d = new Date()
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
  #   Canvas for symbols and Infos on timeline
  #   will be shown below the date numbers
  getCanvas: ->
    @_uiElements.symbolRow

  #   --------------------------------------------------------------------------
  _getTimeFilter: ->
    timefilter = []
    timefilter.end = @maxVisibleDate()
    timefilter.now = @_nowDate
    timefilter.start = @minVisibleDate()
    timefilter

  _disableTextSelection : (e) ->  return false

  _enableTextSelection : () ->    return true
