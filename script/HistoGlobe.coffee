window.HG ?= {}

class HG.HistoGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container) ->

    @_container = container

    @timeline = null
    @map = null
    @sidebar_area = null

    @_createSidebar()
    @_createMap()
    @_createTimeline()
    @_createCollapseButton()

    @_collapsed = @_isInMobileMode()

    $(window).on 'resize', @_updateLayout

    @_updateLayout()

  # ============================================================================
  addModule: (module) ->
    module.hgInit @

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createSidebar: ->
    @sidebar_area = @_createElement "div", "sidebarArea"

    # scrollbar = document.createElement "div"
    # scrollbar.className = "swiper-scrollbar"
    # @sidebar_area.appendChild scrollbar

    $(@sidebar_area).click (e) =>
      if e.target is @sidebar_area or
         $(e.target).hasClass("collapseOnClick") or
         $(e.target).parents(".collapseOnClick").length isnt 0

        @_collapse()

    # @_swiper = new Swiper ".swiper-container",
    #   mode:'vertical',
    #   # loop: false,
    #   mousewheelControl:true,
    #   # freeMode: true,
    #   # freeModeFluid: true,
    #   slidesPerView: 'auto',
    #   scrollContainer: true
    #   scrollbar:
    #     container : '.swiper-scrollbar',
    #     draggable : true,
    #     hide: false

  # ============================================================================
  _createCollapseButton: ->
    @_collapse_button = @_createElement "i", "collapseButton"
    @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"

    $(@_collapse_button).click @_collapse

  # ============================================================================
  _createMap: ->
    @map_area = @_createElement "div", "mapArea"

    @map_canvas = document.createElement "div"
    @map_canvas.id = "mapCanvas"

    @map_area.appendChild @map_canvas

    @map = new HG.Display2D @map_canvas

  # ============================================================================
  _createTimeline: ->
    @timeline_area = @_createElement "div", "timelineArea"
    config =
      parentDiv: @timeline_area
      nowYear: 1900
      minYear: 1800
      maxYear: 2000
    @timeline = new HG.Timeline config

  # ============================================================================
  _collapse: =>
    @_collapsed = not @_collapsed
    @_updateLayout()

  # ============================================================================
  _updateLayout: =>

    width = window.innerWidth
    mapWidth = 0

    # update div positions and widths if collapsed or uncollapsed
    if @_collapsed
      @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"
      @map_area.style.right = "#{SIDEBAR_COLLAPSED_WIDTH}px"
      @_collapse_button.style.right = "#{SIDEBAR_COLLAPSED_WIDTH}px"

      if @_isInMobileMode()
        @sidebar_area.style.right = "#{SIDEBAR_COLLAPSED_WIDTH - width + MAP_COLLAPSED_WIDTH}px"
        @sidebar_area.style.width = "#{width - MAP_COLLAPSED_WIDTH}px"
        mapWidth = width-SIDEBAR_COLLAPSED_WIDTH
      else
        @sidebar_area.style.right = "#{SIDEBAR_COLLAPSED_WIDTH - SIDEBAR_MIN_WIDTH}px"
        @sidebar_area.style.width = "#{SIDEBAR_MIN_WIDTH}px"
        mapWidth = width-SIDEBAR_COLLAPSED_WIDTH

    else
      @_collapse_button.className = "fa fa-arrow-circle-o-right fa-2x"
      @sidebar_area.style.right = "0px"

      if @_isInMobileMode()
        @map_area.style.right = "#{width - MAP_COLLAPSED_WIDTH}px"
        @_collapse_button.style.right = "#{width - MAP_COLLAPSED_WIDTH}px"
        @sidebar_area.style.width = "#{width - MAP_COLLAPSED_WIDTH}px"
        mapWidth = width-SIDEBAR_MIN_WIDTH

      else
        @map_area.style.right = "#{SIDEBAR_MIN_WIDTH}px"
        @_collapse_button.style.right = "#{SIDEBAR_MIN_WIDTH}px"
        @sidebar_area.style.width = "#{SIDEBAR_MIN_WIDTH}px"
        mapWidth = width-SIDEBAR_MIN_WIDTH

    if @_collapsed
      $(@map_canvas).addClass "noAnimation"
      $(@map_area).addClass "noAnimation"
      @map_canvas.style.right = "#{(SIDEBAR_MIN_WIDTH-SIDEBAR_COLLAPSED_WIDTH)/2}px"
      @map_canvas.style.width = "#{mapWidth}px"
      @map_area.style.width = "#{mapWidth}px"
      $(@map_canvas).removeClass "noAnimation"
      $(@map_area).removeClass "noAnimation"
      @map_canvas.style.right = "0px"
      @map.resize mapWidth, @map_area.offsetHeight

    else
      $(@map_canvas).addClass "noAnimation"
      @map_canvas.style.right = "#{-(SIDEBAR_MIN_WIDTH-SIDEBAR_COLLAPSED_WIDTH)/2}px"
      $(@map_canvas).removeClass "noAnimation"
      @map_canvas.style.right = "0px"
      @map_area.style.width = "#{mapWidth}px"
      @map_canvas.style.width = "#{mapWidth}px"

      window.setTimeout ()=>
        @map.resize mapWidth, @map_area.offsetHeight
      , COLLAPSE_DURATION


  # ============================================================================
  _isInMobileMode: =>
    window.innerWidth < SIDEBAR_MIN_WIDTH + MAP_MIN_WIDTH

  # ============================================================================
  _createElement: (type, id) ->
    div = document.createElement type
    div.id = id
    @_container.appendChild div
    return div

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  SIDEBAR_MIN_WIDTH = 400
  SIDEBAR_COLLAPSED_WIDTH = 53

  MAP_MIN_WIDTH = 300
  MAP_COLLAPSED_WIDTH = 30

  COLLAPSE_DURATION = 250 #ms
