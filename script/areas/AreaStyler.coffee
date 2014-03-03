window.HG ?= {}

class HG.AreaStyler

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      stylerConfigs: []
      timeMappings: []

    config = $.extend {}, defaultConfig, config

    @_style_compositor = new HG.StyleCompositor config.stylerConfigs

    @_load_time_mappings config.timeMappings

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaStyler = @

  # ============================================================================
  getStyle: (area, now) ->

    unless area.my_time_mappers?
      area.my_time_mappers = @_time_mappers[area._state]

    return @_style_compositor.getStyle now, area.my_time_mappers

  # ============================================================================
  _load_time_mappings: (time_mappings) ->

    @_time_mappers = {}

    for time_mapping in time_mappings
      $.getJSON time_mapping, (result) =>
        for country, mapping of result
          unless @_time_mappers[country]?
            @_time_mappers[country] = []

          @_time_mappers[country].push new HG.TimeMapper mapping
