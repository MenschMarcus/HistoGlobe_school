window.HG ?= {}

class HG.PictureGalleryWidget extends HG.GalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      pictures : []

    @_config = $.extend {}, defaultConfig, config

    HG.GalleryWidget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    for picture in @_config.pictures
      @addPicture picture

  # ============================================================================
  addPicture: (config) ->
    defaultConfig =
      image: ""
      description: ""
      copyright: ""

    config = $.extend {}, defaultConfig, config

    div = document.createElement "div"
    div.className = "picture-gallery-widget"

    image = document.createElement "div"
    image.className = "picture-gallery-widget-image"
    image.style.backgroundImage = "url('#{config.image}')"
    div.appendChild image

    unless config.copyright is ""
      copyright = document.createElement "div"
      copyright.className = "picture-gallery-widget-copyright"
      copyright.innerHTML = config.copyright
      image.appendChild copyright

    text = document.createElement "div"
    text.className = "clear picture-gallery-widget-text"
    text.innerHTML = config.description
    image.appendChild text

    @addDivSlide div

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

