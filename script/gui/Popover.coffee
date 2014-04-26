window.HG ?= {}

class HG.Popover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      placement: "auto"
      content: undefined
      contentHTML: ""
      title: ""
      container: "body"

    @_config = $.extend {}, defaultConfig, config

    @_width = BODY_DEFAULT_WIDTH
    @_height = BODY_DEFAULT_HEIGHT

    @_mainDiv = document.createElement "div"
    @_mainDiv.className = "guiPopover"
    @_mainDiv.style.position = "absolute"
    @_mainDiv.style.left = "#{WINDOW_TO_ANCHOR_OFFSET_X}px"
    @_mainDiv.style.top = "#{WINDOW_TO_ANCHOR_OFFSET_Y}px"
    @_mainDiv.style.visibility = "hidden"

    @_topArrow = document.createElement "div"
    @_topArrow.className = "arrow arrow-up"

    @_bottomArrow = document.createElement "div"
    @_bottomArrow.className = "arrow arrow-down"

    @_rightArrow = document.createElement "div"
    @_rightArrow.className = "arrow arrow-right"

    @_leftArrow = document.createElement "div"
    @_leftArrow.className = "arrow arrow-left"

    titleDiv = document.createElement "h4"
    titleDiv.className = "guiPopoverTitle"
    titleDiv.innerHTML = @_config.title

    closeDiv = document.createElement "span"
    closeDiv.innerHTML = "×"
    closeDiv.addEventListener 'mouseup', @hide, false

    clearDiv = document.createElement "div"
    clearDiv.className = "clear"

    bodyDiv = document.createElement "div"
    bodyDiv.className = "guiPopoverBody"

    if @_config.content? or @_config.contentHTML isnt ""

      content = document.createElement "div"
      content.className = "guiPopoverContent"

      if @_config.content?
        content.appendChild @_config.content
      else
        content.innerHTML = @_config.contentHTML

      bodyDiv.appendChild content
      if content.offsetHeight < @_height
        bodyDiv.setAttribute "height", "#{@_height}px"

      if content.offsetWidth > @_width
        @_width = Math.min content.offsetWidth, BODY_MAX_WIDTH
        @_height = Math.min @_height, BODY_MAX_HEIGHT

    titleDiv.appendChild closeDiv
    titleDiv.appendChild clearDiv
    @_mainDiv.appendChild @_topArrow
    @_mainDiv.appendChild @_rightArrow
    @_mainDiv.appendChild @_leftArrow
    @_mainDiv.appendChild titleDiv
    @_mainDiv.appendChild bodyDiv
    @_mainDiv.appendChild @_bottomArrow

    @_parentDiv = $(@_config.container)[0]
    @_parentDiv.appendChild @_mainDiv

    @_centerPos =
      x: 0
      y: 0

    @_updateCenterPos()

  # ============================================================================
  toggle: (position) =>
    if @_mainDiv.style.visibility is "visible"
      @hide position
    else
      @show position

  # ============================================================================
  show: (position) =>
    @_mainDiv.style.visibility = "visible"
    @_mainDiv.style.opacity = 1.0

    @updatePosition position

  # ============================================================================
  hide: =>
    hideInfo = =>
      @_mainDiv.style.visibility = "hidden"

    window.setTimeout hideInfo, 200
    @_mainDiv.style.opacity = 0.0
    @_placement = undefined

  # ============================================================================
  updatePosition: (position) ->
    @_position = position
    @_updateCenterPos()
    @_updateWindowPos()

  # ============================================================================
  destroy: () ->
    @_mainDiv.parentNode.removeChild @_mainDiv

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _updateWindowPos: ->

    canvasOffset = $(@_parentDiv).offset()

    unless @_placement?
      if @_config.placement is "left"
        @_placement = {x:-1, y:0}
      else if @_config.placement is "right"
        @_placement = {x:1, y:0}
      else if @_config.placement is "top"
        @_placement = {x:0, y:-1}
      else if @_config.placement is "bottom"
        @_placement = {x:0, y:1}
      else if @_config.placement is "auto"
        @_placement = {x:1, y:0}

        margin =
          top : @_position.y
          left : @_position.x + canvasOffset.left
          bottom : @_parentDiv.offsetHeight - @_position.y
          right : @_parentDiv.offsetWidth - @_position.x

        neededWidth = @_width +
                      HGConfig.hivent_marker_2D_width.val / 2 +
                      HGConfig.hivent_info_popover_arrow_height.val

        neededHeight = @_mainDiv.offsetHeight +
                      HGConfig.hivent_marker_2D_height.val / 2 +
                      HGConfig.hivent_info_popover_arrow_height.val

        # if enough space on top
        if margin.top >= neededHeight

          # if enough space left and right
          if margin.left >= neededWidth*0.5 and margin.right >= neededWidth*0.5
            @_placement = {x:0, y:-1}

          # if enough space right
          else if margin.left <= neededWidth
            @_placement = {x:1, y:0}

          # if enough space left
          else if margin.right <= neededWidth
            @_placement = {x:-1, y:0}

        # if not enough space on top or bottom
        else if margin.bottom < neededHeight
          # if enough space right
          if margin.left <= neededWidth
            @_placement = {x:1, y:0}

          # if enough space left
          else if margin.right <= neededWidth
            @_placement = {x:-1, y:0}

        # if enough space on bottom
        else
          # if enough space left and right
          if margin.left >= neededWidth*0.5 and margin.right >= neededWidth*0.5
            @_placement = {x:0, y:1}

          # if enough space right
          else if margin.left <= neededWidth
            @_placement = {x:1, y:0}

          # if enough space left
          else if margin.right <= neededWidth
            @_placement = {x:-1, y:0}

      else
        @_placement = {x:0, y:-1}
        console.warn "Invalid popover placement: ", @_config.placement


    $(@_topArrow).css "display", if @_placement.y is 1 then "block" else "none"
    $(@_bottomArrow).css "display", if @_placement.y is -1 then "block" else "none"
    $(@_leftArrow).css "display", if @_placement.x is 1 then "block" else "none"
    $(@_rightArrow).css "display", if @_placement.x is -1 then "block" else "none"

    verticalArrowMargin = @_mainDiv.offsetHeight / 2 - HGConfig.hivent_info_popover_arrow_height.val / 2
    $(@_leftArrow).css "margin-top", "#{verticalArrowMargin}px"
    $(@_rightArrow).css "margin-top", "#{verticalArrowMargin}px"

    $(@_mainDiv).offset {
      left: @_position.x + canvasOffset.left +
            @_placement.x * (HGConfig.hivent_marker_2D_width.val / 2 + HGConfig.hivent_info_popover_arrow_height.val) +
            @_placement.x * ((@_width - @_width * @_placement.x) / 2) -
            Math.abs(@_placement.y) *  @_width / 2
      top:  @_position.y + canvasOffset.top +
            @_placement.y * (HGConfig.hivent_marker_2D_height.val / 2 + HGConfig.hivent_info_popover_arrow_height.val) +
            @_placement.y * ((@_mainDiv.offsetHeight - @_mainDiv.offsetHeight * @_placement.y) / 2) -
            Math.abs(@_placement.x) * @_mainDiv.offsetHeight / 2
    }


  # ============================================================================
  _updateCenterPos: ->
    parentOffset = $(@_parentDiv).offset()
    @_centerPos =
      x:@_mainDiv.offsetLeft + @_mainDiv.offsetWidth/2 - parentOffset.left + ARROW_ROOT_OFFSET_X
      y:@_mainDiv.offsetTop  + @_mainDiv.offsetHeight/2 - parentOffset.top + ARROW_ROOT_OFFSET_Y


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  ARROW_ROOT_OFFSET_X = 0
  ARROW_ROOT_OFFSET_Y = 0
  WINDOW_TO_ANCHOR_OFFSET_X = 0
  WINDOW_TO_ANCHOR_OFFSET_Y = 0
  BODY_DEFAULT_WIDTH = 350
  BODY_MAX_WIDTH = 400
  BODY_DEFAULT_HEIGHT = 300
  BODY_MAX_HEIGHT = 400

