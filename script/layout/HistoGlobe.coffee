window.HG ?= {}

class HG.HistoGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container) ->

    @_container = container

    @_createSidebar()
    @_createMap()
    @_createTimeline()
    @_createCollapseButton()

    @_collapsed = @_isInMobileMode()

    $(window).on 'resize', @_updateLayout

    widget = new HG.TextWidget(@_sidebar_area, "fa-tags", "Vorstand", "Jimmy Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
    widget = new HG.TextWidget(@_sidebar_area, "fa-stop", "Toller Stuff", "Lorem ipsum")
    widget = new HG.PictureWidget(@_sidebar_area, "fa-gift", "Legende", "http://extreme.pcgameshardware.de/members/-painkiller--albums-einfach-lustig-3209-picture361371-incoming.jpg")
    widget = new HG.TextWidget(@_sidebar_area, "fa-star", "Lorem Ipsum", "Jimmy Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
    widget = new HG.TextWidget(@_sidebar_area, "fa-star", "Lorem Ipsum", "Jimmy Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
    widget = new HG.TextWidget(@_sidebar_area, "fa-star", "Lorem Ipsum", "Jimmy Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")

    @_updateLayout()


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createSidebar: ->
    @_sidebar_area = @_createElement "div", "sidebarArea"

    scrollbar = document.createElement "div"
    scrollbar.className = "swiper-scrollbar"
    @_sidebar_area.appendChild scrollbar

    $(@_sidebar_area).click (e) =>
      if e.target is @_sidebar_area or
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
    @_map_area = @_createElement "div", "mapArea"

  # ============================================================================
  _createTimeline: ->
    @_timeline_area = @_createElement "div", "timelineArea"

  # ============================================================================
  _collapse: =>
    @_collapsed = not @_collapsed
    @_updateLayout()

  # ============================================================================
  _updateLayout: =>

    width = window.innerWidth

    # update width of sidebar and map if in mobile mode
    if @_isInMobileMode()
      @_sidebar_area.style.width = "#{width - MAP_COLLAPSED_WIDTH}px"
      @_map_area.style.width = "#{width-SIDEBAR_COLLAPSED_WIDTH}px"

    else
      @_sidebar_area.style.width = "#{SIDEBAR_MIN_WIDTH}px"
      @_map_area.style.width = "#{width-SIDEBAR_COLLAPSED_WIDTH}px"


    # update div positions if collapsed or uncollapsed
    if @_collapsed
      @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"
      @_map_area.style.right = "#{SIDEBAR_COLLAPSED_WIDTH}px"
      @_collapse_button.style.right = "#{SIDEBAR_COLLAPSED_WIDTH}px"

      if @_isInMobileMode()
        @_sidebar_area.style.right = "#{SIDEBAR_COLLAPSED_WIDTH - width + MAP_COLLAPSED_WIDTH}px"
      else
        @_sidebar_area.style.right = "#{SIDEBAR_COLLAPSED_WIDTH - SIDEBAR_MIN_WIDTH}px"

    else
      @_collapse_button.className = "fa fa-arrow-circle-o-right fa-2x"
      @_sidebar_area.style.right = "0px"

      if @_isInMobileMode()
        @_map_area.style.right = "#{width - MAP_COLLAPSED_WIDTH}px"
        @_collapse_button.style.right = "#{width - MAP_COLLAPSED_WIDTH}px"

      else
        @_map_area.style.right = "#{SIDEBAR_MIN_WIDTH}px"
        @_collapse_button.style.right = "#{SIDEBAR_MIN_WIDTH}px"

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
