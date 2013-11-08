window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # interval at which year markers are drawn [year]
  YEAR_INTERVALS = [1/12,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]

  # year marker width
  YEAR_MARKER_WIDTH = 50

  constructor: (nowYear, minYear, maxYear, timelineDiv) ->

    # convert years to date objects
    @_nowDate = @_yearToDate nowYear
    @_minDate = @_yearToDate minYear
    @_maxDate = @_yearToDate maxYear

    # get main timeline div and its width
    # get body div for mouse events
    @_body      = document.getElementById("home")
    @_tlDiv     = timelineDiv
    @_tlWidth   = @_tlDiv.offsetWidth

    # x value of distance between now marker and absolute middle of page
    # important for the calculation of now year markers
    @_posTolerance = 0

    # factor of distortion
    # if factor == 0 timeline is linear
    @_fishEyeFactor = 0

    # index to YEAR_INTERVALS
    @_interval      = 3;

    # create doubly linked list for year markers
    @_yearMarkers   = new HG.DoublyLinkedList()

    # create and draw year markers on right position
    @_createYearMarkers()

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

        # move year in x direction with distance given by mouse event
        # and set new now date
        @_moveYearMarkers moveDist

        # add year markers add beginning and end of list if
        # timeline is not shown till screens end
        @_updateYearMarkers()

        @_lastMousePosX = mousePosX

    @_body.onmouseup = (e) =>
      @_clicked = false
      @_lastMousePosX = e.pageX
      console.log "new now date (year): " + @_nowDate.getFullYear() + "\nwith distance to middle: " + @_posTolerance

    @_tlDiv.onmousewheel = (e) =>

  _updateYearMarkers: ->

    # if year markers are on screen there is min one missing
    # there is always one year marker outside the screen
    # is first year marker on screen?
    if @_yearMarkers.get(0).nodeData.getPos() > 0
      year = @_yearMarkers.get(0).nodeData.getYear() - YEAR_INTERVALS[@_interval]
      xPos = @_dateToPosition(@_yearToDate(year))

      newYearMarker = new HG.YearMarker(year, xPos, @_tlDiv, YEAR_MARKER_WIDTH)
      @_yearMarkers.addFirst(newYearMarker)

    # is last year marker on screen?
    last = @_yearMarkers.getLength() - 1
    if @_yearMarkers.get(last).nodeData.getPos() < @_tlWidth
      year = @_yearMarkers.get(last).nodeData.getYear() + YEAR_INTERVALS[@_interval]
      xPos = @_dateToPosition(@_yearToDate(year))

      newYearMarker = new HG.YearMarker(year, xPos, @_tlDiv, YEAR_MARKER_WIDTH)
      @_yearMarkers.addLast(newYearMarker)

  _createYearMarkers: ->

    # get position and year of now marker
    xPos = @_dateToPosition @_nowDate
    year = @_nowDate.getFullYear()

    # create all year makers on the right side
    # between screen border and nowmarker
    # put all year marker in a doubly linked list
    until xPos > @_tlWidth
      newYearMarker = new HG.YearMarker(year, xPos, @_tlDiv, YEAR_MARKER_WIDTH)
      @_yearMarkers.addLast(newYearMarker)

      # set x position and year of next year marker
      year += YEAR_INTERVALS[@_interval]
      xPos = @_dateToPosition(@_yearToDate(year))

    # last year marker outside the window
    newYearMarker = new HG.YearMarker(year, xPos, @_tlDiv, YEAR_MARKER_WIDTH)
    @_yearMarkers.addLast(newYearMarker)

    # get position and year of element left to the now marker
    year = @_nowDate.getFullYear() - YEAR_INTERVALS[@_interval]
    xPos = @_dateToPosition(@_yearToDate(year))

    # create all year markers on the left side
    # between screen border and nowmarker
    # put all year marker in a doubly linked list
    until xPos < 0
      newYearMarker = new HG.YearMarker(year, xPos, @_tlDiv, YEAR_MARKER_WIDTH)
      @_yearMarkers.addFirst(newYearMarker)

      # set x position and year of next year marker
      year -= YEAR_INTERVALS[@_interval]
      xPos = @_dateToPosition(@_yearToDate(year))

    # last year marker outside the window
    newYearMarker = new HG.YearMarker(year, xPos, @_tlDiv, YEAR_MARKER_WIDTH)
    @_yearMarkers.addFirst(newYearMarker)

  _moveYearMarkers: (dist) ->
    smallestDis = null
    nowDateID   = 0
    i = 0
    while i < @_yearMarkers.getLength()
      @_yearMarkers.get(i).nodeData.getDiv().style.color = "#000000"

      # get year marker from list
      # and set its new position, calculated with distance
      newPosX = @_yearMarkers.get(i).nodeData.getPos() + dist
      @_yearMarkers.get(i).nodeData.setPos newPosX

      # is position close to now maker position?
      dis = (@_tlWidth/2) - (newPosX + YEAR_MARKER_WIDTH/2)
      dis *= -1 if dis < 0
      if smallestDis is null or dis < smallestDis
        smallestDis = dis
        nowDateID = i
      i++

    # set new now marker after moved all year markers
    @_nowDate = @_yearToDate @_yearMarkers.get(nowDateID).nodeData.getYear()

    # highlight new now marker
    @_yearMarkers.get(nowDateID).nodeData.getDiv().style.color = "#ff0000"

    # distance between new now marker and middle of page
    @_posTolerance = @_tlWidth/2 - @_yearMarkers.get(nowDateID).nodeData.getPos() - YEAR_MARKER_WIDTH/2

  _dateToPosition: (date) ->

    # fish eye factor controls the distortion of the view
    # for @_fishEyeFactor == 0 the timeline is linear
    # else is the (xPos^2)/fishEyeFactor
    if @_fishEyeFactor == 0
      yearDiff = (date.getFullYear() - @_nowDate.getFullYear()) / YEAR_INTERVALS[@_interval]
      xPos = (yearDiff * YEAR_MARKER_WIDTH) + (@_tlWidth / 2) - @_posTolerance
    else
      xPos = 0
      #todo: distortion view via fish eye effect
    xPos

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date
