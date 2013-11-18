window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # interval at which year markers are drawn [year]
  YEAR_INTERVALS = [1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]

  # year marker width
  YEAR_MARKER_WIDTH = 70

  constructor: (nowYear, minYear, maxYear, timelineDiv) ->

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
    @_interval      = 3

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

    @_tlDiv.onmousedown = (e) =>
      @_clicked   = true
      @_lastMousePosX = e.pageX
      @_disableTextSelection e

    @_body.onmousemove = (e) =>
      if @_clicked
        mousePosX = e.pageX
        moveDist = mousePosX - @_lastMousePosX
        @_nowMarker.setPos moveDist + @_nowMarker.getPos()
        @_updateYearMarkerPositions()
        @_updateNowMarker()
        @_loadYearMarkers(false)
        @_lastMousePosX = mousePosX

    @_body.onmouseup = (e) =>
      if @_clicked
        @_clicked = false
        @_updateNowMarker()
        @_updateYearMarkerPositions()
        @_clearYearMarkers()
        @_lastMousePosX = e.pageX
        @_enableTextSelection()

    @_tlDiv.onmousewheel = (e) =>
      e.preventDefault()
      if e.wheelDeltaY > 0
        if @_interval > 0
          @_interval--
      else
        if @_interval < YEAR_INTERVALS.length - 1
          @_interval++
      @_updateNowMarker()
      @_clearYearMarkers()
      @_updateYearMarkerPositions()
      @_loadYearMarkers(true)

  _scrollMotionBlur: (slowDownValue, scrollSpeed, pos) ->

    # TODO: motion blur after scrolling

  _updateYearMarkerPositions: ->
    i = 0
    while i < @_yearMarkers.getLength()
      date = @_yearMarkers.get(i).nodeData.getDate()
      @_yearMarkers.get(i).nodeData.setPos @_dateToPosition date
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
      temp = (@_nowMarker.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear()) % YEAR_INTERVALS[@_interval]
      if temp != 0
        @_yearMarkers.get(i).nodeData.destroy()
        @_yearMarkers.remove(i)
      else
        i++

  _fillGaps: ->
    i = 0
    while i < @_yearMarkers.getLength() - 1
      if YEAR_INTERVALS[@_interval] < (@_yearMarkers.get(i + 1).nodeData.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear())
        dateBetween = @_yearToDate (@_yearMarkers.get(i).nodeData.getDate().getFullYear() + YEAR_INTERVALS[@_interval])
        newYearMarker = new HG.YearMarker(dateBetween, @_dateToPosition(dateBetween), @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.insertAfter(i, newYearMarker)
      i++

  _loadYearMarkers: (fillGaps)->

    # draw year markers at beginning and end of list
    drawn = true
    while drawn is true
      drawn = false

      dateLeft = @_nowMarker.getDate()
      until dateLeft < @_yearMarkers.get(0).nodeData.getDate()
        dateLeft = @_yearToDate(dateLeft.getFullYear() - YEAR_INTERVALS[@_interval])
      xPosLeft = @_dateToPosition(dateLeft)

      dateRight = @_nowMarker.getDate()
      until dateRight > @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getDate()
        dateRight = @_yearToDate(dateRight.getFullYear() + YEAR_INTERVALS[@_interval])
      xPosRight = @_dateToPosition(dateRight)

      if xPosLeft > 0 - YEAR_MARKER_WIDTH
        drawn = true
        newYearMarker = new HG.YearMarker(dateLeft, xPosLeft, @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.addFirst(newYearMarker)

      if xPosRight < @_tlWidth + YEAR_MARKER_WIDTH
        drawn = true
        newYearMarker = new HG.YearMarker(dateRight, xPosRight, @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.addLast(newYearMarker)

    if fillGaps
      @_fillGaps()

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
    console.log "Timeline:\n     Current now date: " + @_nowMarker.getDate().getFullYear() + "\n     Time interval: " + YEAR_INTERVALS[@_interval]

  _dateToPosition: (date) ->
    yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / YEAR_INTERVALS[@_interval]
    xPos = (yearDiff * YEAR_MARKER_WIDTH) + (@_nowMarker.getPos())

    # TODO: logarithmic view
    #       (Math.log yearDiff / Math.log 10)

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date

  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true
