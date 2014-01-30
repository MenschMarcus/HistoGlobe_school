window.HG ?= {}

class HG.HistoGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container) ->

    @_container = container

    @_timeline = null
    @_map = null

    @_createTopArea()

    @_createMap()
    @_createSidebar()
    @_createTimeline()
    @_createCollapseButton()

    $(window).on 'resize', @_updateLayout

    @_updateLayout()

    @_collapsed = @_isInMobileMode()
    @_collapse()

  # ============================================================================
  addModule: (module) ->
    module.init @

  # ============================================================================
  getTimeline: () ->
    @_timeline

  # ============================================================================
  getMap: () ->
    @_map

  # ============================================================================
  getSidebar: () ->
    @_sidebar

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createTopArea: ->
    @_top_area = @_createElement @_container, "div", "top-area"
    @_top_area_wrapper = @_createElement @_top_area, "div", ""
    @_top_area_wrapper.className = "swiper-wrapper"

    @_top_swiper = new Swiper '#top-area',
      mode:'horizontal',
      slidesPerView: 'auto',
      # cssWidthAndHeight: true,
      resistance:'10%',
      onSlideChangeEnd: () => @_onSlide()
      onResistanceBefore: () => @_onSlide()
      onResistanceAfter: () => @_onSlide()

  # ============================================================================
  _createSidebar: ->
    @_sidebar_area = @_createElement @_top_area_wrapper, "div", "sidebar-area"
    @_sidebar_area.className = "swiper-slide"

    @_sidebar = new HG.Sidebar(
      parentDiv: @_sidebar_area
    )

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
    @_map = new HG.Display2D @_map_canvas

  # ============================================================================
  _createTimeline: ->
    @_timeline_area = @_createElement @_container, "div", "timeline-area"
    config =
      parentDiv: @_timeline_area
      nowYear: 1900
      minYear: 1800
      maxYear: 2000
    @_timeline = new HG.Timeline config

  # ============================================================================
  _collapse: =>
    if (@_collapsed)
      @_top_swiper.swipeNext()
    else
      @_top_swiper.swipePrev()

    # @_updateLayout()

  # ============================================================================
  _onSlide: () =>
    slide = @_top_swiper.slides[0].getOffset().left

    @_collapsed = slide is 0

    if @_collapsed
      @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"
    else
      @_collapse_button.className = "fa fa-arrow-circle-o-right fa-2x"


  # ============================================================================
  _updateLayout: =>
    width = window.innerWidth
    @_map_area.style.width = "#{width - SIDEBAR_COLLAPSED_WIDTH}px"

    @_map.resize width - SIDEBAR_COLLAPSED_WIDTH
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

  MAP_MIN_WIDTH = 300
  MAP_COLLAPSED_WIDTH = 30

  COLLAPSE_DURATION = 250 #ms
