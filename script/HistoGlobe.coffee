window.HG ?= {}

class HG.HistoGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (pathToJson) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onTopAreaSlide"
    @addCallback "onAllModulesLoaded"

    @timeline = null
    @map = null
    @sidebar = null

    @_config = null

    defaultConfig =
      container: "histoglobe"
      nowYear: 2014
      minYear: 1940
      maxYear: 2020
      minZoom: 1
      maxZoom: 6
      startZoom: 4
      maxBounds: undefined
      startLatLong: [51.505, 10.09]
      tiles: 'data/tiles/'

    $.getJSON(pathToJson, (config) =>
      hgConf = config["HistoGlobe"]
      @_config = $.extend {}, defaultConfig, hgConf
      @_config.container =  document.getElementById @_config.container

      @_createTopArea()

      @_createMap()
      @_createSidebar()
      @_createTimeline()
      @_createCollapseButton()

      $(window).on 'resize', @_onResize

      @_collapsed = !@isInMobileMode()
      @_collapse()

      load_module = (moduleName, moduleConfig) =>
        if window["HG"][moduleName]?
          newMod = new window["HG"][moduleName] moduleConfig
          @addModule newMod
        else
          console.error "The module #{moduleName} is not part of the HG namespace!"

      for moduleName, moduleConfig of config
        if moduleName is "Widgets"
          for widget in moduleConfig
            load_module widget.type, widget
        else if moduleName isnt "HistoGlobe"
          load_module moduleName, moduleConfig


      @notifyAll "onAllModulesLoaded"
      @_updateLayout()
    )


  # ============================================================================
  addModule: (module) ->
    module.hgInit @

  # ============================================================================
  isInMobileMode: =>
    window.innerWidth < HGConfig.sidebar_width.val + HGConfig.map_min_width.val

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createTopArea: ->
    @_top_area = @_createElement @_config.container, "div", "top-area"
    @_top_area_wrapper = @_createElement @_top_area, "div", ""
    @_top_area_wrapper.className = "swiper-wrapper"

    @_top_swiper = new Swiper '#top-area',
      mode:'horizontal'
      slidesPerView: 'auto'
      noSwiping: true
      longSwipesRatio: 0.1
      moveStartThreshold: 10
      onSlideReset: @_onSlideEnd
      onSetWrapperTransform: (s, t) => @_onSlide(t)
      onSetWrapperTransition: (s, d) =>
        if d is 0
          $(@mapCanvas).addClass("no-animation")
        else
          $(@mapCanvas).removeClass("no-animation")

    @_top_swiper.wrapperTransitionEnd(@_onSlideEnd, true)

  # ============================================================================
  _createSidebar: ->
    @_sidebar_area = @_createElement @_top_area_wrapper, "div", "sidebar-area"
    @_sidebar_area.className = "swiper-slide"

    @sidebar = new HG.Sidebar
    @addModule @sidebar


  # ============================================================================
  _createCollapseButton: ->
    @_collapse_area_left = @_createElement @_map_area, "div", "collapse-area-left"
    @_collapse_area_right = @_createElement @_sidebar_area, "div", "collapse-area-right"

    @_collapse_button = @_createElement @_map_area, "i", "collapse-button"
    @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"


    $(@_collapse_button).click @_collapse
    $(@_collapse_area_left).click @_collapse
    # $(@_collapse_area_right).click @_collapse

  # ============================================================================
  _createMap: ->
    @_map_area = @_createElement @_top_area_wrapper, "div", "map-area"
    @_map_area.className = "swiper-slide"

    @mapCanvas = @_createElement @_map_area, "div", "map-canvas"
    @mapCanvas.className = "swiper-no-swiping"

    @_map_area.appendChild @mapCanvas
    @map = new HG.Display2D
    @addModule @map

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
      @_collapse_area_left.style.width = "0px"
      @_collapse_area_right.style.width = "#{HGConfig.sidebar_collapsed_width.val}px"
    else
      @_collapse_button.className = "fa fa-arrow-circle-o-right fa-2x"
      @_collapse_area_right.style.width = "0px"
      if @isInMobileMode()
        @_collapse_area_left.style.width = "#{HGConfig.map_collapsed_width.val}px"

  # ============================================================================
  _onSlide: (transform) =>
    if (transform.x < 0)
      @mapCanvas.style.right = "#{transform.x/2}px"
    else
      @mapCanvas.style.right = 0

    @notifyAll "onTopAreaSlide", transform.x


  # ============================================================================
  _onResize: () =>
    @_updateLayout()

  # ============================================================================
  _updateLayout: =>
    width = window.innerWidth
    height = window.innerHeight

    map_height = height - HGConfig.timeline_height.val
    map_width = width - HGConfig.sidebar_collapsed_width.val
    sidebar_width = HGConfig.sidebar_width.val

    if @isInMobileMode()
      sidebar_width = width - HGConfig.map_collapsed_width.val

    @_map_area.style.width = "#{map_width}px"
    @_map_area.style.height = "#{map_height}px"


    @sidebar.resize sidebar_width, map_height
    @map.resize map_width, map_height

    @_top_swiper.reInit()

  # ============================================================================
  _createElement: (container, type, id) ->
    div = document.createElement type
    div.id = id
    container.appendChild div
    return div
