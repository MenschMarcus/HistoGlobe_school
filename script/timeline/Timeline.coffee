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
    @_yearInterval = 4

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onPeriodChanged"
    @addCallback "onZoomLevelChanged"

    # @_nowMarker = new NowMarker
    @_nowDate = @_yearToDate 1980 # preliminary, replace by real nowDate from nowMarker

    # create timeline scroller (maximum size)
    @_tlScroller = document.createElement "div"
    @_tlScroller.id = "tlScroller"
    @_tlScroller.style.width = (@_maxDate.getMilliseconds()-@_minDate.getMilliseconds())*(MS_WIDTH*@_zoomLevel)
    timelineDiv.appendChild @_tlScroller

    # create container for year markers
    @_yearMarkers = document.createElement "div"
    @_yearMarkers.id = "yearMarkers"
    @_tlScroller.appendChild @_yearMarkers

    console.log @_tlScroller

    # init scroller with year markers
    @_drawScroller()

    # event handling
    @_downOnTimeline = false
    @_lastPosX = 0

    @_tlDiv.onmousedown = (e) ->
      @_downOnTimeline = true

    @_tlDiv.onmouseup = (e) ->
      @_downOnTimeline = false

    @_tlDiv.onmousemove = (e) ->
      if @_downOnTimeline
        posX = e.pageX
        moveDist = @_lastPosX - posX
        console.log posX + " -> " + moveDist + @_tlScroller
        # document.getElementById('tlScroller').offsetLeft = posX
        # TODO: drag the scroller! but how?!?
        @_lastPosX = posX

  # ============================================================================
  setZoomLevel : (factor) ->
    @_zoomLevel *= factor
    @_zoomLevel = Math.min @_zoomLevel, @_maxZoom
    @_zoomLevel = Math.max @_zoomLevel, @_minZoom


  #@notifyAll "onPeriodChanged", periodStart, periodEnd


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  _drawScroller : ->
    # get now year
    # nowYear = @_posToDate @_tlWidth/2
    nowYear = @_nowDate  # preliminary, replace by real nowDate from nowMarker

    # find first year to the right that is in year interval
    yearInterval = YEAR_INTERVALS[@_yearInterval]
    refYear = @_dateToYear nowYear
    refYear++ while refYear % yearInterval is not 0
    refPos = @_dateToPos @_yearToDate refYear

    # append all year marker to the right and to the left until 2x tlWidth
    posRight = refPos
    yearLeft = refYear
    yearRight = refYear
    @_appendYearMarker yearLeft
    while posRight <= 2*@_tlWidth
      yearLeft -= yearInterval
      @_appendYearMarker yearLeft if yearLeft >= @_dateToYear @_minDate
      yearRight += yearInterval
      @_appendYearMarker yearRight if yearRight <= @_dateToYear @_maxDate
      posRight = @_dateToPos @_yearToDate yearRight


  _appendYearMarker : (year) ->
    yearMarkerDiv = document.createElement "div"
    yearMarkerDiv.id = "year" + year
    yearMarkerDiv.className = "yearMarker"
    position = @_dateToPos @_yearToDate year
    yearMarkerDiv.style.left = position + "px"
    yearMarkerDiv.innerHTML = '<p>'+year+'</p>'
    @_yearMarkers.appendChild yearMarkerDiv

  _posToDate : (pos) ->
    # get now date and its position
    # nowDate = @_nowMarker.getNowDate()
    nowDate = @_nowDate
    nowPos = @_tlWidth / 2
    # distance to now position [px]
    pxDiff = pos - nowPos
    # distance between two px [ms]
    pxDist = 1 / (MS_WIDTH * @_zoomLevel)
    # very intuitive linear function
    date = new Date(pxDiff*pxDist) + nowDate

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

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  MS_WIDTH = 0.000000000317097919837646   # distance of 10 px between two years
  YEAR_INTERVALS = [1/12,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]
