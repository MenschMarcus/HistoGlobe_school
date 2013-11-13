window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # interval at which year markers are drawn [year]
  YEAR_INTERVALS = [1/12,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]

  # year marker width
  YEAR_MARKER_WIDTH = 70

  constructor: (nowYear, minYear, maxYear, timelineDiv) ->

    # convert years to date objects
    @_minDate = @_yearToDate minYear
    @_maxDate = @_yearToDate maxYear

    # get main timeline div and its width
    # get body div for mouse events
    @_body      = document.getElementById("home")
    @_tlDiv     = timelineDiv
    @_tlWidth   = @_tlDiv.offsetWidth

    # index to YEAR_INTERVALS
    @_interval      = 4

    # create doubly linked list for year markers
    @_yearMarkers   = new HG.YearMarkerList()
    @_nowMarker = new HG.YearMarker(@_yearToDate(nowYear), (@_tlWidth/2 - YEAR_MARKER_WIDTH/2), @_tlDiv, YEAR_MARKER_WIDTH)
    @_yearMarkers.addFirst(@_nowMarker)

    # create and draw year markers on right position
    @_loadYearMarkers()

    # important vars for mouse events and
    # functions that make timeline scrollable
    @_clicked   = false;
    @_lastMousePosX = 0;

    @_tlDiv.onmousedown = (e) =>
      @_clicked   = true
      @_lastMousePosX = e.pageX

    @_body.onmousemove = (e) =>
      if @_clicked
        mousePosX = e.pageX
        moveDist = mousePosX - @_lastMousePosX
        @_nowMarker.setPos moveDist + @_nowMarker.getPos()
        @_updateYearMarkerPositions()
        @_updateNowMarker()
        @_loadYearMarkers()
        @_lastMousePosX = mousePosX

    @_body.onmouseup = (e) =>

      if @_clicked
        @_clicked = false
        @_lastMousePosX = e.pageX

    @_tlDiv.onmousewheel = (e) =>
      # prevent scrolling of map
      e.preventDefault()
      # zoom in
      if e.wheelDeltaY > 0
        if @_interval > 0
          @_interval--
      # zoom out
      else
        if @_interval < YEAR_INTERVALS.length
          @_interval++

      @_updateYearMarkerPositions()
      @_updateNowMarker()
      @_loadYearMarkers()

  _updateYearMarkerPositions: ->
    i = 0
    while i < @_yearMarkers.getLength()
      temp = (@_nowMarker.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear()) % YEAR_INTERVALS[@_interval]
      if temp == 0
        date = @_yearMarkers.get(i).nodeData.getDate()
        @_yearMarkers.get(i).nodeData.setPos @_dateToPosition date
      else
        @_yearMarkers.get(i).nodeData.destroy()
      i++

  _loadYearMarkers: ->
    dateLeft = @_yearToDate(@_yearMarkers.get(0).nodeData.getDate().getFullYear() - YEAR_INTERVALS[@_interval])
    xPosLeft = @_dateToPosition(dateLeft)

    dateRight = @_yearToDate(@_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getDate().getFullYear() + YEAR_INTERVALS[@_interval])
    xPosRight = @_dateToPosition(dateRight)

    drawn = false
    if xPosLeft > 0
      drawn = true
      newYearMarker = new HG.YearMarker(dateLeft, xPosLeft, @_tlDiv, YEAR_MARKER_WIDTH)
      @_yearMarkers.addFirst(newYearMarker)

    if xPosRight < @_tlWidth
      drawn = true
      newYearMarker = new HG.YearMarker(dateRight, xPosRight, @_tlDiv, YEAR_MARKER_WIDTH)
      @_yearMarkers.addLast(newYearMarker)

    if drawn
      @_loadYearMarkers()

  _updateNowMarkers: (dist) ->
    smallestDis = null
    i = 0
    nId = 0
    while i < @_yearMarkers.getLength()
      dis = @_tlWidth / 2 - (@_yearMarkers.get(i).nodeData.getPos() + YEAR_MARKER_WIDTH / 2)
      dis *= -1 if dis < 0
      if smallestDis is null or dis < smallestDis
        smallestDis = dis
        nId = i
      i++
    @_nowMarker = @_yearMarkers.get(nId).nodeData
    console.log "Timeline:\n     Current now date: " + @_nowMarker.getDate().getFullYear()

  _dateToPosition: (date) ->

    yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / YEAR_INTERVALS[@_interval]
    xPos = (yearDiff * YEAR_MARKER_WIDTH) + (@_nowMarker.getPos())
    #console.log "Intervall: " + @_interval
    xPos

    ### yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / YEAR_INTERVALS[@_interval]

      # make yearDiff positiv to make logaritmic function usable
      minus = false
      if yearDiff < 0
        yearDiff *= -1
        minus = true

      # set case of break
      if yearDiff and yearDiff < 100 and yearDiff > -100
        yearDiff = ((Math.log yearDiff / Math.log 10) + @_fishEyeFactor) + yearDiff

      # invert yearDiff if it was negative and determine position of yearMarker
      yearDiff *= -1 if minus
      xPos = (yearDiff * YEAR_MARKER_WIDTH) + (@_tlWidth / 2) - @_posTolerance
    ###


  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date
