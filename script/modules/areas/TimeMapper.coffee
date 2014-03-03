window.HG ?= {}

class HG.TimeMapper

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      domain: ["01.01.1900", "01.01.2000"]
      range: [0, 1]

    @_config = $.extend {}, defaultConfig, config

    date_domain = []
    for date in @_config.domain
      tmp = date.split '.'
      date_domain.push new Date tmp[2], tmp[1]-1, tmp[0]

    @_map = d3.scale.linear().domain(date_domain).range(@_config.range)

  # ============================================================================
  map: (date) ->
    @_map(date)


