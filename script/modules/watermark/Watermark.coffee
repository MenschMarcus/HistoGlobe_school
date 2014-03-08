window.HG ?= {}

class HG.Watermark

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    defaultConfig =
      top: "0px"
      right: "0px"
      bottom: "0px"
      left: "0px"
      image: null
      opacity: 1.0

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  hgInit: (hgInstance) ->
    parentDiv = hgInstance._config.container

    image = document.createElement "img"
    image.src = @_config.image
    image.className = "watermark"
    image.style.top = @_config.top
    image.style.right = @_config.right
    image.style.bottom = @_config.bottom
    image.style.left = @_config.left

    parentDiv.appendChild image
