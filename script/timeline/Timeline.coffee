window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   D E S C R I P T I O N
  #   4 reihen tage, monate, jahre, symbole
  #   je nach zoom ändert sich größe der reihen
  #   reihen größe prozentual zur tlHeight
  #   shrift prozentual zur div height
  #
  #   degrees of drawing is millis per pixel which is calculated by the zoomlevel index
  #   width of dateMarkers is variable, font-weight is bound to the width
  #   3 rows are shown, days, years, months
  #   if things are overlapped, they will be hidden
  #   keep dateMarkers in array, dont remove them fully, user "display:none"
  #
  #   NowMarker.setDate (year) -> find (move) oder create
  #   updatepositions ->  move transition time per length of distance
  #                       hide, show
  #                       updatepositions of other markers
  #   onMouseMove: -> NowMarker.setDate millisPerPixel + DistanceInPixel
  #   onLoad: create all dateMarkers with positions from min_screen to max_screen
  #   filterDateMarkers: -> nextDiv -> is positionborder overlapping to last? -> hide else show and set position border ->
  #
  #   raise size of dateMarkers, width * index,
  #   show days?
  #   show months?
  #
  # http://www.idangero.us/sliders/swiper/api.php
  #
  #
  #
  #   timeline
  #   --> updateLayout
  #     height of rows
  #   loadDateMarkers
  #

  #   ---------------------------------------------------------------------
  constructor: (config) ->
    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onNowChanged"
    @addCallback "onIntervalChanged"

    defaultConfig =
      parentDiv: undefined
      zoom: 1
      nowYear: 1000
      minYear: 0
      maxYear: 2000

    @_config = $.extend {}, defaultConfig, config

    #   --------------------------------------------------------------------------
    @_uiElements = @_createUIElements()

    #   --------------------------------------------------------------------------
    @_maxZoom = @maxZoomLevel()
    @_maxIntervalIndex = @_calcMaxIntervalIndex()

    #   --------------------------------------------------------------------------
    #   Swiper for timeline
    @_timeline_swiper ?= new Swiper '#timeline',
      mode:'horizontal'
      freeModeFluid: true
      freeMode: true

    @_timeline_swiper.reInit()

    #   --------------------------------------------------------------------------
    @_makeLayout()

    #   --------------------------------------------------------------------------
    @_nowDate = @yearToDate(@_config.nowYear)

    #   --------------------------------------------------------------------------
    #   now marker is always in middle of page and contains the nowDate
    #   TODO: make new now marker
    @_nowMarker = new HG.NowMarker(@, @_nowDate)
    nowMarkerDiv = document.createElement "div"
    @_uiElements.tlDiv.appendChild nowMarkerDiv

    #   --------------------------------------------------------------------------
    @_dateMarkers   = new HG.DoublyLinkedList()
    @_updateDateMarkers()

    #   --------------------------------------------------------------------------
    #   mouse and touch events
    ###@c = false
    @lmp = 0
    @_uiElements.tlDiv.onmousedown = (e) =>
      @c = true
      @lmp = e.pageX

    @_uiElements.body.onmousemove = (e) =>
      if @c
        pos = @_uiElements.tlDiv.offsetLeft + (e.pageX - @lmp)
        @_uiElements.tlDiv.style.left = pos + "px"
        @lmp = e.pageX

    @_uiElements.body.onmouseup = (e) =>
      @c = false if @c
      @lmp = e.pageX###

    @_uiElements.tlDiv.onmousewheel = (e) =>
      e.preventDefault()
      zoomed = false
      if e.wheelDeltaY > 0
        if @_config.zoom < @_maxZoom
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

    @_uiElements.tlDivWrapper.addEventListener "webkitTransitionEnd", (e) =>
      alert( "Finished transition!" )
    , false

    #   --------------------------------------------------------------------------

    # OLD STUFF
    #@_minDate = @yearToDate config.minYear
    #@_maxDate = @yearToDate config.maxYear
    #@_nowDate = @yearToDate config.nowYear

    # create doubly linked list for year markers
    #@_yearMarkers   = new HG.DoublyLinkedList()

    # create first now marker and get width of year markers from it
    # add now marker to doubly linked list
    ###@_nowMarker = new HG.YearMarker @_nowDate, 0, @_uiElements.tlDiv
    @_yearMarkerWidth = @_nowMarker.getWidth() * 2
    @_nowMarker.setWidth @_yearMarkerWidth
    @_nowMarker.setPos(window.innerWidth/2 - @_yearMarkerWidth/2)
    @_yearMarkers.addFirst(@_nowMarker)

    # get standard font size from now marker
    @_fontSize = $(@_nowMarker.getDiv()).css('font-size')
    @_fontSize = @_fontSize.substring(0,@_fontSize.length - 2)
