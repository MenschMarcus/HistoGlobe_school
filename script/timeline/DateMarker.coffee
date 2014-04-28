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

  MONTH_NAMES = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

  #   --------------------------------------------------------------------------
  constructor: (date, timeline) ->
    @_date = date
    @_timeline = timeline

    #   ------------------------------------------------------------------------
    @_divs = [ null, null, null ]

    #   ------------------------------------------------------------------------
    @updateView(true)

  #   --------------------------------------------------------------------------
  #   create and update views of datemarker in ui
  updateView: (show) ->
    if show
      if !@_divs[0]?
        @_divs[0] = document.createElement("div")
        @_divs[0].id = "tl_year_" + @_date.getFullYear()
        @_divs[0].className = "tl_marker"
        @_divs[0].innerHTML = @_date.getFullYear()
        @_divs[0].style.left = @_timeline.dateToPosition(@_date) + "px"
        @_divs[0].style.display = "none"
        #@_divs[0].style.fontSize = @_filterView()[0] + "%"
        @_timeline.getUIElements().yearRow.appendChild @_divs[0]
        $(@_divs[0]).fadeIn(200)
      else
        @_divs[0].style.left = @_timeline.dateToPosition(@_date) + "px"
        #@_divs[0].style.fontSize = @_filterView()[0] + "%"
    else
      if @_divs[0]?
        $(@_divs[0]).fadeOut(200, `function() { $(this).remove(); }`);

  #   --------------------------------------------------------------------------
  #   get array of interval between datemarkers to show
  _filterView: ->
    sizes = [0, 0, 0]
    max = @_timeline.getMaxIntervalIndex()

    #   font size of year in procent
    i = 1
    while max >= 0 && sizes[0] == 0
      if @_date.getFullYear() % @_timeline.millisToYear(@_timeline.timeInterval(max)) == 0
        sizes[0] = 100 / i
      else
        max--
        i++

    #   size of months in procent
    sizes[1] = 100 / (max + 1)

    sizes

  #   --------------------------------------------------------------------------
  getDate: ->
    @_date

  #   --------------------------------------------------------------------------
  setDate: (date) ->
    @_date = date

  #   --------------------------------------------------------------------------
  daysInMonth: (month,year) ->
    new Date(year, month + 1, 0).getDate()
