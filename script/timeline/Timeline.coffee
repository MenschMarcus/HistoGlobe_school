window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # interval at which year markers are drawn [year]
  YEAR_INTERVALS = [1/12,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]

  # year marker width
  YEAR_MARKER_WIDTH = 50

  # ============================================================================
  constructor: (nowYear, minYear, maxYear, timelineDiv) ->

    # convert years to date objects
    @_nowDate = @_yearToDate nowYear
    @_minDate = @_yearToDate minYear
    @_maxDate = @_yearToDate maxYear

    # get main timeline div and its width
    # get body div for mouse events
    @_body = document.getElementById("home")
    @_tlDiv   = timelineDiv
    @_tlWidth = @_tlDiv.offsetWidth

    # factor of distortion
    # if factor == 0 timeline is linear
    @_fishEyeFactor = 0

    # index to YEAR_INTERVALS
    @_interval      = 3;

    # create doubly linked list for year markers
    @_yearMarkers = new HG.DoublyLinkedList()

    # create and draw year markers
    @_createYearMarkers()

    # ==========================================================================
    @_clicked   = false;
    @_lastMousePosX = 0;

    @_tlDiv.onmousedown = (e) =>
      @_clicked   = true
      @_lastMousePosX = e.pageX
      @_disableTextSelection()
      console.log e.pageX

    @_body.onmousemove = (e) =>

      # catch any mouse event to allow scrolling of timeline even if mouse is not inside timeline
      if @_clicked
        mousePosX = e.pageX
        moveDist = mousePosX - @_lastMousePosX
        @_moveYearMarkers moveDist
        @_lastMousePosX = mousePosX

    @_body.onmouseup = (e) =>
      @_clicked = false
      @_lastMousePosX = e.pageX
      ###if @_downOnTimeline
        @_updateScroller()
        @_downOnTimeline = false  # catch any mouse up event in UI to stop dragging
      @_lastMousePosX = e.pageX
      @_enableTextSelection()###

    # zooming
    @_tlDiv.onmousewheel = (e) =>
      ### prevent scrolling of map
      e.preventDefault()
      # get mouse position for orientation point for zooming
      mousePosX = e.pageX
      # zoom in
      if e.wheelDeltaY > 0
        @zoom 1.25, mousePosX
      # zoom out
      else
        @zoom 0.8, mousePosX###

  _updateYearMarkers: ->

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

    # get position and year of element left to the now marker
    year = @_nowDate.getFullYear() - YEAR_INTERVALS[@_interval]
    xPos = @_dateToPosition(@_yearToDate(year))

    # create all year makers on the left side
    # between screen border and nowmarker
    # put all year marker in a doubly linked list
    until xPos < 0
      newYearMarker = new HG.YearMarker(year, xPos, @_tlDiv, YEAR_MARKER_WIDTH)
      @_yearMarkers.addLast(newYearMarker)

      # set x position and year of next year marker
      year -= YEAR_INTERVALS[@_interval]
      xPos = @_dateToPosition(@_yearToDate(year))

  _moveYearMarkers: (dist) ->
    console.log "yearmakers on timeline: " + @_yearMarkers.getLength() + "\nmove with distance: " + dist
    i = 0
    while i < @_yearMarkers.getLength()

      # get year marker from list
      # and set its new position, calculated with distance
      newPosX = @_yearMarkers.get(i).nodeData.getPos() + dist
      @_yearMarkers.get(i).nodeData.setPos newPosX
      i++

  _dateToPosition: (date) ->

    # fish eye factor controls the distortion of the view
    # for @_fishEyeFactor == 0 the timeline is linear
    # else is the (xPos^2)/fishEyeFactor
    if @_fishEyeFactor == 0
      yearDiff = (date.getFullYear() - @_nowDate.getFullYear()) / YEAR_INTERVALS[@_interval]
      xPos = (yearDiff * YEAR_MARKER_WIDTH) + (@_tlWidth / 2)
    else
      xPos = 0
      #todo: distortion view
    xPos

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date

  # ============================================================================
  # text selection magic - bääääm!
  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true

