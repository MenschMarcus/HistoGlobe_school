window.HG ?= {}

class HG.StatisticsWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      icon: ""
      name: ""
      text: ""

    @_config = $.extend {}, defaultConfig, config

    HG.Widget.call @

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @setName @_config.name
    @setIcon @_config.icon

    content = document.createElement "div"
    content.className = "statistics-widget"
    content.innerHTML = @_config.text

    @setContent content
