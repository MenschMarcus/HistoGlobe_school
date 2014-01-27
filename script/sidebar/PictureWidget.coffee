window.HG ?= {}

class HG.PictureWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    defaultConfig =
      icon: ""
      name: ""
      url: ""

    @_config = $.extend {}, defaultConfig, config

    HG.Widget.call @

  # ============================================================================
  init: (hgInstance) ->
    super hgInstance

    @setName @_config.name
    @setIcon @_config.icon

    content = document.createElement "img"
    content.src = @_config.url

    @setContent content
