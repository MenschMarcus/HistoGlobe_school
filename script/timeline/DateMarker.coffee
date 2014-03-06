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
        @_divs[0].style.fontSize = @_filterView()[0] + "%"
        @_timeline.getUIElements().yearRow.appendChild @_divs[0]
        $(@_divs[0]).fadeIn(400)
      else
        @_divs[0].style.left = @_timeline.dateToPosition(@_date) + "px"
        @_divs[0].style.fontSize = @_filterView()[0] + "%"
    else
      if @_divs[0]?
        $(@_divs[0]).fadeOut(200, `function() { $(this).remove(); }`);
        #$(@_divs[0]).remove()

  #   --------------------------------------------------------------------------
  ###_showYear: ->
    if @_divs[0] == null
      @_divs[0] = document.createElement("div")
      @_divs[0].id = "tl_year_" + @_date.getFullYear()
      @_divs[0].className = "tl_marker"
      @_divs[0].innerHTML = @_date.getFullYear()
      @_divs[0].style.left = @_timeline.dateToPosition(@_date) + "px"
      @_divs[0].style.fontSize = @_filter[0] + "%"
      @_timeline.getUIElements().yearRow.appendChild @_divs[0]

  _hideYear: ->
    if @_divs[0] != null
      console.log "hide"
      @_divs[0].parentElement.removeChild(@_divs[0])
      @_divs[0] = null###

  #   --------------------------------------------------------------------------
  ###_makeView: ->

    @_year.div.id = "tl_year_" + @_year.date.getFullYear()
    @_year.div.className = "tl_marker"
    @_year.div.innerHTML = @_year.content
    @_year.div.style.left = @_timeline.dateToPosition(@_year.date) + "px"
    @_timeline.getUIElements().yearRow.appendChild @_year.div

    for i in [0..11]
      @_months[i].div.id = "tl_month_" + @_months[i].date.getMonth() + "_" + @_months[i].date.getFullYear()
      @_months[i].div.className = "tl_marker"
      @_months[i].div.innerHTML = @_months[i].content
      days = 1
      for d in [0..i]
        days += @daysInMonth(d, @_year.date.getFullYear())
      @_months[i].div.style.left = (@_year.div.offsetLeft + (days * 24 * 60 * 60 * 1000) / @_timeline.millisPerPixel()) + "px"
      @_timeline.getUIElements().monthRow.appendChild @_months[i].div

    #@filter()###

  #   --------------------------------------------------------------------------
  #   get array of interval between datemarkers to show
  _filterView: ->
    i = @_timeline.getMaxIntervalIndex()
    max = i + 1
    sizes = [0, 0, 0]
    while sizes[0] == 0 && i >= 0
      if @_date.getFullYear() % @_timeline.millisToYear(@_timeline.timeInterval(i)) == 0 && i > max - 3
        sizes[0] = ((i + 1) / max) * 100
      else
        i--
    if i == 0
      sizes[1] = 100
      sizes[2] = 100
    console.log "size calc " + sizes[0]
    sizes


  #   filter months
  ###for i in [1...@_months.length]
    if @_months[i].div.offsetLeft < (@_months[i - 1].div.offsetLeft + @_months[i - 1].div.offsetWidth)
      @_months[i].div.style.display = "none"
    else
      @_months[i].div.style.display = "block"###

  #   --------------------------------------------------------------------------
  ###_fontsize: ->

    #   fontsize of year div
    i = @_timeline.getMaxIntervalIndex() + 1
    max = i
    drawed = false
    while !drawed && i >= 1
      if @_year.date.getFullYear() % @_timeline.millisToYear(@_timeline.timeInterval(i - 1)) == 0
        size = (i / max) * 100
        drawed = true
      else
        i--
    #@_year.div.style.fontSize = size + "%"
    sizes = [ size, 0, 0 ]###

  #   --------------------------------------------------------------------------
  ###_createMonth: (date) ->
    div:      document.createElement("div")
    date:    date
    content:  MONTH_NAMES[date.getMonth()]###

  #   --------------------------------------------------------------------------
  getDate: ->
    @_date

  ###getYear: ->
    @_year

  getSize: ->
    @_size###

  #   --------------------------------------------------------------------------
  setDate: (date) ->
    @_date = date

  #   --------------------------------------------------------------------------
  daysInMonth: (month,year) ->
    new Date(year, month + 1, 0).getDate()
