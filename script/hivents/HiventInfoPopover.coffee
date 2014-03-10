window.HG ?= {}

class HG.HiventInfoPopover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, parentDiv, hgInstance) ->

    @_hiventHandle = hiventHandle
    @_parentDiv = parentDiv
    @_position = new HG.Vector(0, 0)
    @_contentLoaded = false
    @_placement = undefined
    @_hgInstance = hgInstance

    @_width = BODY_DEFAULT_WIDTH
    @_height = BODY_DEFAULT_HEIGHT

    @_mainDiv = document.createElement "div"
    @_mainDiv.className = "hiventInfoPopover"
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

    @_titleDiv = document.createElement "h4"
    @_titleDiv.className = "hiventInfoPopoverTitle"
    @_titleDiv.innerHTML = @_hiventHandle.getHivent().name

    @_closeDiv = document.createElement "span"
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

    @_hiventHandle.onDestruction @, @_destroy

  # ============================================================================
  show: (position) =>
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
        @_width = Math.min content.offsetWidth, BODY_MAX_WIDTH
        @_height = Math.min @_height, BODY_MAX_HEIGHT

      $("a[rel^='prettyPhoto']").prettyPhoto {
        animation_speed:'normal',
        theme:'light_square',
        slideshow:3000,
        autoplay_slideshow: false,
        hideflash: true
      }

      @_contentLoaded = true


    @_mainDiv.style.visibility = "visible"
    @_mainDiv.style.opacity = 1.0

    @updatePosition position

  # ============================================================================
  hide: =>
    hideInfo = =>
      @_mainDiv.style.visibility = "hidden"

    window.setTimeout hideInfo, 200
    @_mainDiv.style.opacity = 0.0
    @_hiventHandle._activated = false
    @_placement = undefined

  # ============================================================================
  updatePosition: (position) ->
    @_position = position.clone()
    @_updateCenterPos()
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
        top : @_position.at(1)
        left : @_position.at(0) + canvasOffset.left
        bottom : @_parentDiv.offsetHeight - @_position.at(1)
        right : @_parentDiv.offsetWidth - @_position.at(0)

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
      left: @_position.at(0) + canvasOffset.left +
            @_placement.at(0) * (HGConfig.hivent_marker_2D_width.val / 2 + HGConfig.hivent_info_popover_arrow_height.val) +
            @_placement.at(0) * ((@_width - @_width * @_placement.at(0)) / 2) -
            Math.abs(@_placement.at(1)) *  @_width / 2
      top:  @_position.at(1) +
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
  _destroy: () =>
    @_mainDiv.parentNode.removeChild @_mainDiv

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
