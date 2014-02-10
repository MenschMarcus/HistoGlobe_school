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
      fallback: "grey"
      extrapolate: false

    @_config = $.extend {}, defaultConfig, config

    @_color = d3.scale.linear().domain(config.domain).range(config.range)

    if config.data?
      @loadFromJSON config.data

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaIndicator = @

  # ============================================================================
  getColor: (id, now) ->
    result = @_config.fallback

    for date, value of @_indicator[id]
      if new Date(date) < new Date(now)
        color = @_color(value)
        break

    return color

  # ============================================================================
  loadFromJSON: (path) ->
    @_indicator = {}

    $.getJSON path, (indicator) =>
      for entry in indicator[1]
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
        @_indicator[entry.country.id][d] = entry.value

      for id, values of @_indicator
        values.sort (a, b) ->
          a = new Date(a.dateModified);
          b = new Date(b.dateModified);
          return a>b ? -1 : a<b ? 1 : 0;

