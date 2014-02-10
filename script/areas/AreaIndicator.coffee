window.HG ?= {}

class HG.AreaIndicator

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      domain: [0, 1]
      range: ["red", "green"]
      data: undefined

    config = $.extend {}, defaultConfig, config

    @_color = d3.scale.linear().domain(config.domain).range(config.range)

    if config.data?
      @loadFromJSON config.data

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaIndicator = @

  # ============================================================================
  getColor: (id, now) ->
    result = undefined
    for date, value of @_indicator[id]
      result ?= value
      if date > now
        break
      else
        result = value

    if result?
      result = @_color(result)

    return result

  # ============================================================================
  loadFromJSON: (path) ->
    @_indicator = {}

    $.getJSON path, (indicator) =>
      for entry in indicator[1]
        @_indicator[entry.country.id] ?= {}
        @_indicator[entry.country.id][parseInt(entry.date)] = entry.value
