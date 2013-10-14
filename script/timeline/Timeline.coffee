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
    @_zoomLevel = 7

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
    @_yearMarkers = document.createElement "div"
    @_yearMarkers.id = "yearMarkers"
    @_tlScroller.appendChild @_yearMarkers

    # init scroller with year markers
    @_drawScroller()

    # event handling
    @_downOnTimeline = false
    @_lastPosX = 0

    @_tlDiv.onmousedown = (e) =>
      @_downOnTimeline = true
      @_lastPosX = e.pageX
      @_disableTextSelection()

    document.body.onmousemove = (e) =>
      if @_downOnTimeline   # catch any mouse event to allow scrolling of timeline even if mouse is not inside timeline
        posX = e.pageX
        moveDist = @_lastPosX - posX
        @_moveScroller moveDist
        @_lastPosX = posX

    document.body.onmouseup = (e) =>
      if @_downOnTimeline
        @_nowDate = @_posToDate @_tlWidth/2
        @_drawScroller()
        @_downOnTimeline = false  # catch any mouse up event in UI to stop dragging
      @_lastPosX = e.pageX
      @_enableTextSelection()

  # ============================================================================
  setZoomLevel : (factor) ->
    @_zoomLevel *= factor
    @_zoomLevel = Math.min @_zoomLevel, @_maxZoom
    @_zoomLevel = Math.max @_zoomLevel, @_minZoom


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

  _drawScroller : ->
    # clear scroller recursively
    @_yearMarkers.removeChild @_yearMarkers.firstChild while @_yearMarkers.firstChild

    # get now year
    # nowYear = @_posToDate @_tlWidth/2
    nowYear = @_nowDate  # preliminary, replace by real nowDate from nowMarker

    # calculate interval at which year markers are drawn
    # difference between two years on timeline at current zoom level [px]
    yearDiff = @_zoomLevel * YEAR_DIST
    # increment interval until distance between two year markers is greater than minimum distance between two markers
    intervalIt = 0
    intervalIt++ while (yearDiff < (MIN_DIST / YEAR_INTERVALS[intervalIt]))
    yearInterval = YEAR_INTERVALS[intervalIt]

    # draw first year to the right that is in year interval
    refYear = @_dateToYear nowYear
    refYear++ while refYear % yearInterval != 0
    refPos = @_dateToPos @_yearToDate refYear
    @_appendYearMarker refYear

    # append all year marker to the right and to the left until 2x tlWidth
    yearLeft = yearRight = refYear

    limitRight  = @_dateToYear @_getEarlierDate  @_maxDate, @_posToDate 2*@_tlWidth  # date at right border of scroller or maximum date
    while yearRight <  limitRight
      yearRight += yearInterval
      @_appendYearMarker yearRight

    limitLeft   = @_dateToYear @_getLaterDate    @_minDate, @_posToDate -@_tlWidth   # date at left  border of scroller or minimum date
    while yearLeft >  limitLeft
      yearLeft -= yearInterval
      @_appendYearMarker yearLeft

  _appendYearMarker : (year) ->
    yearMarkerDiv = document.createElement "div"
    yearMarkerDiv.id = "year" + year
    yearMarkerDiv.className = "yearMarker"
    # position = position of year starting from zero
    #          + moving to center of timeline (width of timeline)
    position = (@_dateToPos @_yearToDate year) + @_tlWidth
    yearMarkerDiv.style.left = position + "px"
    yearMarkerDiv.innerHTML = '<p>'+year+'</p>'
    @_yearMarkers.appendChild yearMarkerDiv

  _moveScroller : (pix) ->
    @_tlDiv.scrollLeft += pix

  # text selection magic - bääääm!
  _disableTextSelection : (e) ->
    return false

  _enableTextSelection : () ->
    return true

  # auxiliary functions
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
