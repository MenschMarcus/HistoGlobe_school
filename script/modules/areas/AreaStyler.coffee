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


    return style.style

  # ============================================================================
  getFallbackStyle: (area) ->

    style = null

    for styler, i in @_stylers
      new_style = styler.getFallbackStyle()

      if style?
        style = @_composite_styles(style, new_style)
      else
        style = new_style

    return style.style

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
  _composite_styles: (base, newStyle) ->
    result = {}
    result.style = {}

    for attrib, value of newStyle.style

      compOp = newStyle.compOp[attrib]

      if compOp is "replace"
        result.style[attrib] = value
      else if compOp is "ignore"
        result.style[attrib] = base.style[attrib]
      else
        if typeof(value) is "number"
          if compOp is "mix"
            result.style[attrib] = (value + base.style[attrib])/2
          else if compOp is "multiply"
            result.style[attrib] = value * base.style[attrib]
          else
            log.warn "Compositing operation " + compOp + " is not supported! Please use ignore, replace, multiply or mix!"

        else if typeof(value) is "string"
          if compOp is "mix"
            result.style[attrib] = d3.interpolateRgb(value, base.style[attrib])(0.5)
          else if compOp is "multiply"
            src = d3.rgb(base.style[attrib])
            dst = d3.rgb(value)
            fac = 1.0 / 255.0
            result.style[attrib] = d3.rgb(fac * src.r * dst.r, fac * src.g * dst.g, fac *src.b * dst.b)
          else
            log.warn "Compositing operation " + compOp + " is not supported! Please use ignore, replace, multiply or mix!"

    return result
