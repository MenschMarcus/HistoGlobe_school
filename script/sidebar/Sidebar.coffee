window.HG ?= {}

class HG.Sidebar

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onResize"

    defaultConfig =
      parentDiv: undefined

    @_config = $.extend {}, defaultConfig, config

    @_container = @_createElement @_config.parentDiv, "div", "sidebar"
    @_container.className = "swiper-container"

    scrollbar = @_createElement @_container, "div", "sidebar-scrollbar"

    @_wrapper = @_createElement @_container, "div", ""
    @_wrapper.className = "swiper-wrapper"

    @_slide = @_createElement @_wrapper, "div", ""
    @_slide.className = "swiper-slide"

    @_sidebar_swiper = new Swiper '#sidebar',
      mode:'vertical'
      grabCursor: true
      scrollContainer: true
      mousewheelControl: true
      scrollbar:
        hide: false
        container: '#sidebar-scrollbar'

    # for some reason needed...
    window.setTimeout () =>
      @updateSize()
    , 1000

  # ============================================================================
  addWidget: (widget) ->
    @_slide.appendChild widget.container
    widget.setWidth $(".widgetBody").width() - HGConfig.widget_title_size.val - 2*HGConfig.widget_body_padding.val
    @updateSize()

  # ============================================================================
  updateSize: () ->
    @_sidebar_swiper?.reInit()

  # ============================================================================
  resize: (width, height) ->
    @_container.style.width = "#{width}px"
    @_container.style.height = "#{height}px"
    $(".widgetBody").css("width", width - 2*HGConfig.widget_margin.val - HGConfig.sidebar_scrollbar_width.val)
    $(".widgetContainer").css("width", width - HGConfig.widget_title_size.val + HGConfig.widget_margin.val - HGConfig.sidebar_scrollbar_width.val)
    @_sidebar_swiper?.reInit()
    @notifyAll "onResize", width, height

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createElement: (container, type, id) ->
    div = document.createElement type
    div.id = id
    container.appendChild div
    return div