###
    # create and draw year markers on right position
    #@_loadYearMarkers(false)

    # important vars for mouse events and
    # functions that make timeline scrollable
    #@_clicked   = false;
    #@_lastMousePosX = 0;

    # create now marker box in middle of page
    #nowMarkerDiv = document.createElement "div"
    #@_uiElements.tlDiv.appendChild nowMarkerDiv
    ###@nowMarkerBox = new HG.NowMarker(@)
    @nowMarkerBox.setNowDate(@_nowMarker.getDate())###

    # set animation for timeline play
    #@_play = false
    #@_speed = 0
    #setInterval @_animTimeline, 100

    #@_uiElements.tlDiv.onmousedown = (e) =>
    ###@_clicked   = true
    @_lastMousePosX = e.pageX
    @_disableTextSelection e###

    #@_uiElements.body.onmousemove = (e) =>
    ###if @_clicked
      mousePosX = e.pageX
      moveDist = mousePosX - @_lastMousePosX

      # stop scrolling timeline when min or max is reached
      if((moveDist > 0 and @_yearMarkers.get(0).nodeData.getPos() + @_yearMarkerWidth / 2 < window.innerWidth / 2) or (moveDist < 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + @_yearMarkerWidth / 2 > window.innerWidth / 2))
        @_nowMarker.setPos moveDist + @_nowMarker.getPos()
        @_updateYearMarkerPositions(false)
        @_updateNowMarker()
        @_loadYearMarkers(false)
        @notifyAll "onIntervalChanged", @_getTimeFilter()
      @_lastMousePosX = mousePosX###

    @_uiElements.body.onmouseup = (e) =>
      console.log "left position of timeline: " + @_uiElements.tlDivWrapper.style.getPropertyCSSValue('-webkit-transform')[0][0].getFloatValue(CSSPrimitiveValue.CSS_PX)
      console.log "now Date: " + @_calcNowDate()
    ###if @_clicked
      @_clicked = false
      @_updateNowMarker()
      @_updateYearMarkerPositions(false)
      @_clearYearMarkers()
      @_lastMousePosX = e.pageX
      @_enableTextSelection()
      @notifyAll "onIntervalChanged", @_getTimeFilter()###

    #@_uiElements.tlDiv.onmousewheel = (e) =>
    ###e.preventDefault()
    zoom = false
    if e.wheelDeltaY > 0
      if @_zoomLevel > 0
        @_zoomLevel -= 0.1
        zoom = true
    else

      # stop zooming when interval is to big for size of hole timeline (minDate and maxDate)
      if @_minDate.getFullYear() < 0
        mY = @_minDate.getFullYear() * -1
      else
        mY = @_minDate.getFullYear()
      maxScale = @_maxDate.getFullYear() - mY
      numberOfIntervals = window.innerWidth / @_yearMarkerWidth
      if @_timeInterval(@_zoomLevel, false) * numberOfIntervals < maxScale
        @_zoomLevel += 0.1
        zoom = true

    # console.log "Timeline: \n     ZoomLevel: " + @_zoomLevel

    # execute changed year interval
    # if interval was changed
    if zoom
      @_zoomLevel = @_roundNumber(@_zoomLevel, 1)
      @_clearYearMarkers()
      @_updateYearMarkerPositions(false)
      @_loadYearMarkers(true)
      @notifyAll "onIntervalChanged", @_getTimeFilter()###

  #   --------------------------------------------------------------------------
  _createUIElements: ->

    uiElements =
      body:         document.getElementsByTagName("body")[0]
      tlDiv:        document.createElement("div")
      tlDivWrapper: document.createElement("div")
      dayRow:       document.createElement("div")
      monthRow:     document.createElement("div")
      yearRow:      document.createElement("div")
      symbolRow:    document.createElement("div")

    uiElements.tlDiv.id         = "timeline"
    uiElements.tlDivWrapper.id  = "timelineWrapper"
    uiElements.dayRow.id        = "dayRow"
    uiElements.monthRow.id      = "monthRow"
    uiElements.yearRow.id       = "yearRow"
    uiElements.symbolRow.id     = "symbolRow"

    uiElements.tlDiv.className        = "swiper-container"
    uiElements.tlDivWrapper.className = "swiper-wrapper"

    uiElements.dayRow.className    = "tl_row swiper-slide"
    uiElements.monthRow.className  = "tl_row swiper-slide"
    uiElements.yearRow.className   = "tl_row swiper-slide"
    uiElements.symbolRow.className = "tl_row swiper-slide"

    uiElements.tlDiv.style.width = window.innerWidth + "px"
    uiElements.dayRow.style.width = (@timelineLength() + window.innerWidth/2) + "px"
    uiElements.monthRow.style.width = (@timelineLength() + window.innerWidth/2) + "px"
    uiElements.yearRow.style.width = (@timelineLength() + window.innerWidth/2) + "px"
    uiElements.symbolRow.style.width = (@timelineLength() + window.innerWidth/2) + "px"

    @_config.parentDiv.appendChild uiElements.tlDiv
    uiElements.tlDiv.appendChild uiElements.tlDivWrapper
    uiElements.tlDivWrapper.appendChild uiElements.dayRow
    uiElements.tlDivWrapper.appendChild uiElements.monthRow
    uiElements.tlDivWrapper.appendChild uiElements.yearRow
    uiElements.tlDivWrapper.appendChild uiElements.symbolRow

    uiElements

  #   --------------------------------------------------------------------------
  millisPerPixel: ->
    mpp = (@yearToMillis(@_config.maxYear - @_config.minYear) / window.innerWidth) / @_config.zoom

  minVisibleDate: ->
    d = new Date(@_nowMarker.getDate().getTime() - (@millisPerPixel() * window.innerWidth / 2))

  maxVisibleDate: ->
    d = new Date(@_nowMarker.getDate().getTime() + (@millisPerPixel() * window.innerWidth / 2))

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

  _calcNowDate: ->
    new Date(@yearToDate(@_config.minYear).getTime() + (-1) * @_uiElements.tlDivWrapper.style.getPropertyCSSValue('-webkit-transform')[0][0].getFloatValue(CSSPrimitiveValue.CSS_PX) * @millisPerPixel())

  #   --------------------------------------------------------------------------
  #   for i e {0,1,2,3,...} it should return 1,5,10,50,100,...
  #   needed for highlightinh timescale dates
  timeInterval: (i) ->
    if i % 2 != 0
      return @yearToMillis(5 * Math.pow(10, Math.floor(i / 2)))
    else
      return @yearToMillis(Math.pow(10, Math.floor(i / 2)))


  #   --------------------------------------------------------------------------
  #   set HEIGHT and WIDTH of TIMELINE
  _makeLayout: ->
    tlHeight = HGConfig.timeline_height.val
    tlHeightType = HGConfig.timeline_height.unit

    zoom = @_config.zoom * 5

    hp = 0.75 * tlHeight

    dayRowHeight = (zoom / @_maxZoom) * (1/3)
    monthRowHeight = (zoom / @_maxZoom) * (2/3)
    yearRowHeight = ((@_maxZoom - zoom) / @_maxZoom)

    @_uiElements.dayRow.style.height = (dayRowHeight * hp) + tlHeightType
    @_uiElements.dayRow.style.width = (@timelineLength() + window.innerWidth/2) + tlHeightType
    @_uiElements.dayRow.style.fontSize = (dayRowHeight * hp) + tlHeightType
    @_uiElements.dayRow.style.backgroundColor = "#ff0000"

    @_uiElements.monthRow.style.height = (monthRowHeight * hp) + tlHeightType
    @_uiElements.monthRow.style.width = (@timelineLength() + window.innerWidth/2) + tlHeightType
    @_uiElements.monthRow.style.fontSize = (monthRowHeight * hp) + tlHeightType
    @_uiElements.monthRow.style.backgroundColor = "#00ff00"

    @_uiElements.yearRow.style.height = (yearRowHeight * hp) + tlHeightType
    @_uiElements.yearRow.style.width = (@timelineLength() + window.innerWidth/2) + tlHeightType
    @_uiElements.yearRow.style.fontSize = (yearRowHeight * hp) + tlHeightType
    @_uiElements.yearRow.style.backgroundColor = "#ff00ff"

    @_uiElements.symbolRow.style.height = (0.25 * tlHeight) + tlHeightType
    @_uiElements.symbolRow.style.width = (@timelineLength() + window.innerWidth/2) + tlHeightType
    @_uiElements.symbolRow.style.fontSize = (0.25 * tlHeight) + tlHeightType
    @_uiElements.symbolRow.style.backgroundColor = "#ffff00"

  #   --------------------------------------------------------------------------
  _updateDateMarkers: ->
    console.log "Update DateMarkers"

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


  # OLD STUFF
  # ============================================================================
  getCanvas : ->
    @_uiElements.tlDiv

  ### ============================================================================
  dateToPosition: (date) ->
    yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / @_timeInterval(@_zoomLevel, true)
    xPos = (yearDiff * @_yearMarkerWidth + (@_nowMarker.getPos()))
