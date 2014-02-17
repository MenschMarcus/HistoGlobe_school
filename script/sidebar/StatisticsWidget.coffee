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
      xAttributeName: ""
      yAttributeName: ""
      yLableDistance: 0
      yCaption: ""

    @_config = $.extend {}, defaultConfig, config
    @_canvas = null
    @_canvasWidth = 0
    @_canvasHeight = 0
    @_minYear = 0
    @_maxYear = 0
    @_nowMarker = null

    @_timeline = null

    HG.Widget.call @

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @_timeline = hgInstance.timeline

    @setName @_config.name
    @setIcon @_config.icon

    content = document.createElement "div"
    content.className = "statistics-widget"

    height = @_width * 9/16
    unless height >= HGConfig.statistics_widget_min_height.val
      height = @_width

    height -= 2*HGConfig.widget_body_padding.val

    @_canvasWidth = @_width - HGConfig.statistics_widget_margin_left.val - HGConfig.statistics_widget_margin_right.val
    @_canvasHeight = height - HGConfig.statistics_widget_margin_top.val - HGConfig.statistics_widget_margin_bottom.val

    x = d3.scale.ordinal()
        .rangeRoundBands([0, @_canvasWidth], .1)

    y = d3.scale.linear()
        .range([@_canvasHeight, 0])

    xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")

    yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(@_config.yLableDistance, "")

    @_canvas = d3.select(content).append("svg")
        .attr("width", @_width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + HGConfig.statistics_widget_margin_left.val + "," + HGConfig.statistics_widget_margin_top.val + ")")

    type = (d) =>
      d[@_config.yAttributeName] = +d[@_config.yAttributeName]
      return d

    dsv = d3.dsv "|", "text/plain"

    dsv(@_config.data, type, (error, data) =>
      x.domain(data.map((d) => return d[@_config.xAttributeName] ))
      y.domain([0, d3.max(data, (d) => return d[@_config.yAttributeName] )])

      @_minYear = d3.min(data, (d) => return d[@_config.xAttributeName])
      @_maxYear = d3.max(data, (d) => return d[@_config.xAttributeName])

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
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text(@_config.yCaption)


      @_canvas.selectAll(".bar")
          .data(data)
          .enter().append("rect")
          .attr("class", "bar")
          .attr("x", (d) => return x(d[@_config.xAttributeName]) )
          .attr("width", x.rangeBand())
          .attr("y", (d) => return y(d[@_config.yAttributeName]) )
          .attr("height", (d) => return @_canvasHeight - y(d[@_config.yAttributeName]) )

      @_initNowMarker()

      @setContent content
    )

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initNowMarker: ->
    startYear = @_timeline.getNowDate().getFullYear()

    @_nowMarker = @_canvas.append("rect")
          .attr("id", "statistics_now_marker")
          .attr("x", @_yearToXCoordinate startYear)
          .attr("y", 0)
          .attr("width", 4)
          .attr("height", @_canvasHeight)

    @_timeline.onNowChanged @, (date) =>
      @_nowMarker.attr("x", @_yearToXCoordinate date.getFullYear())

  # ============================================================================
  _yearToXCoordinate: (year) =>
    if year > @_maxYear
      return @_canvasWidth

    if year < @_minYear
      return 0

    return @_canvasWidth * (year - @_minYear) / (@_maxYear - @_minYear)

  # ============================================================================
  _xCoordinateToYear: (x) =>
    if x > @_canvasWidth
      return @_maxYear

    if x < 0
      return @_minYear

    return Math.round (@_maxYear * x / @_canvasWidth)
