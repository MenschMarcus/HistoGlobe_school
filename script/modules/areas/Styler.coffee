window.HG ?= {}

class HG.Styler

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      domain: [0, 1]
      fillColor:
        range: ["red", "green"]
        fallback: "grey"
      fillOpacity:
        range: [1, 1]
        fallback: 1
      lineColor:
        range: ["grey", "grey"]
        fallback: "grey"
      lineOpacity:
        range: [1, 1]
        fallback: 1
      lineWidth:
        range: [2, 2]
        fallback: 1
      labelOpacity:
        range: [1, 1]
        fallback: 1

    @_config = $.extend {}, defaultConfig, config
    @_config.fillColor = $.extend {}, defaultConfig.fillColor, config.fillColor
    @_config.fillOpacity = $.extend {}, defaultConfig.fillOpacity, config.fillOpacity
    @_config.lineColor = $.extend {}, defaultConfig.lineColor, config.lineColor
    @_config.lineOpacity = $.extend {}, defaultConfig.lineOpacity, config.lineOpacity
    @_config.lineWidth = $.extend {}, defaultConfig.lineWidth, config.lineWidth
    @_config.labelOpacity = $.extend {}, defaultConfig.labelOpacity, config.labelOpacity

    @_fill_color    = d3.scale.linear().domain(@_config.domain).range(@_config.fillColor.range)
    @_fill_opacity  = d3.scale.linear().domain(@_config.domain).range(@_config.fillOpacity.range)
    @_line_color    = d3.scale.linear().domain(@_config.domain).range(@_config.lineColor.range)
    @_line_opacity  = d3.scale.linear().domain(@_config.domain).range(@_config.lineOpacity.range)
    @_line_width    = d3.scale.linear().domain(@_config.domain).range(@_config.lineWidth.range)
    @_label_opacity = d3.scale.linear().domain(@_config.domain).range(@_config.labelOpacity.range)

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaĆolorizer = @

  # ============================================================================
  getFallbackStyle: (value) ->
    result =
      fillColor:    d3.rgb(@_config.fillColor.fallback).toString()
      fillOpacity:  @_config.fillOpacity.fallback
      lineColor:    d3.rgb(@_config.lineColor.fallback).toString()
      lineOpacity:  @_config.lineOpacity.fallback
      lineWidth:    @_config.lineWidth.fallback
      labelOpacity: @_config.labelOpacity.fallback

  # ============================================================================
  getInterpolatedStyle: (alpha) ->
    result =
      fillColor:    @_fill_color(alpha)
      fillOpacity:  @_fill_opacity(alpha)
      lineColor:    @_line_color(alpha)
      lineOpacity:  @_line_opacity(alpha)
      lineWidth:    @_line_width(alpha)
      labelOpacity: @_label_opacity(alpha)

  # ============================================================================
  getStyle: (value) ->

    unless value?
      return @getFallbackStyle()

    if value >= @_config.domain[0] and value <= @_config.domain[@_config.domain.length-1]
      return @getInterpolatedStyle value

    else
      return @getFallbackStyle()
