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
  constructor: (startDate, endDate, timeline) ->
    @_startDate = startDate
    @_endDate   = endDate   # not used yet
    @_timeline = timeline

    #   ------------------------------------------------------------------------
    @_year =
      div:      document.createElement("div")
      date:     @_startDate
      content:  @_startDate.getFullYear()

    #   ------------------------------------------------------------------------
    @_months = []
    for i in [0..11]
      date = new Date(@_startDate.getTime())
      date.setMonth(i)
      @_months.push(@_createMonth(date))

    #   ------------------------------------------------------------------------
    @_days

    #   ------------------------------------------------------------------------
    @_makeView()  

  #   --------------------------------------------------------------------------
  #   create and update views of datemarker in ui
  updateView: ->
    @_year.div.style.left = @_timeline.dateToPosition(@_year.date) + "px"
    @filter()  

  #   --------------------------------------------------------------------------
  _makeView: ->   

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

    @filter()    

  #   --------------------------------------------------------------------------
  filter: ->

    #   filter years
    i = @_timeline.getMaxIntervalIndex() + 1
    max = i
    drawed = false
    while !drawed && i >= 1
      if @_year.date.getFullYear() % @_timeline.millisToYear(@_timeline.timeInterval(i - 1)) == 0
        size = (i / max) * 100
        drawed = true
      else
        i--
    @_year.div.style.fontSize = size + "%"

    #   filter months
    for i in [1...@_months.length]
      if @_months[i].div.offsetLeft < (@_months[i - 1].div.offsetLeft + @_months[i - 1].div.offsetWidth)
        @_months[i].div.style.display = "none"
      else
        @_months[i].div.style.display = "block"

  #   --------------------------------------------------------------------------
  _createMonth: (date) ->
    div:      document.createElement("div")
    date:    date
    content:  MONTH_NAMES[date.getMonth()]

  #   --------------------------------------------------------------------------
  getStartDate: ->
    @_startDate

  getEndDate: ->
    @_endDate

  getYear: ->
    @_year

  getSize: ->
    @_size

  #   --------------------------------------------------------------------------
  setStartDate: (date) ->
    @_startDate = date

  setEndDate: (date) ->
    @_endDate = date

  #   --------------------------------------------------------------------------
  daysInMonth: (month,year) ->
    new Date(year, month + 1, 0).getDate()
