window.HG ?= {}

class HG.Timeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (nowYear, minYear, maxYear, timelineDiv) ->

    # CONVERT YEARS TO DATE OBJECTS
    @_nowDate = @_yearToDate nowYear
    @_minDate = @_yearToDate minYear
    @_maxDate = @_yearToDate maxYear

    @_tlDiv   = timelineDiv
    @_tlWidth = @_tlDiv.offsetWidth

    @_fishEyeFactor = 0;

  _dateToPosition: (date) ->

  _yearToDate : (year) ->
    date = new Date(0)
    date.setFullYear year
    date

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  # interval at which year markers are drawn [year]
  YEAR_INTERVALS = [1/12,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000]

  ##############################################################################
  #                             YEAR MARKER DIVS                               #
  ##############################################################################

  class YearMarker

    constructor: (year, pos, parentDiv) ->
      @_year = year
      @_pos = pos
      @_parentDiv = parentDiv

      # create HTML div
      @_yearMarkerDiv = document.createElement "div"
      @_yearMarkerDiv.id = "yearMarker" + @_year
      @_yearMarkerDiv.className = "yearMarker"
      @_yearMarkerDiv.style.left = @_pos + "px"
      @_yearMarkerDiv.innerHTML = @_year

      # add to DOM
      @_parentDiv.appendChild @_yearMarkerDiv

    # ============================================================================
    getYear : () -> @_year
    setYear : (year) -> @_year = year
    setPos: (pos) -> @_pos = pos
    destroy : () -> @_parentDiv.removeChild @_yearMarkerDiv
