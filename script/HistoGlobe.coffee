window.HG ?= {}

class HG.HistoGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    defaultConfig =
      container: undefined
      nowYear: 2014
      minYear: 1940
      maxYear: 2020

    @_config = $.extend {}, defaultConfig, config

    @timeline = null
    @map = null
    @sidebar = null

    @_createTopArea()

    @_createMap()
    @_createSidebar()
    @_createTimeline()
    @_createCollapseButton()

    $(window).on 'resize', @_onResize

    @_onResize()

    @_collapsed = !@_isInMobileMode()
    @_collapse()

  # ============================================================================
  addModule: (module) ->
    module.hgInit @

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createTopArea: ->
    @_top_area = @_createElement @_config.container, "div", "top-area"
    @_top_area_wrapper = @_createElement @_top_area, "div", ""
    @_top_area_wrapper.className = "swiper-wrapper"

    @_top_swiper = new Swiper '#top-area',
      mode:'horizontal',
      slidesPerView: 'auto',
      noSwiping: true,
      onSlideChangeEnd: () => @_onSlideEnd()
      onTouchEnd: () => @_onSlideEnd()
      onSetWrapperTransform: (s, t) => @_onSlide(t)
      onSetWrapperTransition: (s, d) =>
        if d is 0
          $(@_map_canvas).addClass("no-animation")
        else
          $(@_map_canvas).removeClass("no-animation")

  # ============================================================================
  _createSidebar: ->
    @_sidebar_area = @_createElement @_top_area_wrapper, "div", "sidebar-area"
    @_sidebar_area.className = "swiper-slide"

    @sidebar = new HG.Sidebar
      parentDiv: @_sidebar_area


  # ============================================================================
  _createCollapseButton: ->
    @_collapse_button = @_createElement @_map_area, "i", "collapse-button"
    @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"

    $(@_collapse_button).click @_collapse

  # ============================================================================
  _createMap: ->
    @_map_area = @_createElement @_top_area_wrapper, "div", "map-area"
    @_map_area.className = "swiper-slide"

    @_map_canvas = @_createElement @_map_area, "div", "map-canvas"

    @_map_area.appendChild @_map_canvas
    @map = new HG.Display2D @_map_canvas

  # ============================================================================
  _createTimeline: ->
    @_timeline_area = @_createElement @_config.container, "div", "timeline-area"

    @timeline = new HG.Timeline
      parentDiv: @_timeline_area
      nowYear: @_config.nowYear
      minYear: @_config.minYear
      maxYear: @_config.maxYear

  # ============================================================================
  _collapse: =>
    @_collapsed = not @_collapsed

    if @_collapsed
      @_top_swiper.swipePrev()
    else
      @_top_swiper.swipeNext()

  # ============================================================================
  _onSlideEnd: () =>
    slide = @_top_swiper.slides[0].getOffset().left

    @_collapsed = slide >= 0

    if @_collapsed
      @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"
    else
      @_collapse_button.className = "fa fa-arrow-circle-o-right fa-2x"


  # ============================================================================
  _onSlide: (transform) =>
    if (transform.x < 0)
      @_map_canvas.style.right = "#{transform.x/2}px"
    else
      @_map_canvas.style.right = 0

    # return false;


  # ============================================================================
  _onResize: () =>
    @_updateLayout()

  # ============================================================================
  _updateLayout: =>
    width = window.innerWidth
    height = window.innerHeight

    map_height = height - TIMELINE_HEIGHT
    map_width = width - SIDEBAR_COLLAPSED_WIDTH
    sidebar_width = 400

    if @_isInMobileMode()
      sidebar_width = width - MAP_COLLAPSED_WIDTH

    @_map_area.style.width = "#{map_width}px"
    @_map_area.style.height = "#{map_height}px"


    @sidebar.resize sidebar_width, map_height
    @map.resize map_width, map_height

    @_top_swiper.reInit()

  # ============================================================================
  _isInMobileMode: =>
    window.innerWidth < SIDEBAR_MIN_WIDTH + MAP_MIN_WIDTH

  # ============================================================================
  _createElement: (container, type, id) ->
    div = document.createElement type
    div.id = id
    container.appendChild div
    return div

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  SIDEBAR_MIN_WIDTH = 400
  SIDEBAR_COLLAPSED_WIDTH = 53

  TIMELINE_HEIGHT = 80

  MAP_MIN_WIDTH = 300
  MAP_COLLAPSED_WIDTH = 50

  COLLAPSE_DURATION = 250 #ms
