#include Mixin.coffee
#include CallbackContainer.coffee

window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (nowDate, minDate, maxDate, minZoom, maxZoom, timelineDiv) ->
    @_nowDate = @_yearToDate nowDate
    @_minDate = @_yearToDate minDate
    @_maxDate = @_yearToDate maxDate
    @_minZoom = minZoom
    @_maxZoom = maxZoom
    @_tlDiv   = timelineDiv
    @_body = document.getElementById("home")
    @_tlWidth = @_tlDiv.offsetWidth
    @_zoomLevel = 1

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onPeriodChanged"
    @addCallback "onZoomLevelChanged"

    # @_nowMarker = new NowMarker

    # create timeline scroller (size: 3 x timeline width)
    @_tlScroller = document.createElement "div"
    @_tlScroller.id = "tlScroller"
    @_tlScroller.style.width = (@_tlWidth*3) + "px"
    timelineDiv.appendChild @_tlScroller

    # reference date and position (on scroller!) for drawing the year markers -> initially now date
    @_refDate = @_nowDate.getTime()   # [ms]
    @_refPos = @_tlWidth*1.5          # [px]

    # move scroller to center of timeline
    # (so that it sticks out both directions by width of timeline)
    @_tlDiv.scrollLeft += @_tlWidth

    # create container for year markers
    @_yearMarkers = new Array()
    @_yearMarkersToInsert = new Array()
    @_yearMarkersDiv = document.createElement "div"
    @_yearMarkersDiv.id = "yearMarkers"
    @_tlScroller.appendChild @_yearMarkersDiv

    # init scroller with year markers
    @_drawScroller()

    # ============================================================================
    # event handling
    @_downOnTimeline = false
    @_lastMousePosX = 0

    # dragging
    @_tlDiv.onmousedown = (e) =>
      @_downOnTimeline = true
      @_lastMousePosX = e.pageX
      @_disableTextSelection()
      # console.log e.pageX + " date: " + @_dateToYear @_posToDate e.pageX

    @_body.onmousemove = (e) =>
      if @_downOnTimeline   # catch any mouse event to allow scrolling of timeline even if mouse is not inside timeline
        mousePosX = e.pageX
        moveDist = @_lastMousePosX - mousePosX
        @_moveScroller moveDist
        @_lastMousePosX = mousePosX

    @_body.onmouseup = (e) =>
      if @_downOnTimeline
        @_updateScroller()
        @_downOnTimeline = false  # catch any mouse up event in UI to stop dragging
      @_lastMousePosX = e.pageX
      @_enableTextSelection()

    # zooming
    @_tlDiv.onmousewheel = (e) =>
      # prevent scrolling of map
      e.preventDefault()
      # zoom in
      if e.wheelDeltaY > 0
        @zoom 1.25
      # zoom out
      else
        @zoom 0.8


  # ============================================================================
  zoom : (factor) ->
    @_zoomLevel *= factor
    @_zoomLevel = Math.min @_zoomLevel, @_maxZoom
    @_zoomLevel = Math.max @_zoomLevel, @_minZoom
    # console.log @_zoomLevel

    # chek if new year interval
    # console.log @_getYearInterval()

  #@notifyAll "onPeriodChanged", periodStart, periodEnd


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  # distance between two years on timeline at zoom level 1 [px]
  YEAR_DIST = 10
  # distance between two milliseconds on timeline [px]
  MS_WIDTH = 0.000000000317097919837646 # TODO: can I calculate that ?!?
  # interval at which year markers are drawn [year]
  YEAR_INTERVALS = [1/12,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]
  # minimum distance between two year markers on timeline [px]
  MIN_DIST = 50


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  _drawScroller : () ->
    # clear scroller recursively
    @_yearMarkersDiv.removeChild @_yearMarkersDiv.firstChild while @_yearMarkersDiv.firstChild

    # calculate interval at which year markers are drawn [px]
    yearInterval = @_getYearInterval()

    # get position and year of first year marker on the left
    leftYear = @_dateToYear @_posToDate -@_tlWidth
    leftYear++ while leftYear % yearInterval != 0   # increment leftYear until it is in yearInterval
    leftPos = @_dateToPos @_yearToDate leftYear

    # draw first year to the right that is in year interval
    @_addYearToScroller leftYear

    # date at right border of scroller or maximum date
    limitRight = @_dateToYear @_getEarlierDate @_maxDate, @_posToDate 2*@_tlWidth
    while leftYear < limitRight
      leftYear += yearInterval
      @_addYearToScroller leftYear

    # initally draw all year markers 
    @_updateYearMarkers()

  # ============================================================================
  _getYearInterval : () ->
    yearDiff = @_zoomLevel * YEAR_DIST
      # increment interval until distance between two year markers is greater than minimum distance between two markers
    intervalIt = 0
    intervalIt++ while (yearDiff < (MIN_DIST / YEAR_INTERVALS[intervalIt]))
    yearInterval = YEAR_INTERVALS[intervalIt]

  # ============================================================================
  _addYearToScroller : (year) ->
    # create year marker
    # position = position of year starting from zero
    #          + moving to center of timeline (width of timeline)
    pos = (@_dateToPos @_yearToDate year)
    yearMarker = new HG.YearMarker(year, pos, @_yearMarkersDiv)

    # add object to temporary list of to be inserted year markers
    @_yearMarkersToInsert.push(yearMarker)

  # ============================================================================
  _moveScroller : (pix) ->
    @_tlDiv.scrollLeft += pix
    # update nowDate (to be replaced later...)
    @_nowDate = @_dateToYear @_posToDate @_tlWidth*0.5


  # ============================================================================
  _updateScroller : () ->
    # get area of redraw
    newArea = @_tlDiv.scrollLeft - @_tlWidth
    # get number of year markers that fit into area
    yearInterval = @_getYearInterval()
    numNewMarkers = Math.floor newArea/yearInterval
    # add year markers at front resp. back and remove same amount of year markers at back resp. front
    i = 0
    # append to front
    if newArea < 0
      firstYear = @_yearMarkers[0].getYear()-numNewMarkers*yearInterval
      @_addYearToScroller firstYear
      while i < numNewMarkers
        firstYear += yearInterval
        @_addYearToScroller firstYear
        i++
    # append to back
    else
      firstYear = @_yearMarkers[@_yearMarkers.length-1].getYear()+numNewMarkers*yearInterval
      @_addYearToScroller firstYear
      while i < numNewMarkers
        firstYear += yearInterval
        @_addYearToScroller firstYear
        i++


  # ====================================================
  _updateYearMarkers : () ->
    # exception handling: if scroller is empty, just set to be inserted yearMarkers as new yearMarkers
    if @_yearMarkers.length < 1
      @_yearMarkers = @_yearMarkersToInsert.slice()  # deep copy

    # new year markers at beginning of scroller
    else if @_yearMarkers[0].getYear() > @_yearMarkersToInsert[0].getYear()
      # delete yearMarkers at end
      @_yearMarkers.splice @_yearMarkers.length-@_yearMarkersToInsert.length, @_yearMarkersToInsert.length
      # add yearMarkers to front = insert new array into final array
      @_yearMarkers.splice.apply(@_yearMarkers, [0, 0].concat(@_yearMarkersToInsert));

    # new year markers at end of scroller
    else 
      # delete yearMarkers at front
      @_yearMarkers.splice 0, @_yearMarkersToInsert.length
      # add yearMarkers to back
      @_yearMarkers.splice.apply(@_yearMarkers, [@_yearMarkers.length, 0].concat(@_yearMarkersToInsert));
      
    # clear array of to be inserted year markers
    @_yearMarkersToInsert.length = 0


  # ============================================================================
  # text selection magic - bääääm!
  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true

  # ============================================================================
  # auxiliary functions
  # ============================================================================
  _posToDate : (inPos) ->   # in: position on timeline, not on scroller!
    # distance of click position and now position
    pxDiff = inPos+@_tlDiv.scrollLeft - @_refPos                   # [px-px = px]
    # time distance between two px
    pxDist = 1 / (MS_WIDTH * @_zoomLevel)       # [ms/px]
    # very intuitive linear function that is not so intuitive anymore
    outDate = @_refDate + pxDist*pxDiff         # [ms = ms + ms/px*px]
    new Date(outDate)

  _dateToPos : (inDate) -> # out: position on timeline, not on scroller!
    # difference between date and now date
    msDiff = inDate.getTime() - @_refDate   # [ms]
    # distance between two ms
    msDist = MS_WIDTH * @_zoomLevel         # [px/ms]
    # very intuitive linear function
    outPos = msDiff*msDist + @_refPos       # [px = ms*px/ms + px]

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date

  _dateToYear : (date) ->
    date.getFullYear()

  _addDates : (date1, date2) ->
    ms1 = date1.getTime()
    ms2 = date2.getTime()
    new Date (ms1+ms2)

  _subtractDates : (date1, date2) ->
    ms1 = date1.getTime()
    ms2 = date2.getTime()
    new Date (ms1-ms2)

  _getEarlierDate : (date1, date2) ->
    diff = date1.getTime()-date2.getTime()
    if diff < 0 then date1 else date2

  _getLaterDate : (date1, date2) ->
    diff = date1.getTime()-date2.getTime()
    if diff > 0 then date1 else date2
