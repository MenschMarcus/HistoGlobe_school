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
      extrapolateFuture: true
      extrapolatePast: true

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

    tmp = undefined

    if @_indicator[id]?
      for entry in @_indicator[id]
        date = new Date(entry[0])
        value = entry[1]

        if date < now
          tmp = value
        else if tmp?
          result = @_color(tmp)
          tmp = undefined
          break
        else
          if @_config.extrapolatePast
            result = @_color(@_indicator[id][0][1])
          break

      if tmp? and @_config.extrapolateFuture
        result = @_color(tmp)

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

