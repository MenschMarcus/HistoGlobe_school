window.HG ?= {}

class HG.HistoGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container) ->

    @_container = container

    @_createLayout()

    @_createMap()

    widget = new HG.TextWidget(@_sidebar_area, "fa-tags", "Vorstand", "Jimmy Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
    widget = new HG.TextWidget(@_sidebar_area, "fa-stop", "Toller Stuff", "Lorem ipsum")
    widget = new HG.TextWidget(@_sidebar_area, "fa-star", "Lorem Ipsum", "Jimmy Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
    widget = new HG.TextWidget(@_sidebar_area, "fa-gift", "Legende", "Gaaay!")


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createLayout: ->
    # base layout
    @_sidebar_area = document.createElement "div"

    $(@_sidebar_area).click (e) =>
      if e.target is @_sidebar_area or
         $(e.target).hasClass("collapseOnClick") or
         $(e.target).parents(".collapseOnClick").length isnt 0

        @_collapse()

    @_sidebar_area.id = "sidebarArea"
    @_container.appendChild @_sidebar_area

    @_map_area = document.createElement "div"
    @_map_area.id = "mapArea"
    @_container.appendChild @_map_area

    @_timeline_area = document.createElement "div"
    @_timeline_area.id = "timelineArea"
    @_container.appendChild @_timeline_area


    # collapse button
    @_collapse_button = document.createElement "i"
    @_collapse_button.id = "collapseButton"
    @_collapse_button.className = "fa fa-arrow-circle-o-left fa-2x"
    @_container.appendChild @_collapse_button

    @_collapsed = @_isInMobileMode()
    @_updateLayout()

    $(@_collapse_button).click @_collapse
    $(window).on 'resize', @_updateLayout

  # ============================================================================
  _createMap: () ->

  # ============================================================================
  _collapse: =>
    @_collapsed = not @_collapsed
    @_updateLayout()

  # ============================================================================
  _updateLayout: =>
    width = window.innerWidth

    if @_isInMobileMode()
      @_sidebar_area.style.width = "#{width - MAP_COLLAPSED_WIDTH}px"
      @_map_area.style.width = "#{width-SIDEBAR_COLLAPSED_WIDTH}px"

    else
      @_sidebar_area.style.width = "#{SIDEBAR_MIN_WIDTH}px"
      @_map_area.style.width = "#{width-SIDEBAR_COLLAPSED_WIDTH}px"

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


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  SIDEBAR_MIN_WIDTH = 400
  SIDEBAR_COLLAPSED_WIDTH = 53

  MAP_MIN_WIDTH = 300
  MAP_COLLAPSED_WIDTH = 30
