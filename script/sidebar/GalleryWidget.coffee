window.HG ?= {}

class HG.GalleryWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      icon: ""
      name: ""
      interactive : true
      showPagination : true

    @_config = $.extend {}, defaultConfig, config

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onSlideChanged"

    HG.Widget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @_gallery = new HG.Gallery @_config

    @_gallery.onSlideChanged @, (slide) =>
      @notifyAll "onSlideChanged", slide

    @mainDiv = document.createElement "div"
    @mainDiv.className = "gallery-widget"
    @mainDiv.appendChild @_gallery.mainDiv

    @setName    @_config.name
    @setIcon    @_config.icon
    @setContent @mainDiv

    @_gallery.init()

  # ============================================================================
  addDivSlide: (div, clickCallback=undefined) ->
    @_gallery.addDivSlide div, clickCallback

  # ============================================================================
  addHTMLSlide: (html, clickCallback=undefined) ->
    @_gallery.addHTMLSlide html, clickCallback

  # ============================================================================
  getSlideCount: () ->
    @_gallery.getSlideCount()

  # ============================================================================
  getActiveSlide: () ->
    @_gallery.getActiveSlide()




