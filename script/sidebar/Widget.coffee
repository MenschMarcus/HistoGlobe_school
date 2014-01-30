window.HG ?= {}

class HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  hgInit: (hgInstance) ->
    @_createLayout()
    hgInstance.sidebar.addWidget @

  # ============================================================================
  setName: (title) ->
    @_title.innerHTML = title
    @_title_top.innerHTML = title

  # ============================================================================
  setIcon: (icon) ->
    @_icon.className = "fa fa-fw " + icon

  # ============================================================================
  setContent: (div) ->
    $(@_content).empty()
    @_content.appendChild div

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _createLayout: () ->
    @container = document.createElement "div"
    @container.className = "widgetContainer"

    # header -------------------------------------------------------------------
    @_header = document.createElement "div"
    @_header.className = "widgetHeader"
    @container.appendChild @_header

    # icon
    icon_container = document.createElement "div"
    icon_container.className = "iconContainer collapseOnClick"
    @_header.appendChild icon_container

    @_icon = document.createElement "i"
    icon_container.appendChild @_icon

    @_title_top = document.createElement "div"
    @_title_top.className = "topTitleContainer"
    @_header.appendChild @_title_top


    # collapse button
    collapse_button_container = document.createElement "div"
    collapse_button_container.className = "collapseButtonContainer"
    @_header.appendChild collapse_button_container

    collapse_button = document.createElement "i"
    collapse_button.className = "fa fa-chevron-down widgetCollapseItem"
    collapse_button_container.appendChild collapse_button

    $(@_title_top).click @_collapse
    $(collapse_button_container).click @_collapse

    # body ---------------------------------------------------------------------
    body_collapsable = document.createElement "div"
    body_collapsable.className = "collapsable"
    @container.appendChild body_collapsable

    # title
    title_container = document.createElement "div"
    title_container.className = "verticalTitleContainer collapseOnClick"
    body_collapsable.appendChild title_container

    @_title = document.createElement "div"
    @_title.className = "verticalTextInner"
    @_title.innerHTML = name
    title_container.appendChild @_title

    # content
    @_content = document.createElement "div"
    @_content.className = "widgetBody"
    body_collapsable.appendChild @_content

    @setName "New Widget"
    @setIcon "fa-star"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _collapse: () =>
    body = @_header.nextSibling

    $(@_header).toggleClass("collapsed")

    if $(@_header).hasClass("collapsed")
      $(body).animate
        height: 0
      , WIDGET_ANIMATION_SPEED * 1000

    else
      $(body).css
        "height": "auto"

      targetHeight = $(body).height()

      $(body).css
        "height": 0

      $(body).animate
        height: targetHeight
      , WIDGET_ANIMATION_SPEED * 1000, () =>
        $(body).css
          "height": "auto"


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  WIDGET_ANIMATION_SPEED = 0.3
