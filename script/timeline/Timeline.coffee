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
      @_disableTextSelection e

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

        # This function adds some motion after timeline was scrolled
        # the motion is calculated by the speed of scrolling (px/sec)
        # and a value that specifies how fast the motion is slowing down
        @_scrollMotionBlur(2, 50)   

        @_lastMousePosX = e.pageX
        @_enableTextSelection()

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
      
      @_clearYearMarkers()
      @_updateYearMarkerPositions()      
      @_loadYearMarkers()      
      #@_fillGaps()

  # fade out movement of year markers after scrolling
  # calculate fade out by speed of scrolling and slowDownValue
  # Movement: at first change position of NowMarker 
  #           then call "@_updateYearMarkerPositions"
  #           this updates all positions of year markers in relation to the NowMarker
  @_scrollMotionBlur: (slowDownValue, scrollSpeed) ->

    #TODO: repeat this several times and determine the new nowmarker position
    # the value of scrollSpeed can be positive (motion to right) or negative (motion to left)
    # the slowDownValue is fixed and can be given by your choice
    # look for the javascript function "setTimeOut" with this you can repeat a function in a given time interval
    # much fun :)
    @_nowMarker.setPos @_nowMarker.getPos()
    @_updateYearMarkerPositions()

  _updateYearMarkerPositions: ->
    i = 0
    while i < @_yearMarkers.getLength()
      date = @_yearMarkers.get(i).nodeData.getDate()
      @_yearMarkers.get(i).nodeData.setPos @_dateToPosition date
      i++

  _clearYearMarkers: ->
    i = 0
    while i < @_yearMarkers.getLength()
      temp = (@_nowMarker.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear()) % YEAR_INTERVALS[@_interval]
      if temp != 0
        @_yearMarkers.get(i).nodeData.destroy()
        @_yearMarkers.remove(i)
      else
        i++

  ###_fillGaps: ->
    i = 0
    while i < @_yearMarkers.getLength() - 1
      dateBetween = @_yearToDate (@_yearMarkers.get(i).nodeData.getDate().getFullYear() + YEAR_INTERVALS[@_interval])
      if dateBetween.getFullYear() != @_yearMarkers.get(i + 1).nodeData.getDate().getFullYear()
        newYearMarker = new HG.YearMarker(dateBetween, @_dateToPosition(dateBetween), @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.insert(i, newYearMarker)
      i++    ###  

  _loadYearMarkers: ->
    
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
      
      if xPosLeft > 0
        drawn = true
        newYearMarker = new HG.YearMarker(dateLeft, xPosLeft, @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.addFirst(newYearMarker)

      if xPosRight < @_tlWidth
        drawn = true
        newYearMarker = new HG.YearMarker(dateRight, xPosRight, @_tlDiv, YEAR_MARKER_WIDTH)
        @_yearMarkers.addLast(newYearMarker)    

  _updateNowMarker: (dist) ->
    smallestDis = null
    i = 0
    nId = 0
    while i < @_yearMarkers.getLength()
      dis = @_tlWidth / 2 - (@_yearMarkers.get(i).nodeData.getPos() + YEAR_MARKER_WIDTH / 2)
      dis *= -1 if dis < 0
      #temp = (@_nowMarker.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear()) % YEAR_INTERVALS[@_interval]
      if (smallestDis is null or dis < smallestDis)# and temp == 0
        smallestDis = dis
        nId = i
      i++
    @_nowMarker = @_yearMarkers.get(nId).nodeData
    console.log "Timeline:\n     Current now date: " + @_nowMarker.getDate().getFullYear() + "\n     Time interval: " + YEAR_INTERVALS[@_interval]

  _dateToPosition: (date) ->

    yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / YEAR_INTERVALS[@_interval]
    xPos = (yearDiff * YEAR_MARKER_WIDTH) + (@_nowMarker.getPos())

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

  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true

