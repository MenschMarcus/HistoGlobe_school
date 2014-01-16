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

    @_addWidget "Vorstand"
    @_addWidget "Wichtige Ereignisse"
    @_addWidget "Legende"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createLayout: ->

    # base layout
    @_sidebar_area = document.createElement "div"



    $(@_sidebar_area).click (e) =>
      if e.target is @_sidebar_area
        console.log "y"
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

  # ============================================================================
  _addWidget: (name) ->
    widget = document.createElement "div"
    widget.className = "widgetContainer"
    @_sidebar_area.appendChild widget

    # header -------------------------------------------------------------------
    header = document.createElement "div"
    header.className = "widgetHeader"
    widget.appendChild header

    $(header).click () ->
      body = @.nextSibling

      $(@).toggleClass("collapsed")

      if $(@).hasClass("collapsed")
        $(body).animate
          height: 0
        , 300

      else
        $(body).css
          "height": "auto"

        targetHeight = $(body).height()

        $(body).css
          "height": 0

        $(body).animate
          height: targetHeight
        , 300, () ->
          $(body).css
            "height": "auto"

    # icon
    icon_container = document.createElement "div"
    icon_container.className = "iconContainer"
    $(icon_container).click @_collapse
    header.appendChild icon_container

    icon = document.createElement "i"
    icon.className = "fa fa-fw fa-pagelines"
    icon_container.appendChild icon

    title_top = document.createElement "div"
    title_top.className = "topTitleContainer"
    title_top.innerHTML = name
    header.appendChild title_top

    # collapse button
    collapse_button_container = document.createElement "div"
    collapse_button_container.className = "collapseButtonContainer"
    header.appendChild collapse_button_container

    collapse_button = document.createElement "i"
    collapse_button.className = "fa fa-chevron-down widgetCollapseItem"
    collapse_button_container.appendChild collapse_button

    # body ---------------------------------------------------------------------
    body_collapsable = document.createElement "div"
    widget.appendChild body_collapsable

    body_table = document.createElement "table"
    body_collapsable.appendChild body_table

    body = document.createElement "tr"
    body_table.appendChild body

    # title
    title_container = document.createElement "td"
    title_container.className = "verticalTitleContainer"
    $(title_container).click @_collapse
    body.appendChild title_container

    title_container_inner = document.createElement "div"
    title_container_inner.className = "verticalText"
    title_container.appendChild title_container_inner

    title = document.createElement "div"
    title.className = "verticalTextInner"
    title.innerHTML = name
    title_container_inner.appendChild title

    # content
    content = document.createElement "td"
    content.className = "widgetBody"
    content.innerHTML = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Aldus PageMaker including versions of Lorem Ipsum."
    body.appendChild content


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  SIDEBAR_MIN_WIDTH = 400
  SIDEBAR_COLLAPSED_WIDTH = 48

  MAP_MIN_WIDTH = 300
  MAP_COLLAPSED_WIDTH = 30
