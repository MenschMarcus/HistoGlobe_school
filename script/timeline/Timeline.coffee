window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # interval at which year markers are drawn [year]
  YEAR_INTERVALS = [1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]

  # year marker width
  # TODO: could be calculated by first node (nowMarker) and screen resolution
  YEAR_MARKER_WIDTH = 70

  constructor: (nowYear, minYear, maxYear, timelineDiv, nowMarkerDiv) ->

    # convert years to date objects
    @_minDate = @_yearToDate minYear
    @_maxDate = @_yearToDate maxYear
    @_nowDate = @_yearToDate nowYear

    # get main timeline div and its width
    # get body div for mouse events
    @_body      = document.getElementById("home")
    @_tlDiv     = timelineDiv
    @_tlWidth   = @_tlDiv.offsetWidth

    # index to YEAR_INTERVALS
    @_interval  = 3

    # create doubly linked list for year markers
    @_yearMarkers   = new HG.YearMarkerList()
    @_nowMarker = new HG.YearMarker(@_yearToDate(nowYear), (@_tlWidth/2 - YEAR_MARKER_WIDTH/2), @_tlDiv, YEAR_MARKER_WIDTH)
    @_yearMarkers.addFirst(@_nowMarker)

    # create and draw year markers on right position
    @_loadYearMarkers(false)

    # important vars for mouse events and
    # functions that make timeline scrollable
    @_clicked   = false;
    @_lastMousePosX = 0;

    # create now marker box in middle of page
    @_nowMarkerBox = new HG.NowMarker(@_tlDiv, nowMarkerDiv)

    @_tlDiv.onmousedown = (e) =>
      @_clicked   = true
      @_lastMousePosX = e.pageX
      @_disableTextSelection e

    @_body.onmousemove = (e) =>
      if @_clicked
        mousePosX = e.pageX
        moveDist = mousePosX - @_lastMousePosX

        # stop scrolling timeline when min or max is reached
        if((moveDist > 0 and @_yearMarkers.get(0).nodeData.getPos() + YEAR_MARKER_WIDTH / 2 < @_tlWidth / 2) or (moveDist < 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + YEAR_MARKER_WIDTH / 2 > @_tlWidth / 2))
          @_nowMarker.setPos moveDist + @_nowMarker.getPos()
          @_updateYearMarkerPositions(false)
          @_updateNowMarker()
          @_loadYearMarkers(false)
        @_lastMousePosX = mousePosX

    @_body.onmouseup = (e) =>
      if @_clicked
        @_clicked = false
        @_updateNowMarker()
        @_updateYearMarkerPositions(false)
        @_clearYearMarkers()
        @_lastMousePosX = e.pageX
        @_enableTextSelection()

    @_tlDiv.onmousewheel = (e) =>
      e.preventDefault()
      if e.wheelDeltaY > 0
        if @_interval > 0
          @_interval--
          #@_interval -= 0.5
      else
        if @_interval < YEAR_INTERVALS.length - 1

          # stop zooming when interval is to big for
          # interval of hole timeline (minDate and maxDate)
          if @_minDate.getFullYear() < 0
            mY = @_minDate.getFullYear() * -1
          else
            mY = @_minDate.getFullYear()
          maxScale = @_maxDate.getFullYear() - mY
          numberOfIntervals = @_tlWidth / YEAR_MARKER_WIDTH
          if YEAR_INTERVALS[Math.round(@_interval)] * numberOfIntervals < maxScale
            @_interval++
            #@_interval += 0.5
      #@_updateNowMarker()
      @_clearYearMarkers()
      @_updateYearMarkerPositions(false)
      @_loadYearMarkers(true)
      #@_highlightIntervals()

  _highlightIntervals: ->
    if Math.round(@_interval) + 3 < YEAR_INTERVALS.length
      i = 0
      while i < @_yearMarkers.getLength()
        if(@_yearMarkers.get(i).nodeData.getDate().getFullYear() % YEAR_INTERVALS[Math.round(@_interval) + 3] == 0)
          @_yearMarkers.get(i).nodeData.highlight(1)
        else
          if(@_yearMarkers.get(i).nodeData.getDate().getFullYear() % YEAR_INTERVALS[Math.round(@_interval) + 2] == 0)
            @_yearMarkers.get(i).nodeData.highlight(2)
          else
            @_yearMarkers.get(i).nodeData.highlight(0)
        i++

  _scrollMotionBlur: (slowDownValue, scrollSpeed, pos) ->

    # TODO: motion blur after scrolling

  _updateYearMarkerPositions: (animation) ->
    i = 0
    while i < @_yearMarkers.getLength()
      date = @_yearMarkers.get(i).nodeData.getDate()
      if(!animation)
        @_yearMarkers.get(i).nodeData.setPos @_dateToPosition date
      else
        @_yearMarkers.get(i).nodeData.moveTo 500, @_dateToPosition date
      i++

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
      temp = (@_yearMarkers.get(i).nodeData.getDate().getFullYear()) % YEAR_INTERVALS[Math.round(@_interval)]
      if temp != 0
        @_yearMarkers.get(i).nodeData.destroy()
        @_yearMarkers.remove(i)
      else
        i++

  _fillGaps: ->

    # when overlapping year markers and year markers which are not fit to the scale are removed
    # gaps have to be filled with new year markers, and thats is happening here
    i = 0
    while i < @_yearMarkers.getLength() - 1
      if YEAR_INTERVALS[Math.round(@_interval)] < (@_yearMarkers.get(i + 1).nodeData.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear())
        dateBetween = @_yearToDate (@_yearMarkers.get(i).nodeData.getDate().getFullYear() + YEAR_INTERVALS[Math.round(@_interval)])
        newYearMarker = new HG.YearMarker(dateBetween, @_dateToPosition(dateBetween), @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.insertAfter(i, newYearMarker)
      i++

  _loadYearMarkers: (fillGaps)->

    # draw year markers at beginning and end of list
    drawn = true
    while drawn is true
      drawn = false

      # round date first, so only year markers fit on scale will be shown
      dateLeft =  @_roundDate @_nowMarker.getDate()
      until dateLeft < @_yearMarkers.get(0).nodeData.getDate()
        dateLeft = @_yearToDate(dateLeft.getFullYear() - YEAR_INTERVALS[Math.round(@_interval)])
      xPosLeft = @_dateToPosition(dateLeft)

      # round date first, so only year markers fit on scale will be shown
      dateRight = @_roundDate @_nowMarker.getDate()
      until dateRight > @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getDate()
        dateRight = @_yearToDate(dateRight.getFullYear() + YEAR_INTERVALS[Math.round(@_interval)])
      xPosRight = @_dateToPosition(dateRight)

      # is new year marker needed?
      if xPosLeft > 0 - YEAR_MARKER_WIDTH and dateLeft.getFullYear() >= @_minDate.getFullYear()
        drawn = true
        newYearMarker = new HG.YearMarker(dateLeft, @_dateToPosition(dateLeft), @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.addFirst(newYearMarker)

      # is new year marker needed?
      if xPosRight < @_tlWidth + YEAR_MARKER_WIDTH and dateRight.getFullYear() <= @_maxDate.getFullYear()
        drawn = true
        newYearMarker = new HG.YearMarker(dateRight, @_dateToPosition(dateRight), @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.addLast(newYearMarker)

    # are there gaps in the timeline to fill?
    if fillGaps
      @_fillGaps()

    @_highlightIntervals()

  _updateNowMarker: (dist) ->
    smallestDis = null
    i = 0
    nId = 0
    while i < @_yearMarkers.getLength()
      dis = @_tlWidth / 2 - (@_yearMarkers.get(i).nodeData.getPos() + YEAR_MARKER_WIDTH / 2)
      dis *= -1 if dis < 0
      if (smallestDis is null or dis < smallestDis)
        smallestDis = dis
        nId = i
      i++

    # TODO: difference between year markers which are shown and real now date
    @_nowMarker = @_yearMarkers.get(nId).nodeData
    console.log "Timeline:\n     Current now date: " + @_nowMarker.getDate().getFullYear() + "\n     Time interval: " + YEAR_INTERVALS[Math.round(@_interval)]

  _dateToPosition: (date) ->

    # TODO: calculate real position

    yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / YEAR_INTERVALS[Math.round(@_interval)]
    xPos = (yearDiff * YEAR_MARKER_WIDTH + (@_nowMarker.getPos()))

    # TODO: logarithmic view
    #       (Math.log yearDiff / Math.log 10)

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date

  _roundDate : (date) ->
    @_yearToDate(Math.round(date.getFullYear() / YEAR_INTERVALS[Math.round(@_interval)]) * YEAR_INTERVALS[Math.round(@_interval)])

  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true
