window.HG ?= {}

class HG.DateMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  MONTH_NAMES = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

  #   --------------------------------------------------------------------------
  constructor: (date, timeline) ->
    @_date = date
    @_timeline = timeline
    @_div = null
    @updateView(true)

  #   --------------------------------------------------------------------------
  updateView: (show) ->
    if show
      if !@_div?
        @_div = document.createElement("div")
        @_div.id = "tl_year_" + @_date.getFullYear()
        @_div.className = "tl_datemarker"
        @_div.innerHTML = @_date.getFullYear()
        @_div.style.left = @_timeline.dateToPosition(@_date) + "px"
        @_div.style.display = "none"
        @_timeline.getCanvas().appendChild @_div
        $(@_div).fadeIn(200)
      else
        @_div.style.left = @_timeline.dateToPosition(@_date) + "px"
    else
      if @_div?
        $(@_div).fadeOut(200, `function() { $(this).remove(); }`)

  #   --------------------------------------------------------------------------
  getDate: ->
    @_date
  getDiv: ->
    @_div
  #   --------------------------------------------------------------------------
  setDate: (date) ->
    @_date = date

  #   --------------------------------------------------------------------------
  daysInMonth: (month,year) ->
    new Date(year, month + 1, 0).getDate()
