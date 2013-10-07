#include Mixin.coffee
#include CallbackContainer.coffee

window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (minDate, maxDate, minZoom, maxZoom, timelineDiv) ->

    @_minDate = minDate
    @_maxDate = maxDate
    @_minZoom = minZoom
    @_maxZoom = maxZoom
    @_zoomLevel = 1
    @_yearInterval = 1
    @_tlWidth = timelineDiv.getOffsetWidth

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onPeriodChanged"
    @addCallback "onZoomLevelChanged"

    @_nowMarker = new NowMarker

    # create timeline scroller (maximum size)
    @_tlScroller = document.createElement "div"
    @_tlScroller.id = "hlScroller"
    @_tlScroller.style.width = (maxDate.getMilliseconds()-minDate.getMilliseconds())*(MS_WIDTH*@_zoomLevel)



    # create container for year markers
    @_yearMarkers = document.createElement "div"
    @_yearMarkers.id = "yearMarkers"
    timelineDiv.appendChild @_yearMarkers

  # ============================================================================
  setZoomLevel : (factor) ->
    @_zoomLevel *= factor
    @_zoomLevel = Math.min @_zoomLevel, @_maxZoom
    @_zoomLevel = Math.max @_zoomLevel, @_minZoom


  #@notifyAll "onPeriodChanged", periodStart, periodEnd


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  drawScroller : ->
    # get now year
    nowYear = posToDate @_tlWidth / 2

    # find first year to the right that is in year interval
    yearInterval = YEAR_INTERVALS[@_yearInterval]
    refYear = nowYear.getFullYear
    refYear++ while refYear % yearInterval is not 0
    refPos = dateToPos refYear

    # append all year marker to the right and to the left until 2x tlWidth
    posRight = refPos
    yearLeft = yearRight = refYear
    while posRight <= 2*@_tlWidth
      yearLeft -= yearInterval
      appendYearMarker yearLeft
      yearRight += yearInterval
      appendYearMarker yearRight
      posRight = dateToPos yearRight

  appendYearMarker : (year) ->
    yearMarkerDiv = document.createElement "div"
    yearMarkerDiv.id = "year" + year
    yearMarkerDiv.addClass "yearMarker"
    yearMarkerDiv.style.left = dateToPos year
    yearMarkerDiv.innerHTML = '<p>'+year+'</p>'
    @_yearMarkers.appendChild yearMarkerDiv

  posToDate : (pos) ->
    # get now date and its position
    nowDate = @_nowMarker.getNowDate()
    nowPos = @_tlWidth / 2
    # distance to now position [px]
    pxDiff = pos - nowPos
    # distance between two px [ms]
    pxDist = 1 / (MS_WIDTH * @_zoomLevel)
    # very intuitive linear function
    date = new Date(pxDiff*pxDist) + nowDate

  dateToPos : (date) ->
    # get now date and its position
    nowDate = @_nowMarker.getNowDate
    nowPos = @_tlWidth / 2
    # difference between date and now date [ms]
    msDiff = date.getMilliseconds() - nowDate.getMilliseconds()
    # distance between two ms [px]
    msDist = MS_WIDTH * @_zoomLevel
    # very intuitive linear function
    pos = msDiff * msDist + nowPos


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  MS_WIDTH = 0.000000000317097919837646   # distance of 10 px between two years
  YEAR_INTERVALS = [1/12,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]