###
  # ============================================================================


  # ============================================================================
  _getTimeFilter: ->
    timefilter = []
    ###timefilter.start = @_yearMarkers.get(0).nodeData.getDate()
    timefilter.end = @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getDate()###
    timefilter.end = @_positionToDate(window.innerWidth)
    timefilter.start = @_positionToDate(0)
    timefilter

  # ============================================================================
  _scrollToDate: (date) ->
    if date.getFullYear() > @_minDate.getFullYear() and date.getFullYear() < @_maxDate.getFullYear()

      # delete old year markers
      i = 0
      while i < @_yearMarkers.getLength()
          @_yearMarkers.get(i).nodeData.destroy()
          i++

      # create new year markers
      @_yearMarkers   = new HG.DoublyLinkedList()
      if(date.getMonth() == 0 && date.getDate() == 1)
        @_zoomLevel = @_calcZoomLevel date.getFullYear()
      else
        @_zoomLevel = 0
      nowDate = @yearToDate(date.getFullYear())
      pixel = (date.getTime() - nowDate.getTime()) / @_millisPerPixel()
      @_nowMarker = new HG.YearMarker(nowDate, 0, @_uiElements.tlDiv)
      @_yearMarkerWidth = @_nowMarker.getWidth() * 2
      @_nowMarker.setWidth @_yearMarkerWidth
      @_nowMarker.setPos(window.innerWidth/2 - @_yearMarkerWidth/2 - pixel)
      @_yearMarkers.addFirst(@_nowMarker)
      @_loadYearMarkers(false)
      @notifyAll "onIntervalChanged", @_getTimeFilter()
    else
      alert "Date is out of Range."

  # ============================================================================
  _highlightIntervals: ->

    # set the font size of year markers in relation to the shown time interval
    diff = (@_zoomLevel - Math.round(@_zoomLevel)) * 2
    i = 0
    while i < @_yearMarkers.getLength()
      if(@_yearMarkers.get(i).nodeData.getDate().getFullYear() % @_timeInterval(@_zoomLevel + 2, false) == 0)
        @_yearMarkers.get(i).nodeData.highlight(1)
      else
        if(@_yearMarkers.get(i).nodeData.getDate().getFullYear() % @_timeInterval(@_zoomLevel + 1, false) == 0)
          @_yearMarkers.get(i).nodeData.highlight(2)
        else
          @_yearMarkers.get(i).nodeData.highlight(0)
          if diff > 0
            @_yearMarkers.get(i).nodeData.getDiv().style.fontSize = (1 - diff) * @_fontSize + "px"
            @_yearMarkers.get(i).nodeData.getDiv().style.opacity = (1 - diff)
      i++

  # ============================================================================
  _scrollMotionBlur: (slowDownValue, scrollSpeed, pos) ->

    # TODO: motion blur after scrolling


  # ============================================================================
  _updateYearMarkerPositions: (animation) ->
    i = 0
    while i < @_yearMarkers.getLength()
      date = @_yearMarkers.get(i).nodeData.getDate()
      if(!animation)
        @_yearMarkers.get(i).nodeData.setPos @dateToPosition date
      else
        @_yearMarkers.get(i).nodeData.moveTo 500, @dateToPosition date
      i++

  # ============================================================================
  _clearYearMarkers: ->

    # remove year marker outside of screen
    i = 0
    while i < @_yearMarkers.getLength() - 1
      if @_yearMarkers.get(i).nodeData.getPos() < 0 and @_yearMarkers.get(i + 1).nodeData.getPos() < 0
        @_yearMarkers.get(i).nodeData.destroy()
        @_yearMarkers.remove(i)
      else
        if @_yearMarkers.get(i).nodeData.getPos() > window.innerWidth and @_yearMarkers.get(i + 1).nodeData.getPos() > window.innerWidth
          @_yearMarkers.get(i + 1).nodeData.destroy()
          @_yearMarkers.remove(i + 1)
        else
          i++

    # remove overlapping year markers
    i = 0
    while i < @_yearMarkers.getLength()
      temp  = (@_yearMarkers.get(i).nodeData.getDate().getFullYear()) % @_timeInterval(@_zoomLevel, false)
      if temp != 0
        @_yearMarkers.get(i).nodeData.destroy()
        @_yearMarkers.remove(i)
      else
        i++

  # ============================================================================
  _fillGaps: ->

    # when overlapping year markers and year markers which are not fit to the scale are removed
    # gaps have to be filled with new year markers, and thats is happening here
    i = 0
    while i < @_yearMarkers.getLength() - 1
      if @_timeInterval(@_zoomLevel, false) < (@_yearMarkers.get(i + 1).nodeData.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear())
        dateBetween = @yearToDate (@_yearMarkers.get(i).nodeData.getDate().getFullYear() + @_timeInterval(@_zoomLevel, false))
        newYearMarker = new HG.YearMarker(dateBetween, @dateToPosition(dateBetween), @_uiElements.tlDiv)
        newYearMarker.setWidth @_yearMarkerWidth
        @_yearMarkers.insertAfter(i, newYearMarker)
      i++

  # ============================================================================
  _loadYearMarkers: (fillGaps)->

    # draw year markers at beginning and end of list
    drawn = true
    while drawn is true
      drawn = false

      # round date first, so only year markers fit on scale will be shown
      dateLeft =  @_roundDate @_nowMarker.getDate()
      until dateLeft < @_yearMarkers.get(0).nodeData.getDate()
        dateLeft = @yearToDate(dateLeft.getFullYear() - @_timeInterval(@_zoomLevel, false))
      xPosLeft = @dateToPosition(dateLeft)

      # round date first, so only year markers fit on scale will be shown
      dateRight = @_roundDate @_nowMarker.getDate()
      until dateRight > @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getDate()
        dateRight = @yearToDate(dateRight.getFullYear() + @_timeInterval(@_zoomLevel, false))
      xPosRight = @dateToPosition(dateRight)

      # is new year marker needed?
      if xPosLeft > 0 - @_yearMarkerWidth and dateLeft.getFullYear() >= @_minDate.getFullYear()
        drawn = true
        newYearMarker = new HG.YearMarker(dateLeft, @dateToPosition(dateLeft), @_uiElements.tlDiv)
        newYearMarker.setWidth @_yearMarkerWidth
        @_yearMarkers.addFirst(newYearMarker)

      # is new year marker needed?
      if xPosRight < window.innerWidth + @_yearMarkerWidth and dateRight.getFullYear() <= @_maxDate.getFullYear()
        drawn = true
        newYearMarker = new HG.YearMarker(dateRight, @dateToPosition(dateRight), @_uiElements.tlDiv)
        newYearMarker.setWidth @_yearMarkerWidth
        @_yearMarkers.addLast(newYearMarker)

    # are there gaps in the timeline to fill?
    if fillGaps
      @_fillGaps()

    # highlight year markers with a rounded date
    @_highlightIntervals()

  # ============================================================================
  ###_timeInterval: (index, exact) ->
    yearIntervals = [1,5,10,50,100,500,1000,5000,10000,50000,100000,500000,1000000,5000000]

    # index is zoomlevel
    # exect says function should return rounded or exact year intveral
    if exact and index > 0
      i = 0
      while index > i
        i++
      next = i
      prev = i - 1
      dis = index - prev
      res = yearIntervals[prev] + (yearIntervals[next] - yearIntervals[prev]) * dis
    else
      res = yearIntervals[Math.round(index)]
    res###

  # ============================================================================
  _calcZoomLevel: (year) ->
    yearIntervals = [1,5,10,50,100,500,1000,5000,10000,50000,100000,500000,1000000,5000000]
    i = 0
    bam = true
    while year % yearIntervals[i] == 0
        i++
    if i > 1
      i -= 2
    else
      if i > 0
        i -= 1
    i

  # ============================================================================
  _updateNowMarker: (dist) ->
    smallestDis = null
    i = 0
    nId = 0
    while i < @_yearMarkers.getLength()
      dis = window.innerWidth / 2 - (@_yearMarkers.get(i).nodeData.getPos() + @_yearMarkerWidth / 2)
      dis *= -1 if dis < 0
      if (smallestDis is null or dis < smallestDis)
        smallestDis = dis
        nId = i
      i++
    @_nowMarker = @_yearMarkers.get(nId).nodeData
    @nowMarkerBox.setNowDate(@_positionToDate((window.innerWidth / 2) - (@_yearMarkerWidth / 2)))
    @notifyAll "onNowChanged", @_nowMarker.getDate()

  # ============================================================================
  _positionToDate: (position) ->
    millisPerPixel = @_millisPerPixel()
    pixelDiff = position - @_nowMarker.getPos()
    exactNowDate = (pixelDiff * millisPerPixel) + @_nowMarker.getDate().getTime()
    new Date(exactNowDate)

  # ============================================================================
  _millisPerPixel: ->
    yearDiffExact = @_timeInterval(@_zoomLevel, true)
    yearDiff = Math.round(yearDiffExact)
    monthDiffExact = (yearDiffExact - yearDiff) / (1/12)
    monthDiff = Math.round(monthDiffExact)
    dayDiffExact = (yearDiffExact - yearDiff) / (1/365)
    dayDiff = Math.round(dayDiffExact)

    millisDiff = yearDiffExact * 365 * 24 * 60 * 60 * 1000
    millisPerPixel = millisDiff / @_yearMarkerWidth


  # ============================================================================
  _roundDate : (date) ->
    @yearToDate(Math.round(date.getFullYear() / @_timeInterval(@_zoomLevel, false)) * @_timeInterval(@_zoomLevel, false))

  # ============================================================================
  _roundNumber : (number, n) ->
    factor = Math.pow(10,n)
    Math.round(number * factor) / factor

  # ============================================================================
  _disableTextSelection : (e) ->  return false

  # ============================================================================
  _enableTextSelection : () ->    return true

  # ============================================================================
  _animTimeline: =>

    # move timeline periodic
    if @_play
      if((@_speed <= 0 and @_yearMarkers.get(0).nodeData.getPos() + @_yearMarkerWidth / 2 < window.innerWidth / 2) or (@_speed > 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + @_yearMarkerWidth / 2 > window.innerWidth / 2))
        @_nowMarker.setPos @_nowMarker.getPos() - @_speed
        @_updateYearMarkerPositions(false)
        @_updateNowMarker()
        @_loadYearMarkers(false)
        @notifyAll "onIntervalChanged", @_getTimeFilter()
      else
        @nowMarkerBox.animationSwitch()

  # TODO: set timeline now date via input field
  ###_setNowMarker: () ->
    @_nowMarker.setPos window.innerWidth / 2
    @_nowMarker._date = ###

  # ============================================================================
  stopTimeline: ->
    @_play = false

  # ============================================================================
  playTimeline: ->
    @_play = true

  # ============================================================================
  setSpeed: (speed) ->
    @_speed = speed

  # ============================================================================
  getPlayStatus: ->
    @_play

  # ============================================================================

