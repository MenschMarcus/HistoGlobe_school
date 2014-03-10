window.HG ?= {}

class HG.StatisticsWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      icon: ""
      name: ""
      title: ""
      data: ""
      lineColor: ""
      lineWidth: ""
      smoothLine: false
      xAttributeName: ""
      yAttributeName: ""
      yDomain: [0,0]
      xLableTicks: 0
      yLableTicks: 0
      yCaption: ""

    @_config = $.extend {}, defaultConfig, config
    @_canvas = null
    @_canvasWidth = 0
    @_canvasHeight = 0
    @_minDate = 0
    @_maxDate = 0
    @_nowMarker = null

    @_timeline = null
    @_data = undefined
    @_dataLoadedCallback = undefined

    dsv = d3.dsv "|", "text/plain"
    dsv @_config.data, (error, data) =>
      @_data = data

      parseDate = d3.time.format("%d.%m.%Y").parse
      @_data.forEach (d) =>
        d[@_config.xAttributeName] = parseDate(d[@_config.xAttributeName])
        d[@_config.yAttributeName] = +d[@_config.yAttributeName]

      if @_dataLoadedCallback?
        @_dataLoadedCallback()

    HG.Widget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @_timeline = hgInstance.timeline

    @setName @_config.name
    @setIcon @_config.icon

    @_sidebar.onWidthChanged @, (width) =>
      @_drawStatistics()

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initNowMarker: ->

    @_nowMarker = @_canvas.append("rect")
          .attr("class", "statistics-widget-now-marker")
          .attr("x", @_dateToXCoordinate @_timeline.getNowDate())
          .attr("y", 0)
          .attr("width", 2)
          .attr("height", @_canvasHeight)

    @_timeline.onNowChanged @, (date) =>
      @_setNowMarkerPosition @_dateToXCoordinate date

  # ============================================================================
  _onDataLoaded: (callback) =>
    @_dataLoadedCallback = callback

    if @_data?
      @_dataLoadedCallback()

  # ============================================================================
  _drawStatistics: () =>
    @_onDataLoaded () =>
      if @_canvas?
        d3.select(@_canvas).remove()

      content = document.createElement "div"
      content.className = "statistics-widget swiper-no-swiping"

      if @_config.title?
        title = document.createElement "div"
        title.className = "statistics-widget statistics-widget-title"
        title.innerHTML = @_config.title
        content.appendChild title

      if @_config.subtitle?
        subtitle = document.createElement "div"
        subtitle.className = "statistics-widget statistics-widget-subtitle"
        subtitle.innerHTML = @_config.subtitle
        content.appendChild subtitle

      @setContent content
      width = $(content).width()
      height = Math.max width * 9/16, HGConfig.statistics_widget_min_height.val

      @_canvasWidth = width - HGConfig.statistics_widget_margin_left.val - HGConfig.statistics_widget_margin_right.val
      @_canvasHeight = height - HGConfig.statistics_widget_margin_top.val - HGConfig.statistics_widget_margin_bottom.val

      x = d3.time.scale()
          .range([0, @_canvasWidth])

      y = d3.scale.linear()
          .range([@_canvasHeight, 0])

      xAxis = d3.svg.axis()
          .scale(x)
          .orient("bottom")
          .ticks(@_config.xLableTicks, "")

      yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(@_config.yLableTicks, "")

      line = d3.svg.line()
        .x((d) => return x(d[@_config.xAttributeName]) )
        .y((d) => return y(d[@_config.yAttributeName]) )

      line.interpolate("basis") if @_config.smoothLine

      @_canvas = d3.select(content).append("svg")
          .attr("width", width)
          .attr("height", height)
          .append("g")
          .attr("transform", "translate(" + HGConfig.statistics_widget_margin_left.val + "," + HGConfig.statistics_widget_margin_top.val + ")")

      x.domain(d3.extent(@_data, (d) => return d[@_config.xAttributeName] ))
      y.domain(@_config.yDomain)

      @_minDate = d3.min(@_data, (d) => return d[@_config.xAttributeName])
      @_maxDate = d3.max(@_data, (d) => return d[@_config.xAttributeName])

      @_canvas.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + @_canvasHeight + ")")
          .call(xAxis)

      @_canvas.append("g")
          .attr("class", "y axis")
          .call(yAxis)
          .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", "0.71em")
          .style("text-anchor", "end")
          .text(@_config.yCaption)

      @_canvas.append("path")
        .datum(@_data)
        .attr("class", "line")
        .attr("d", line)
        .attr("stroke", "#{@_config.lineColor}")
        .attr("stroke-width", "#{@_config.lineWidth}")

      @onDivClick content, (e) =>
        x = e.clientX - $(content).offset().left -
            HGConfig.statistics_widget_margin_left.val -
            HGConfig.widget_body_padding.val
        @_setNowMarkerPosition x
        @_updateTimeline x

      @_initNowMarker()

  # ============================================================================
  _dateToXCoordinate: (date) =>
    if date.getTime() > @_maxDate.getTime()
      return @_canvasWidth

    if date.getTime() <= @_minDate.getTime()
      return 0

    return @_canvasWidth * (date.getTime() - @_minDate.getTime()) / (@_maxDate.getTime() - @_minDate.getTime())

  # ============================================================================
  _xCoordinateToDate: (x) =>
    if x > @_canvasWidth
      return @_maxDate

    if x < 0
      return @_minDate

    return new Date (@_maxDate.getTime() - @_minDate.getTime()) * x / @_canvasWidth + @_minDate.getTime()

  # ============================================================================
  _setNowMarkerPosition: (x) =>
    @_nowMarker.attr "x", Math.min(@_canvasWidth, Math.max(x, 0))

  # ============================================================================
  _updateTimeline: (x) =>
    @_timeline.moveToDate @_xCoordinateToDate(x), 0.5

