window.HG ?= {}

class HG.AreaIndicator

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      data: undefined
      domain: [0, 1]
      rangeFillColor: ["red", "green"]
      rangeFillOpacity: [1, 1]
      rangeLineColor: ["grey", "grey"]
      rangeLineOpacity: [1, 1]
      rangeLineWidth: [2, 2]
      fallbackFillColor: "grey"
      fallbackFillOpacity: 1
      fallbackLineColor: "grey"
      fallbackLineOpacity: 1
      fallbackLineWidth: 1
      extrapolateFuture: true
      extrapolatePast: true

    @_config = $.extend {}, defaultConfig, config

    @_fill_color    = d3.scale.linear().domain(@_config.domain).range(@_config.rangeFillColor)
    @_fill_opacity  = d3.scale.linear().domain(@_config.domain).range(@_config.rangeFillOpacity)
    @_line_color    = d3.scale.linear().domain(@_config.domain).range(@_config.rangeLineColor)
    @_line_opacity  = d3.scale.linear().domain(@_config.domain).range(@_config.rangeLineOpacity)
    @_line_width    = d3.scale.linear().domain(@_config.domain).range(@_config.rangeLineWidth)

    if config.data?
      @loadFromJSON config.data

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaIndicator = @

  # ============================================================================
  getStyle: (id, now) ->

    result =
      fillColor:   d3.rgb(@_config.fallbackFillColor).toString()
      fillOpacity: @_config.fallbackFillOpacity
      lineColor:   d3.rgb(@_config.fallbackLineColor).toString()
      lineOpacity: @_config.fallbackLineOpacity
      lineWidth:   @_config.fallbackLineWidth

    tmp = undefined

    if @_indicator[id]?
      for entry in @_indicator[id]
        date = new Date(entry[0])
        value = entry[1]

        if date < now
          tmp = value
        else if tmp?
          result.fillColor      = @_fill_color(tmp)
          result.fillOpacity    = @_fill_opacity(tmp)
          result.lineColor      = @_line_color(tmp)
          result.lineOpacity    = @_line_opacity(tmp)
          result.lineWidth      = @_line_width(tmp)
          tmp = undefined
          break
        else
          if @_config.extrapolatePast
            result.fillColor    = @_fill_color(@_indicator[id][0][1])
            result.fillOpacity  = @_fill_opacity(@_indicator[id][0][1])
            result.lineColor    = @_line_color(@_indicator[id][0][1])
            result.lineOpacity  = @_line_opacity(@_indicator[id][0][1])
            result.lineWidth    = @_line_width(@_indicator[id][0][1])
          break

      if tmp? and @_config.extrapolateFuture
        result.fillColor        = @_fill_color(tmp)
        result.fillOpacity      = @_fill_opacity(tmp)
        result.lineColor        = @_line_color(tmp)
        result.lineOpacity      = @_line_opacity(tmp)
        result.lineWidth        = @_line_width(tmp)

    return result

  # ============================================================================
  loadFromJSON: (path) ->
    @_indicator = {}

    $.getJSON path, (indicator) =>
      for entry in indicator[1]
        if entry.value?
          @_indicator[entry.country.id] ?= []

          date = entry.date.split '.'
          day = 1
          month = 1
          year = date[date.length-1]

          if date.length is 3
            day = date[0]
            month = date[1]
          else if date.length is 2
            month = date[0]

          d = new Date(year, month-1, day)

          @_indicator[entry.country.id].push([d, entry.value])


      for id, entry of @_indicator
        entry.sort (a, b) ->
          a = new Date(a[0]);
          b = new Date(b[0]);

          if a<b
            return -1
          if a>b
            return  1

          return 0;

