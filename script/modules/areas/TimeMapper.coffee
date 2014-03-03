window.HG ?= {}

class HG.TimeMapper

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (mapping) ->

    @_date_domain = []
    for date in mapping.domain
      tmp = date.split '.'
      @_date_domain.push new Date tmp[2], tmp[1]-1, tmp[0]

    @_map = d3.scale.linear().domain(@_date_domain).range(mapping.range)

  # ============================================================================
  getValue: (date) ->
    if date >= @_date_domain[0] and date <= @_date_domain[@_date_domain.length-1]
      @_map(date)
    else
      undefined


