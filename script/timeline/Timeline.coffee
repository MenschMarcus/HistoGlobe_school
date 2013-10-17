#include Mixin.coffee
#include CallbackContainer.coffee

window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (minDate, maxDate, minZoom, maxZoom, timelineDiv) ->
    @_minDate = @_yearToDate minDate
    @_maxDate = @_yearToDate maxDate
    @_minZoom = minZoom
    @_maxZoom = maxZoom
    @_tlDiv = timelineDiv
    @_tlWidth = @_tlDiv.offsetWidth
    @_zoomLevel = 1

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onPeriodChanged"
    @addCallback "onZoomLevelChanged"

    # @_nowMarker = new NowMarker
    @_nowDate = @_yearToDate 1888 # preliminary, replace by real nowDate from nowMarker

    # create timeline scroller (size: 3 times timeline width)
    @_tlScroller = document.createElement "div"
    @_tlScroller.id = "tlScroller"
    @_tlScroller.style.width = (@_tlWidth*3) + "px"
    timelineDiv.appendChild @_tlScroller

    # move scroller to center of timeline
    # (so that it sticks out both directions by width of timeline)
    @_moveScroller @_tlWidth

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

    document.body.onmousemove = (e) =>
      if @_downOnTimeline   # catch any mouse event to allow scrolling of timeline even if mouse is not inside timeline
        mousePosX = e.pageX
        moveDist = @_lastMousePosX - mousePosX
        @_moveScroller moveDist
        @_lastMousePosX = mousePosX

    document.body.onmouseup = (e) =>
      if @_downOnTimeline
        @_nowDate = @_posToDate @_tlWidth/2
        @_drawScroller()
        @_downOnTimeline = false  # catch any mouse up event in UI to stop dragging
      @_lastMousePosX = e.pageX
      @_enableTextSelection()

    # zooming
    @_tlDiv.onmousewheel = (e) =>
      # zoom in
      if e.wheelDeltaY > 0
        @setZoomLevel 2
      # zoom out
      else
        @setZoomLevel 0.5


  # ============================================================================
  setZoomLevel : (factor) ->
    @_zoomLevel *= factor
    @_zoomLevel = Math.min @_zoomLevel, @_maxZoom
    @_zoomLevel = Math.max @_zoomLevel, @_minZoom
    console.log @_zoomLevel
    @_drawScroller

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

    # calculate interval at which year markers are drawn
    # difference between two years on timeline at current zoom level [px]
    yearDiff = @_zoomLevel * YEAR_DIST
    # increment interval until distance between two year markers is greater than minimum distance between two markers
    intervalIt = 0
    intervalIt++ while (yearDiff < (MIN_DIST / YEAR_INTERVALS[intervalIt]))
    yearInterval = YEAR_INTERVALS[intervalIt]

    # get now year TODO
    # nowYear = @_posToDate @_tlWidth/2
    nowYear = @_nowDate  # preliminary, replace by real nowDate from nowMarker

    # get position and year or first year marker on the left
    leftYear = @_dateToYear @_posToDate -@_tlWidth
    leftYear++ while leftYear % yearInterval != 0
    leftPos = @_dateToPos @_yearToDate leftYear

    #draw first year to the right that is in year interval
    @_addYearToScroller leftYear

    limitRight  = @_dateToYear @_getEarlierDate  @_maxDate, @_posToDate 2*@_tlWidth  # date at right border of scroller or maximum date
    while leftYear < limitRight
      leftYear += yearInterval
      @_addYearToScroller leftYear

    @_updateScroller()

  # ============================================================================
  _addYearToScroller : (year) ->
    # create year marker
    # position = position of year starting from zero
    #          + moving to center of timeline (width of timeline)
    pos = (@_dateToPos @_yearToDate year) + @_tlWidth
    yearMarker = new HG.YearMarker(year, pos, @_yearMarkersDiv)

    # add object to temporary list of to be inserted year markers
    @_yearMarkersToInsert.push(yearMarker)

  # ============================================================================
  _updateScroller : () ->
    # exception handling: if scroller is empty, just set to be inserted yearMarkers as new yearMarkers
    if @_yearMarkers.length < 1
      @_yearMarkers = @_yearMarkersToInsert

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
  _moveScroller : (pix) ->
    @_tlDiv.scrollLeft += pix

  # ============================================================================
  # text selection magic - bääääm!
  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true

  # ============================================================================
  # auxiliary functions
  # ============================================================================
  _posToDate : (pos) ->
    # get now date and its position
    # nowDate = @_nowMarker.getNowDate()
    nowDate = @_nowDate
    nowPos = @_tlWidth / 2
    # distance to now position [px]
    pxDiff = pos - nowPos
    # distance between two px [ms]
    pxDist = 1 / (MS_WIDTH * @_zoomLevel)
    # very intuitive linear function that is not so intuitive anymore
    date = @_addDates(new Date(pxDiff*pxDist), nowDate)

  _dateToPos : (date) ->
    # get now date and its position
    # nowDate = @_nowMarker.getNowDate
    nowPos = @_tlWidth / 2
    # difference between date and now date [ms]
    msDiff = date.getTime() - @_nowDate.getTime()
    # distance between two ms [px]
    msDist = MS_WIDTH * @_zoomLevel
    # very intuitive linear function
    pos = msDiff * msDist + nowPos

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date

  _dateToYear : (date) ->
    year = date.getFullYear()
    year

  _addDates : (date1, date2) ->
    ms1 = date1.getTime()
    ms2 = date2.getTime()
    date = new Date (ms1+ms2)
    date

  _subtractDates : (date1, date2) ->
    ms1 = date1.getTime()
    ms2 = date2.getTime()
    date = new Date (ms1-ms2)
    date

  _getEarlierDate : (date1, date2) ->
    diff = date1.getTime()-date2.getTime()
    if diff < 0 then date1 else date2

  _getLaterDate : (date1, date2) ->
    diff = date1.getTime()-date2.getTime()
    if diff > 0 then date1 else date2
