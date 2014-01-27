window.HG ?= {}

class HG.TextWidget extends HG.Widget

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
  init: (hgInstance) ->
    super hgInstance

    @setName @_config.name
    @setIcon @_config.icon

    content = document.createElement "div"
    content.innerHTML = @_config.text

    @setContent content
