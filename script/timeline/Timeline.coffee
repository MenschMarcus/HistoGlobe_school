window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

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
    @_zoomLevel  = 2

    # create doubly linked list for year markers
    @_yearMarkers   = new HG.YearMarkerList()

    # create first now marker and get width of year markers from it
    # add now marker to doubly linked list
    @_nowMarker = new HG.YearMarker(@_yearToDate(nowYear), 0, @_tlDiv)
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
    @_nowMarkerBox = new HG.NowMarker(@_tlDiv, nowMarkerDiv, @)
    @_nowMarkerBox.setNowDate(@_nowMarker.getDate())

    # set animation for timeline play
    @_play = false
    @_speed = 0 
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

      console.log "Timeline: \n     ZoomLevel: " + @_zoomLevel
      
      # execute changed year interval
      # if interval was changed
      if zoom        
        @_zoomLevel = @_roundNumber(@_zoomLevel, 1)
        @_clearYearMarkers()
        @_updateYearMarkerPositions(false)      
        @_loadYearMarkers(true)

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
      temp  = (@_yearMarkers.get(i).nodeData.getDate().getFullYear()) % @_timeInterval(@_zoomLevel, false)
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
      if @_timeInterval(@_zoomLevel, false) < (@_yearMarkers.get(i + 1).nodeData.getDate().getFullYear() - @_yearMarkers.get(i).nodeData.getDate().getFullYear())
        dateBetween = @_yearToDate (@_yearMarkers.get(i).nodeData.getDate().getFullYear() + @_timeInterval(@_zoomLevel, false))
        newYearMarker = new HG.YearMarker(dateBetween, @_dateToPosition(dateBetween), @_tlDiv)
        newYearMarker.setWidth @_yearMarkerWidth
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
        dateLeft = @_yearToDate(dateLeft.getFullYear() - @_timeInterval(@_zoomLevel, false))
      xPosLeft = @_dateToPosition(dateLeft)

      # round date first, so only year markers fit on scale will be shown
      dateRight = @_roundDate @_nowMarker.getDate()
      until dateRight > @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getDate()
        dateRight = @_yearToDate(dateRight.getFullYear() + @_timeInterval(@_zoomLevel, false))
      xPosRight = @_dateToPosition(dateRight)

      # is new year marker needed?
      if xPosLeft > 0 - @_yearMarkerWidth and dateLeft.getFullYear() >= @_minDate.getFullYear()
        drawn = true
        newYearMarker = new HG.YearMarker(dateLeft, @_dateToPosition(dateLeft), @_tlDiv)
        newYearMarker.setWidth @_yearMarkerWidth
        @_yearMarkers.addFirst(newYearMarker)

      # is new year marker needed?
      if xPosRight < @_tlWidth + @_yearMarkerWidth and dateRight.getFullYear() <= @_maxDate.getFullYear()
        drawn = true
        newYearMarker = new HG.YearMarker(dateRight, @_dateToPosition(dateRight), @_tlDiv)
        newYearMarker.setWidth @_yearMarkerWidth
        @_yearMarkers.addLast(newYearMarker)

    # are there gaps in the timeline to fill?
    if fillGaps
      @_fillGaps()

    # highlight some year markers with a round date 
    # for example all 5,10,50,100 years
    @_highlightIntervals()

  _timeInterval: (index, exact) ->
    yearIntervals = [1,5,10,50,100,500,1000,5000,10000,50000,100000,500000,1000000,5000000]
    if exact and index > 0
      i = 0
      while index > i
        i++
      next = i
      prev = i - 1
      dis = index - prev
      res = yearIntervals[prev] + (yearIntervals[next] - yearIntervals[prev]) * dis
    else
      # static way to get year intervals      
      res = yearIntervals[Math.round(index)]  
    res

      # Calclate years from index (index >= 0) for e function
      #res = Math.round(Math.pow(Math.E, index))

      # TODO: calculate via interpolated time scale

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
    @_nowMarkerBox.setNowDate(@_nowMarker.getDate())

  _dateToPosition: (date) ->

    # old version to show year marker on linear scale
    yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / @_timeInterval(@_zoomLevel, true)    

    # calculate position of year markers with exact zoom level
    # on logarithmic timescale
    #yearDiff = (date.getFullYear() - @_nowMarker.getDate().getFullYear()) / Math.round(Math.pow(Math.E, @_zoomLevel))
    xPos = (yearDiff * @_yearMarkerWidth + (@_nowMarker.getPos()))

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date

  _roundDate : (date) ->
    @_yearToDate(Math.round(date.getFullYear() / @_timeInterval(@_zoomLevel, false)) * @_timeInterval(@_zoomLevel, false))

  _roundNumber : (number, n) ->
    factor = Math.pow(10,n)
    Math.round(number * factor) / factor

  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true   

  # functions to move timeline periodic
  _animTimeline: =>
    if @_play
      if((@_speed >= 0 and @_yearMarkers.get(0).nodeData.getPos() + @_yearMarkerWidth / 2 < @_tlWidth / 2) or (@_speed < 0 and @_yearMarkers.get(@_yearMarkers.getLength() - 1).nodeData.getPos() + @_yearMarkerWidth / 2 > @_tlWidth / 2))
        @_nowMarker.setPos @_speed + @_nowMarker.getPos()
        @_updateYearMarkerPositions(false)
        @_updateNowMarker()
        @_loadYearMarkers(false)
      else
        @_nowMarkerBox.animationSwitch()


  stopTimeline: ->
    @_play = false

  playTimeline: ->
    @_play = true

  setSpeed: (speed) ->
    @_speed = speed

  getPlayStatus: ->
    @_play


