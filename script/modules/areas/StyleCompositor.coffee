window.HG ?= {}

class HG.StyleCompositor

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (stylerConfigs) ->

    @_stylers = []

    console.log stylerConfigs

    for stylerConfig in stylerConfigs
      @_stylers.push new HG.Styler stylerConfig

  # ============================================================================
  getStyle: (date, time_mappers) ->

    style = undefined

    if time_mappers?
      if @_stylers.length != time_mappers.length
        console.warn "Failed to composite style: Number of stylers and time mappers do not match! (#{@_stylers.length} vs #{time_mappers.length})"
        return undefined
      for styler, i in @_stylers
        style = styler.getStyle(time_mappers[i].map(date))
    else
      for styler, i in @_stylers
        style = styler.getFallbackStyle()

    return style
