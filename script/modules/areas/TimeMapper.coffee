window.HG ?= {}

class HG.TimeMapper

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (mapping) ->

    @_dateDomain = []
    for date in mapping.domain
      tmp = date.split '.'
      @_dateDomain.push new Date tmp[2], tmp[1]-1, tmp[0]

    @_map = d3.scale.linear().domain(@_dateDomain).range(mapping.range)

  # ============================================================================
  getValue: (date) ->
    if date >= @_dateDomain[0] and date <= @_dateDomain[@_dateDomain.length-1]
      @_map date
    else
      undefined


