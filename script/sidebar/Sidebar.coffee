window.HG ?= {}

class HG.Sidebar

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    defaultConfig =
      parentDiv: undefined

    @_config = $.extend {}, defaultConfig, config

    @_container = @_createElement @_config.parentDiv, "div", "sidebar"
    @_container.className = "swiper-container"

    @_wrapper = @_createElement @_container, "div", ""
    @_wrapper.className = "swiper-wrapper"

    @_slide = @_createElement @_wrapper, "div", ""
    @_slide.className = "swiper-slide"

  # ============================================================================
  addWidget: (widget) ->
    @_slide.appendChild widget.container

    @_sidebar_swiper ?= new Swiper '#sidebar',
      mode:'vertical',
      scrollContainer: true,
      autoResize: false,
      mousewheelControl: true

    @_sidebar_swiper.reInit()

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createElement: (container, type, id) ->
    div = document.createElement type
    div.id = id
    container.appendChild div
    return div
