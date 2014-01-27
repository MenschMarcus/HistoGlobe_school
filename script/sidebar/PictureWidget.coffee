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

    image = document.createElement "img"
    image.src = @_config.url

    content = document.createElement "div"
    content.className = "pictureWidget"
    content.appendChild image

    @setContent content
