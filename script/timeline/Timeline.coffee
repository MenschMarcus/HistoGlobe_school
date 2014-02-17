window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onNowChanged"
    @addCallback "onIntervalChanged"

    defaultConfig =
      parentDiv: undefined
      nowYear: 1900
      minYear: 1800
      maxYear: 2000

    config = $.extend {}, defaultConfig, config

    # convert years to date objects
    @_minDate = @yearToDate config.minYear
    @_maxDate = @yearToDate config.maxYear
    @_nowDate = @yearToDate config.nowYear

    # get main timeline div and its width
    # get body div for mouse events
    @_body   = document.getElementsByTagName("body")[0]
    @_parent = config.parentDiv

    @_tlDiv = document.createElement "div"
    @_tlDiv.id = "timeline"
    @_parent.appendChild @_tlDiv

    @_tlWidth   = @_tlDiv.offsetWidth

    # index to YEAR_INTERVALS
    @_zoomLevel  = 2

    # create doubly linked list for year markers
    @_yearMarkers   = new HG.DoublyLinkedList()

    # create first now marker and get width of year markers from it
    # add now marker to doubly linked list
    @_nowMarker = new HG.YearMarker @_nowDate, 0, @_tlDiv
    @_yearMarkerWidth = @_nowMarker.getWidth() * 2
    @_nowMarker.setWidth @_yearMarkerWidth
    @_nowMarker.setPos(@_tlWidth/2 - @_yearMarkerWidth/2)
    @_yearMarkers.addFirst(@_nowMarker)

    # get standard font size from now marker
    @_fontSize = $(@_nowMarker.getDiv()).css('font-size')
    @_fontSize = @_fontSize.substring(0,@_fontSize.length - 2)

    # create and draw year markers on right position
    @_loadYearMarkers(false)

    # important vars for mouse events and
    # functions that make timeline scrollable
    @_clicked   = false;
    @_lastMousePosX = 0;

    # create now marker box in middle of page
    nowMarkerDiv = document.createElement "div"
    @_tlDiv.appendChild nowMarkerDiv
    @nowMarkerBox = new HG.NowMarker(@)
    @nowMarkerBox.setNowDate(@_nowMarker.getDate())

    # set animation for timeline play
    @_play = false
    @_speed = 6
    setInterval @_animTimeline, 100

    @_tlDiv.onmousedown = (e) =>
      @_clicked   = true
      @_lastMousePosX = e.pageX
      @_disableTextSelection e

    @_body.onmousemove = (e) =>
      if @_clicked
        mousePosX = e.pageX
        moveDist = mousePosX - @_lastMousePosX

        # stop scrolling timeline when min or max is reached
        if((moveDist > 0 and @_yearMarkers.get(0).nodeData.getPos() + @_yearMarkerWidth / 2 < @_tlWidth / 2) or (moveDist < 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + @_yearMarkerWidth / 2 > @_tlWidth / 2))
          @_nowMarker.setPos moveDist + @_nowMarker.getPos()
          @_updateYearMarkerPositions(false)
          @_updateNowMarker()
          @_loadYearMarkers(false)
          @notifyAll "onIntervalChanged", @_getTimeFilter()
        @_lastMousePosX = mousePosX

    @_body.onmouseup = (e) =>
      if @_clicked
        @_clicked = false
        @_updateNowMarker()
        @_updateYearMarkerPositions(false)
        @_clearYearMarkers()
        @_lastMousePosX = e.pageX
        @_enableTextSelection()
        @notifyAll "onIntervalChanged", @_getTimeFilter()

    @_tlDiv.onmousewheel = (e) =>
      e.preventDefault()
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
        numberOfIntervals = @_tlWidth / @_yearMarkerWidth
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
        @notifyAll "onIntervalChanged", @_getTimeFilter()

  # ============================================================================
  getCanvas : ->
    @_tlDiv

  # ============================================================================
  dateToPosition: (date) ->
    yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / @_timeInterval(@_zoomLevel, true)
    xPos = (yearDiff * @_yearMarkerWidth + (@_nowMarker.getPos()))

  # ============================================================================
  yearToDate : (year) ->
    # aber was wenn das jahr ungerade ist junge?
    date = new Date(0)
    date.setFullYear year
    date.setMonth 0
    date.setDate 1
    date

  # ============================================================================
  scrollToDate: (date) ->
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
      @_nowMarker = new HG.YearMarker(nowDate, 0, @_tlDiv)
      @_yearMarkerWidth = @_nowMarker.getWidth() * 2
      @_nowMarker.setWidth @_yearMarkerWidth
      @_nowMarker.setPos(@_tlWidth/2 - @_yearMarkerWidth/2 - pixel)
      @_yearMarkers.addFirst(@_nowMarker)
      @_loadYearMarkers(false)
      @notifyAll "onIntervalChanged", @_getTimeFilter()
      @notifyAll "onNowChanged", @_positionToDate((@_tlWidth / 2) - (@_yearMarkerWidth / 2))
    else
      console.error "Date #{date} is out of Range."

  # ============================================================================
  _getTimeFilter: ->
    timefilter = []
    ###timefilter.start = @_yearMarkers.get(0).nodeData.getDate()
    timefilter.end = @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getDate()###
    timefilter.end = @_positionToDate(@_tlWidth)
    timefilter.start = @_positionToDate(0)
    timefilter


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
        if @_yearMarkers.get(i).nodeData.getPos() > @_tlWidth and @_yearMarkers.get(i + 1).nodeData.getPos() > @_tlWidth
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
        newYearMarker = new HG.YearMarker(dateBetween, @dateToPosition(dateBetween), @_tlDiv)
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
        newYearMarker = new HG.YearMarker(dateLeft, @dateToPosition(dateLeft), @_tlDiv)
        newYearMarker.setWidth @_yearMarkerWidth
        @_yearMarkers.addFirst(newYearMarker)

      # is new year marker needed?
      if xPosRight < @_tlWidth + @_yearMarkerWidth and dateRight.getFullYear() <= @_maxDate.getFullYear()
        drawn = true
        newYearMarker = new HG.YearMarker(dateRight, @dateToPosition(dateRight), @_tlDiv)
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
      dis = @_tlWidth / 2 - (@_yearMarkers.get(i).nodeData.getPos() + @_yearMarkerWidth / 2)
      dis *= -1 if dis < 0
      if (smallestDis is null or dis < smallestDis)
        smallestDis = dis
        nId = i
      i++
    @_nowMarker = @_yearMarkers.get(nId).nodeData
    @nowMarkerBox.setNowDate(@_positionToDate((@_tlWidth / 2) - (@_yearMarkerWidth / 2)))
    @notifyAll "onNowChanged", @_positionToDate((@_tlWidth / 2) - (@_yearMarkerWidth / 2))

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
      if((@_speed <= 0 and @_yearMarkers.get(0).nodeData.getPos() + @_yearMarkerWidth / 2 < @_tlWidth / 2) or (@_speed > 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + @_yearMarkerWidth / 2 > @_tlWidth / 2))
        @_nowMarker.setPos @_nowMarker.getPos() - @_speed
        @_updateYearMarkerPositions(false)
        @_updateNowMarker()
        @_loadYearMarkers(false)
        @notifyAll "onIntervalChanged", @_getTimeFilter()
      else
        @nowMarkerBox.animationSwitch()

  # TODO: set timeline now date via input field
  ###_setNowMarker: () ->
    @_nowMarker.setPos @_tlWidth / 2
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
  getNowDate: ->
    @nowMarkerBox.getNowDate()
