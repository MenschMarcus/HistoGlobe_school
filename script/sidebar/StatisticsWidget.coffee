window.HG ?= {}

# fix swiper / d3 issue
SVGAnimatedString.prototype.indexOf = (e) -> @baseVal.indexOf(e)

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
      yDomain: [0,0]
      xLableTicks: 0
      yLableTicks: 0
      yCaption: ""
      lines : [
        dataPath: ""
        color: ""
        width: ""
        smooth: false
        xAttributeName: ""
        yAttributeName: ""
      ]

    @_config = $.extend {}, defaultConfig, config
    @_canvas = null
    @_canvasWidth = 0
    @_canvasHeight = 0
    @_minDate = 0
    @_maxDate = 0
    @_nowMarker = null

    @_graphInfo = null

    @_timeline = null
    @_data = []
    @_dataLoadedCallback = undefined

    dsv = d3.dsv "|", "text/plain"
    parseDate = d3.time.format("%d.%m.%Y").parse

    lineIndex = 0
    for l in @_config.lines
      dsv l.dataPath, (error, data) =>
        config = @_config.lines[lineIndex]
        data.forEach (d) =>
          d[config.xAttributeName] = parseDate(d[config.xAttributeName])
          d[config.yAttributeName] = +d[config.yAttributeName]

        @_data.push
          config : config
          data : data

        if lineIndex == @_config.lines.length - 1
          if @_dataLoadedCallback?
            @_dataLoadedCallback()

        lineIndex++

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
  _initTooltip: ->

    @_graphInfo = document.createElement("div")
    @_graphInfo.class = "btn btn-default"
    @_graphInfo.style.position = "absolute"
    @_graphInfo.style.left = "0px"
    @_graphInfo.style.top = "0px"
    #@_graphInfo.style.color = "white"
    #@_graphInfo.style.background = "black"
    @_graphInfo.style.visibility = "hidden"
    @_graphInfo.style.pointerEvents = "none"

    $(@_graphInfo).tooltip {title: "TEST", html:true, placement: "top", container:"#histoglobe"}
    #$(@_graphInfo).tooltip()
    #$(@_graphInfo).tooltip {content:"TEST"}

    #@_graphInfo.appendChild(document.createTextNode('hello this is javascript work'));


    console.log @_canvas
    document.body.appendChild(@_graphInfo)



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

    if @_data.length > 0
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

      @_canvas = d3.select(content).append("svg")
          .attr("width", width)
          .attr("height", height)
          .append("g")
          .attr("transform", "translate(" + HGConfig.statistics_widget_margin_left.val + "," + HGConfig.statistics_widget_margin_top.val + ")")

      for entry in @_data
        line = d3.svg.line()
          .x((d) => return x(d[entry.config.xAttributeName]) )
          .y((d) => return y(d[entry.config.yAttributeName]) )

        line.interpolate("basis") if entry.config.smooth

        x.domain(d3.extent(entry.data, (d) => return d[entry.config.xAttributeName] ))
        y.domain(@_config.yDomain)

        @_minDate = d3.min(entry.data, (d) => return d[entry.config.xAttributeName])
        @_maxDate = d3.max(entry.data, (d) => return d[entry.config.xAttributeName])

        @_canvas.append("path")
          .datum(entry.data)
          .attr("class", "line")
          .attr("d", line)
          .attr("stroke", "#{entry.config.color}")
          .attr("stroke-width", "#{entry.config.width}")
          .on("mousemove", @_showTooltip)
          .on("mouseout", @_hideTooltip)


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

      @onDivClick content, (e) =>
        x = e.clientX - $(content).offset().left -
            HGConfig.statistics_widget_margin_left.val -
            HGConfig.widget_body_padding.val
        @_setNowMarkerPosition x
        @_updateTimeline x

      @_initNowMarker()

      @_initTooltip()

  # ============================================================================
  _showTooltip: (e) =>
    #console.log e
    #$(@_graphInfo).tooltip.title = e[0].amount + "<br />" + e[0].amount.date
    string = e[0].amount + "<br />" + e[0].date
    console.log string

    $(@_graphInfo.class).tooltip( "option", "title", e[0].amount + "<br />" + e[0].date );
    #console.log $(@_graphInfo).tooltip#("option","title")
    #$(@_graphInfo).tooltip.title = "bla"

    @_graphInfo.style.left = window.event.clientX + "px"
    @_graphInfo.style.top = window.event.clientY + "px"
    $(@_graphInfo).tooltip "show"
    #@_graphInfo.style.visibility = "visible"


  # ============================================================================
  _hideTooltip: (e) =>
    $(@_graphInfo).tooltip "hide"




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

