#include Hivent.coffee
#include Display.coffee
#include Vector.coffee

window.HG ?= {}

class HG.HiventInfoPopover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, anchor, parentDiv, hgInstance) ->

    @_hiventHandle = hiventHandle
    @_parentDiv = parentDiv
    @_anchor = anchor
    @_contentLoaded = false
    @_placement = undefined
    @_hgInstance = hgInstance

    # $(@_hgInstance.mapCanvas).mousewheel (e) =>
    # $(window).mousewheel (e) =>
    #   console.log "scroll"

    @_width = BODY_DEFAULT_WIDTH
    @_height = BODY_DEFAULT_HEIGHT

    @_mainDiv = document.createElement "div"
    @_mainDiv.className = "hiventInfoPopover"
    @_mainDiv.style.position = "absolute"
    @_mainDiv.style.left = "#{anchor.at(0) + WINDOW_TO_ANCHOR_OFFSET_X}px"
    @_mainDiv.style.top = "#{anchor.at(1) + WINDOW_TO_ANCHOR_OFFSET_Y}px"
    @_mainDiv.style.visibility = "hidden"
    @_mainDiv.addEventListener "mousedown", @_bringToFront, false

    @_topArrow = document.createElement "div"
    @_topArrow.className = "arrow arrow-up"

    @_bottomArrow = document.createElement "div"
    @_bottomArrow.className = "arrow arrow-down"

    @_rightArrow = document.createElement "div"
    @_rightArrow.className = "arrow arrow-right"

    @_leftArrow = document.createElement "div"
    @_leftArrow.className = "arrow arrow-left"

    @_titleDiv = document.createElement "h4"
    @_titleDiv.className = "hiventInfoPopoverTitle"
    @_titleDiv.innerHTML = @_hiventHandle.getHivent().name
    # @_titleDiv.addEventListener 'mousedown', @_onMouseDown, false

    @_closeDiv = document.createElement "span"
    # @_closeDiv.className = "close"
    @_closeDiv.innerHTML = "×"
    @_closeDiv.addEventListener 'mouseup', @hide, false

    @_bodyDiv = document.createElement "div"
    @_bodyDiv.className = "hiventInfoPopoverBody"

    @_titleDiv.appendChild @_closeDiv
    @_mainDiv.appendChild @_topArrow
    @_mainDiv.appendChild @_rightArrow
    @_mainDiv.appendChild @_leftArrow
    @_mainDiv.appendChild @_titleDiv
    @_mainDiv.appendChild @_bodyDiv
    @_mainDiv.appendChild @_bottomArrow

    @_parentDiv.appendChild @_mainDiv

    @_centerPos = new HG.Vector 0, 0
    @_updateCenterPos()

    # @_raphael = Raphael @_parentDiv, @_parentDiv.offsetWidth, @_parentDiv.offsetHeight
    # @_raphael.canvas.style.position = "absolute"
    # @_raphael.canvas.style.zIndex = "#{HG.Display.Z_INDEX + 9}"
    # @_raphael.canvas.style.pointerEvents = "none"
    # @_raphael.canvas.style.visibility = "hidden"
    # @_raphael.canvas.style.opacity = 0
    # @_raphael.canvas.className.baseVal = "hiventInfoArrow"

    # @_arrow = @_raphael.path ""
    @_updateArrow()

    @_lastMousePos = null

    @_hiventHandle.onDestruction @, @_destroy

  # ============================================================================
  show: =>
    unless @_contentLoaded

      #check whether location is set
      locationString = ''
      if @_hiventHandle.getHivent().locationName != ''
        locationString = @_hiventHandle.getHivent().locationName + ', '

      subheading = document.createElement "h3"
      subheading.innerHTML = locationString + @_hiventHandle.getHivent().displayDate
      @_bodyDiv.appendChild subheading

      gotoDate = document.createElement "i"
      gotoDate.className = "fa fa-clock-o"
      $(gotoDate).tooltip {title: "Springe zum Ereignisdatum", placement: "right", container:"#histoglobe"}
      $(gotoDate).click () =>
        @_hgInstance.timeline.moveToDate @_hiventHandle.getHivent().startDate, 0.5
      subheading.appendChild gotoDate

      content = document.createElement "div"
      content.className = "hiventInfoPopoverContent"
      content.innerHTML = @_hiventHandle.getHivent().content
      @_bodyDiv.appendChild content
      if content.offsetHeight < @_height
        @_bodyDiv.setAttribute "height", "#{@_height}px"

      if content.offsetWidth > @_width
        @_resize(content.offsetWidth, @_height)

      $("a[rel^='prettyPhoto']").prettyPhoto {
        animation_speed:'normal',
        theme:'light_square',
        slideshow:3000,
        autoplay_slideshow: false,
        hideflash: true
      }

      @_contentLoaded = true

    @_mainDiv.style.visibility = "visible"
    # @_raphael.canvas.style.overlayPanevisibility = "visible"

    showArrow = =>
      @_raphael.canvas.style.opacity = 1.0

    @_bringToFront()
    @_mainDiv.style.opacity = 1.0
    # window.setTimeout showArrow, 200

  # ============================================================================
  hide: =>
    hideInfo = =>
      @_mainDiv.style.visibility = "hidden"

    hideArrow = =>
      @_mainDiv.style.opacity = 0.0
      # @_raphael.canvas.style.visibility = "hidden"
      window.setTimeout hideInfo, 200


    # @_raphael.canvas.style.opacity = 0.0
    window.setTimeout hideArrow, 100
    @_hiventHandle._activated = false
    @_placement = undefined

  # ============================================================================
  positionWindowAtAnchor: ->
    @_updateWindowPos()
    @_updateCenterPos()
    @_updateArrow()

  # ============================================================================
  setAnchor: (anchor) ->
    @_anchor = anchor.clone()
    @_updateWindowPos()

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _updateWindowPos: ->

    canvasOffset = $(@_parentDiv).offset()

    unless @_placement?
      @_placement = new HG.Vector 0, -1

      anchorOffset =
        top : @_anchor.at(1)
        left : @_anchor.at(0) + canvasOffset.left
        bottom : @_parentDiv.offsetHeight - @_anchor.at(1)
        right : @_parentDiv.offsetWidth - @_anchor.at(0)

      neededWidth = @_width +
                    HGConfig.hivent_marker_2D_width.val / 2 +
                    HGConfig.hivent_info_popover_arrow_height.val

      neededHeight = @_mainDiv.offsetHeight +
                    HGConfig.hivent_marker_2D_height.val / 2 +
                    HGConfig.hivent_info_popover_arrow_height.val

      if anchorOffset.top >= neededHeight
        if anchorOffset.left >= neededWidth / 2 and
           anchorOffset.right >= neededWidth / 2
          @_placement = new HG.Vector 0, -1

        else if anchorOffset.left <= neededWidth
          @_placement = new HG.Vector 1, 0

        else if anchorOffset.right <= neededWidth
          @_placement = new HG.Vector -1, 0

      else
        if anchorOffset.left >= neededWidth / 2 and
           anchorOffset.right >= neededWidth / 2
          @_placement = new HG.Vector 0, 1

        else if anchorOffset.left <= neededWidth
          @_placement = new HG.Vector 1, 0

        else if anchorOffset.right <= neededWidth
          @_placement = new HG.Vector -1, 0

      $(@_topArrow).css "display", if @_placement.at(1) is 1 then "block" else "none"
      $(@_bottomArrow).css "display", if @_placement.at(1) is -1 then "block" else "none"
      $(@_leftArrow).css "display", if @_placement.at(0) is 1 then "block" else "none"
      $(@_rightArrow).css "display", if @_placement.at(0) is -1 then "block" else "none"

      verticalArrowMargin = @_mainDiv.offsetHeight / 2 - HGConfig.hivent_info_popover_arrow_height.val / 2
      $(@_leftArrow).css "margin-top", "#{verticalArrowMargin}px"
      $(@_rightArrow).css "margin-top", "#{verticalArrowMargin}px"

    $(@_mainDiv).offset {
      left: @_anchor.at(0) + canvasOffset.left +
            @_placement.at(0) * (HGConfig.hivent_marker_2D_width.val / 2 + HGConfig.hivent_info_popover_arrow_height.val) +
            @_placement.at(0) * ((@_width - @_width * @_placement.at(0)) / 2) -
            Math.abs(@_placement.at(1)) *  @_width / 2
      top:  @_anchor.at(1) +
            @_placement.at(1) * (HGConfig.hivent_marker_2D_height.val / 2 + HGConfig.hivent_info_popover_arrow_height.val) +
            @_placement.at(1) * ((@_mainDiv.offsetHeight - @_mainDiv.offsetHeight * @_placement.at(1)) / 2) -
            Math.abs(@_placement.at(0)) * @_mainDiv.offsetHeight / 2
    }


  # ============================================================================
  _updateCenterPos: ->
    parentOffset = $(@_parentDiv).offset()
    @_centerPos = new HG.Vector(@_mainDiv.offsetLeft + @_mainDiv.offsetWidth/2 -
                                parentOffset.left + ARROW_ROOT_OFFSET_X,
                                @_mainDiv.offsetTop  + @_mainDiv.offsetHeight/2 -
                                parentOffset.top + ARROW_ROOT_OFFSET_Y)

  # ============================================================================
  _resize: (width, height) ->
    @_width = Math.min width, BODY_MAX_WIDTH
    @_height = Math.min height, BODY_MAX_HEIGHT

  # ============================================================================
  _updateArrow: ->
    # centerToAnchor = @_anchor.clone()
    # centerToAnchor.sub @_centerPos
    # centerToAnchor.normalize()
    # ortho = new HG.Vector -centerToAnchor.at(1), centerToAnchor.at(0)
    # ortho.mulScalar ARROW_ROOT_WIDTH/2
    # arrowRight = @_centerPos.clone()
    # arrowRight.add ortho
    # arrowLeft = @_centerPos.clone()
    # arrowLeft.sub ortho

    # @_arrow.attr "path", "M #{@_centerPos.at 0} #{@_centerPos.at 1}
    #                       L #{arrowRight.at 0} #{arrowRight.at 1}
    #                       L #{@_anchor.at 0} #{@_anchor.at 1}
    #                       L #{arrowLeft.at 0} #{arrowLeft.at 1}
    #                       Z"
    # @_arrow.attr "fill", "#fff"
    # @_arrow.attr "stroke", "#fff"

  # ============================================================================
  _onMouseDown: (event) =>
    event.preventDefault()
    @_titleDiv.addEventListener 'mousemove', @_onMouseMove, false
    @_titleDiv.addEventListener 'mouseup', @_onMouseUp, false
    @_titleDiv.addEventListener 'mouseout', @_onMouseOut, false
    @_titleDiv.className = "hiventInfoPopoverTitle grab"

  # ============================================================================
  _onMouseUp: (event) =>
    event.preventDefault()
    @_titleDiv.removeEventListener 'mousemove', @_onMouseMove, false
    @_titleDiv.removeEventListener 'mouseup', @_onMouseUp, false
    @_titleDiv.removeEventListener 'mouseout', @_onMouseOut, false
    @_titleDiv.className = "hiventInfoPopoverTitle"
    @_lastMousePos = null

  # ============================================================================
  _onMouseMove: (event) =>
    event.preventDefault()
    currentMousePos = new HG.Vector event.clientX, event.clientY

    @_lastMousePos ?= currentMousePos

    currentDivPos = $(@_mainDiv).offset()
    $(@_mainDiv).offset {
                     left: currentDivPos.left + (currentMousePos.at(0) - @_lastMousePos.at(0))
                     top:  currentDivPos.top + (currentMousePos.at(1) - @_lastMousePos.at(1))
                    }

    @_updateCenterPos()
    @_updateArrow()
    @_lastMousePos = currentMousePos

  # ============================================================================
  _onMouseOut: (event) =>
    @_titleDiv.removeEventListener 'mousemove', @_onMouseMove, false
    @_titleDiv.removeEventListener 'mouseup', @_onMouseUp, false
    @_titleDiv.removeEventListener 'mouseout', @_onMouseOut, false
    @_titleDiv.className = "hiventInfoPopoverTitle"
    @_lastMousePos = null

  # ============================================================================
  _bringToFront: () =>
    @_mainDiv.style.zIndex = "#{HG.Display.Z_INDEX + 10 + LAST_Z_INDEX}"
    LAST_Z_INDEX++

  # ============================================================================
  _destroy: () =>
    @_mainDiv.parentNode.removeChild @_mainDiv
    # @_raphael.canvas.parentNode.removeChild @_raphael.canvas

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  ARROW_ROOT_WIDTH = 30
  ARROW_ROOT_OFFSET_X = 0
  ARROW_ROOT_OFFSET_Y = 0
  WINDOW_TO_ANCHOR_OFFSET_X = 0
  WINDOW_TO_ANCHOR_OFFSET_Y = 0
  WINDOW_MARGIN = 40
  BODY_DEFAULT_WIDTH = 350
  BODY_MAX_WIDTH = 400
  BODY_DEFAULT_HEIGHT = 300
  BODY_MAX_HEIGHT = 400
  TITLE_DEFAULT_HEIGHT = 20
  LAST_Z_INDEX = 0
