window.HG ?= {}

class HG.AreaStyler

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      stylers: []

    config = $.extend {}, defaultConfig, config

    @_load_stylers config.stylers

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaStyler = @

  # ============================================================================
  getStyle: (area, now) ->

    @_init_area area

    style = null

    for styler, i in @_stylers

      new_style = null

      if area.myTimeMappers[i]?
        new_style = styler.getStyle(area.myTimeMappers[i].getValue(now))
      else
        new_style = styler.getFallbackStyle()

      if style?
        style = @_composite_styles(style, new_style)
      else
        style = new_style

    return style

  # ============================================================================
  getFallbackStyle: (area) ->

    style = null

    for styler, i in @_stylers
      new_style = styler.getFallbackStyle()

      if style?
        style = @_composite_styles(style, new_style)
      else
        style = new_style

    return style

  # ============================================================================
  _init_area: (area) ->
    unless area.myTimeMappers?
      area.myTimeMappers = []

      for styler in @_stylers
        area.myTimeMappers.push styler.myTimeMappers[area._state]


  # ============================================================================
  _load_stylers: (configs) ->
    @_stylers = []

    for config in configs
      newStyler = new HG.Styler config
      newStyler.myTimeMappers = {}
      @_stylers.push newStyler
      @_load_mapping newStyler, config

  # ============================================================================
  _load_mapping: (styler, config) ->
    $.getJSON config.mapping, (result) =>
      for country, mapping of result
        newMapper = new HG.TimeMapper mapping
        styler.myTimeMappers[country] = newMapper

  # ============================================================================
  _composite_styles: (styleSrc, styleDst) ->
    result = {}

    for attrib, value of styleSrc

      if typeof(value) is "number"
        result[attrib] = value * styleDst[attrib]
      else if typeof(value) is "string"
        result[attrib] = d3.interpolateRgb(value, styleDst[attrib])(0.5)

    return result
