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
      text: ""

    @_config = $.extend {}, defaultConfig, config

    HG.Widget.call @

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @setName @_config.name
    @setIcon @_config.icon

    content = document.createElement "div"
    content.className = "statistics-widget"

    height = @_width * 9/16
    unless height >= HGConfig.statistics_widget_min_height.val
      height = @_width

    height -= 2*HGConfig.widget_body_padding.val

    canvasWidth = @_width - HGConfig.statistics_widget_margin_left.val - HGConfig.statistics_widget_margin_right.val
    canvasHeight = height - HGConfig.statistics_widget_margin_top.val - HGConfig.statistics_widget_margin_bottom.val

    x = d3.scale.ordinal()
        .rangeRoundBands([0, canvasWidth], .1)

    y = d3.scale.linear()
        .range([canvasHeight, 0])

    xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")

    yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(10, "%")

    svg = d3.select(content).append("svg")
        .attr("width", @_width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + HGConfig.statistics_widget_margin_left.val + "," + HGConfig.statistics_widget_margin_top.val + ")")

    type = (d) ->
      d.frequency = +d.frequency
      return d

    dsv = d3.dsv "|", "text/plain"

    dsv("config/eu/data/statistics_data.dsv", type, (error, data) =>
      x.domain(data.map((d) -> return d.letter ))
      y.domain([0, d3.max(data, (d) -> return d.frequency )])

      svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + canvasHeight + ")")
          .call(xAxis)

      svg.append("g")
          .attr("class", "y axis")
          .call(yAxis)
        .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text("Frequency")

      svg.selectAll(".bar")
          .data(data)
          .enter().append("rect")
          .attr("class", "bar")
          .attr("x", (d) -> return x(d.letter) )
          .attr("width", x.rangeBand())
          .attr("y", (d) -> return y(d.frequency) )
          .attr("height", (d) -> return canvasHeight - y(d.frequency) )

      @setContent content
    )


