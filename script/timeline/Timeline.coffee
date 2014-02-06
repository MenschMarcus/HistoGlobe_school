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

  #   STATICS
  DATE_OBJ_START_YEAR = 1970
  HIGHLIGHT_INTERVALS = []

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
      maxYear: 2500

    @_config = $.extend {}, defaultConfig, config

    #   --------------------------------------------------------------------------
    #   keeps all ui elements
    @_uiElements =
      body:      document.getElementsByTagName("body")[0]
      tlDiv:     document.createElement("div")
      dayRow:    document.createElement("div")
      monthRow:  document.createElement("div")
      yearRow:   document.createElement("div")
      symbolRow: document.createElement("div")

    @_uiElements.tlDiv.id     = "timeline"
    @_uiElements.dayRow.id    = "dayRow"
    @_uiElements.monthRow.id  = "monthRow"
    @_uiElements.yearRow.id   = "yearRow"
    @_uiElements.symbolRow.id = "symbolRow"

    @_uiElements.dayRow.className    = "tl_row"
    @_uiElements.monthRow.className  = "tl_row"
    @_uiElements.yearRow.className   = "tl_row"
    @_uiElements.symbolRow.className = "tl_row"

    @_config.parentDiv.appendChild @_uiElements.tlDiv
    @_uiElements.tlDiv.appendChild @_uiElements.dayRow
    @_uiElements.tlDiv.appendChild @_uiElements.monthRow
    @_uiElements.tlDiv.appendChild @_uiElements.yearRow
    @_uiElements.tlDiv.appendChild @_uiElements.symbolRow

    #   --------------------------------------------------------------------------
    @_makeLayout()

    #   --------------------------------------------------------------------------
    #   now marker is always in middle of page and contains the nowDate
    @_nowMarker = new HG.NowMarker(@, @yearToDate @_config.nowYear)

    #   --------------------------------------------------------------------------
    #
    @_dateMarkers   = new HG.DoublyLinkedList()
    @_loadDateMarkers()

    @_minDate = @yearToDate config.minYear
    @_maxDate = @yearToDate config.maxYear
    @_nowDate = @yearToDate config.nowYear

    # create doubly linked list for year markers
    #@_yearMarkers   = new HG.DoublyLinkedList()

    # create first now marker and get width of year markers from it
    # add now marker to doubly linked list
    ###@_nowMarker = new HG.YearMarker @_nowDate, 0, @_uiElements.tlDiv
    @_yearMarkerWidth = @_nowMarker.getWidth() * 2
    @_nowMarker.setWidth @_yearMarkerWidth
    @_nowMarker.setPos(@_uiElements.tlDiv.offsetWidth/2 - @_yearMarkerWidth/2)
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
    nowMarkerDiv = document.createElement "div"
    @_uiElements.tlDiv.appendChild nowMarkerDiv
    ###@nowMarkerBox = new HG.NowMarker(@)
    @nowMarkerBox.setNowDate(@_nowMarker.getDate())###

    # set animation for timeline play
    #@_play = false
    #@_speed = 0
    #setInterval @_animTimeline, 100

    @_uiElements.tlDiv.onmousedown = (e) =>
      ###@_clicked   = true
      @_lastMousePosX = e.pageX
      @_disableTextSelection e###

    @_uiElements.body.onmousemove = (e) =>
      ###if @_clicked
        mousePosX = e.pageX
        moveDist = mousePosX - @_lastMousePosX

        # stop scrolling timeline when min or max is reached
        if((moveDist > 0 and @_yearMarkers.get(0).nodeData.getPos() + @_yearMarkerWidth / 2 < @_uiElements.tlDiv.offsetWidth / 2) or (moveDist < 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + @_yearMarkerWidth / 2 > @_uiElements.tlDiv.offsetWidth / 2))
          @_nowMarker.setPos moveDist + @_nowMarker.getPos()
          @_updateYearMarkerPositions(false)
          @_updateNowMarker()
          @_loadYearMarkers(false)
          @notifyAll "onIntervalChanged", @_getTimeFilter()
        @_lastMousePosX = mousePosX###

    @_uiElements.body.onmouseup = (e) =>
      ###if @_clicked
        @_clicked = false
        @_updateNowMarker()
        @_updateYearMarkerPositions(false)
        @_clearYearMarkers()
        @_lastMousePosX = e.pageX
        @_enableTextSelection()
        @notifyAll "onIntervalChanged", @_getTimeFilter()###

    @_uiElements.tlDiv.onmousewheel = (e) =>
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
        numberOfIntervals = @_uiElements.tlDiv.offsetWidth / @_yearMarkerWidth
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
  millisPerPixel: ->
    millisPerPixel = (@yearToMillis((@_config.maxYear + DATE_OBJ_START_YEAR) - (@_config.minYear + DATE_OBJ_START_YEAR)) / @_uiElements.tlDiv.offsetWidth) / @_config.zoom

  minVisibleDate: ->
    new Date(@_nowMarker.getDate().getTime() - (@millisPerPixel * @_uiElements.tlDiv.offsetWidth))

  maxVisibleDate: ->
    new Date(@_nowMarker.getDate().getTime() + (@millisPerPixel * @_uiElements.tlDiv.offsetWidth))

  # uüdate now marker only when moved timeline
  # move whole div tl when moved
  # when scrolling load new now marker

  #   --------------------------------------------------------------------------
  _makeLayout: ->
    tlHeight = HGConfig.timeline_height.val
    tlHeightType = HGConfig.timeline_height.unit

    @_uiElements.tlDiv.style.fontSize = (0.25 * tlHeight) + tlHeightType

    @_uiElements.dayRow.style.height = (0.25 * tlHeight) + tlHeightType
    @_uiElements.dayRow.style.backgroundColor = "#ff0000"

    @_uiElements.monthRow.style.height = (0.25 * tlHeight) + tlHeightType
    @_uiElements.monthRow.style.backgroundColor = "#00ff00"

    @_uiElements.monthRow.style.height = (0.25 * tlHeight) + tlHeightType
    @_uiElements.yearRow.style.backgroundColor = "#ff00ff"

    @_uiElements.symbolRow.style.height = (0.25 * tlHeight) + tlHeightType
    @_uiElements.symbolRow.style.backgroundColor = "#ffff00"

  #   --------------------------------------------------------------------------
  _loadDateMarkers: ->
    count = @_config.maxYear - @_config.minYear
    for i in [0..count]
      start = new Date(@_config.minYear + i, 0, 1, 0, 0, 0)
      end = new Date(@_config.minYear + i, 11, 31, 0, 0, 0)
      dateMarker = new HG.DateMarker(start, end, @)
      @_dateMarkers.addFirst(dateMarker)

  ###_filterDateMarkers: ->
    for i in [0..@_dateMarkers.length()]
      if(@_dateMarkers.get(i).nodeData.getYearHighlightLevel())
        #TODO: FILTER DATA
        false###

  #   --------------------------------------------------------------------------
  #   calculate date interval in millis to show
  #
  getTimeInterval: ->
    if HIGHLIGHT_INTERVALS.size() == 0
      inLimit = true
      i = 0
      while inLimit
        if i % 2 == 0
          HIGHLIGHT_INTERVALS.push(5 * Math.pow(10, Math.floor(i / 2)))
        else
          HIGHLIGHT_INTERVALS.push(Math.pow(10, Math.floor(i / 2)))
      HIGHLIGHT_INTERVALS.inverse()
    for i in HIGHLIGHT_INTERVALS
      if @_year.date.getFullYear() % HIGHLIGHT_INTERVALS[i] == 0
        return i

  #   --------------------------------------------------------------------------
  #   calculate max zoom level,
  #   so that full interval from minYear to maxYear would be visible
  #   than calculate millis per pixel
  dateToPosition: (date) ->
    dateDiff = date.getTime() - @_nowMarker.getDate().getTime()
    console.log @_nowMarker.getDate().getFullYear()
    pos = (@_uiElements.tlDiv.offsetWidth / 2) + (dateDiff / @millisPerPixel())

  #   --------------------------------------------------------------------------
  getUIElements: ->
    @_uiElements

  getNowDate: ->
    @_nowMarker.getDate()

  #   --------------------------------------------------------------------------
  #   methods to convert objects

  yearToDate: (year) ->
    date = new Date(0)
    date.setFullYear year
    date.setMonth 0
    date.setDate 1
    date

  yearToMillis: (year) ->
    millis = year * 365.25 * 24 * 60 * 60 * 1000

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
    timefilter.end = @_positionToDate(@_uiElements.tlDiv.offsetWidth)
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
      @_nowMarker.setPos(@_uiElements.tlDiv.offsetWidth/2 - @_yearMarkerWidth/2 - pixel)
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
        if @_yearMarkers.get(i).nodeData.getPos() > @_uiElements.tlDiv.offsetWidth and @_yearMarkers.get(i + 1).nodeData.getPos() > @_uiElements.tlDiv.offsetWidth
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
      if xPosRight < @_uiElements.tlDiv.offsetWidth + @_yearMarkerWidth and dateRight.getFullYear() <= @_maxDate.getFullYear()
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
  _timeInterval: (index, exact) ->
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
    res

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
      dis = @_uiElements.tlDiv.offsetWidth / 2 - (@_yearMarkers.get(i).nodeData.getPos() + @_yearMarkerWidth / 2)
      dis *= -1 if dis < 0
      if (smallestDis is null or dis < smallestDis)
        smallestDis = dis
        nId = i
      i++
    @_nowMarker = @_yearMarkers.get(nId).nodeData
    @nowMarkerBox.setNowDate(@_positionToDate((@_uiElements.tlDiv.offsetWidth / 2) - (@_yearMarkerWidth / 2)))
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
      if((@_speed <= 0 and @_yearMarkers.get(0).nodeData.getPos() + @_yearMarkerWidth / 2 < @_uiElements.tlDiv.offsetWidth / 2) or (@_speed > 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + @_yearMarkerWidth / 2 > @_uiElements.tlDiv.offsetWidth / 2))
        @_nowMarker.setPos @_nowMarker.getPos() - @_speed
        @_updateYearMarkerPositions(false)
        @_updateNowMarker()
        @_loadYearMarkers(false)
        @notifyAll "onIntervalChanged", @_getTimeFilter()
      else
        @nowMarkerBox.animationSwitch()

  # TODO: set timeline now date via input field
  ###_setNowMarker: () ->
    @_nowMarker.setPos @_uiElements.tlDiv.offsetWidth / 2
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

