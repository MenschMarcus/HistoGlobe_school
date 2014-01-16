window.HG ?= {}

class HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container) ->
    @_container = container
    @_createLayout()

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
    widget = document.createElement "div"
    widget.className = "widgetContainer"
    @_container.appendChild widget

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
    header.appendChild icon_container

    @_icon = document.createElement "i"
    icon_container.appendChild @_icon

    @_title_top = document.createElement "div"
    @_title_top.className = "topTitleContainer"
    header.appendChild @_title_top

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
    title_container.className = "verticalTitleContainer collapseOnClick"
    body.appendChild title_container

    title_container_inner = document.createElement "div"
    title_container_inner.className = "verticalText"
    title_container.appendChild title_container_inner

    @_title = document.createElement "div"
    @_title.className = "verticalTextInner"
    @_title.innerHTML = name
    title_container_inner.appendChild @_title

    # content
    @_content = document.createElement "td"
    @_content.className = "widgetBody"
    body.appendChild @_content

    @setName "New Widget"
    @setIcon "fa-star"
