window.HG ?= {}

class HG.DateMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   --------------------------------------------------------------------------
  #   D E S C R I P T I O N
  #   each dateMarker has an start and end date
  #   one div for the year
  #   one div for each day
  #   12 divs for the months

  #   --------------------------------------------------------------------------
  constructor: (startDate, endDate, timeline) ->
    @_startDate = startDate
    @_endDate   = endDate
    @_timeline = timeline

    #   ------------------------------------------------------------------------
    @_year =
      div:      document.createElement("div")
      date:     @_startDate
      content:  @_startDate.getFullYear()

    @_year.div.id = "tl_year_" + @_year.date.getFullYear()
    @_year.div.className = "tl_marker"
    @_year.div.innerHTML = @_year.content
    @_year.div.style.left = @_timeline.dateToPosition(@_year.date) + "px"

    @_timeline.getUIElements().yearRow.appendChild @_year.div

  #   --------------------------------------------------------------------------
  getStartDate: ->
    @_startDate

  getEndDate: ->
    @_endDate

  getYear: ->
    @_year

  #   --------------------------------------------------------------------------
  setStartDate: (date) ->
    @_startDate = date

  setEndDate: (date) ->
    @_endDate = date
