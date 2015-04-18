window.HG ?= {}

class HG.Popover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onResize"
    @addCallback "onClose"

    defaultConfig =
      hgInstance: undefined
      hiventHandle: undefined
      placement: "top"
      content: undefined
      contentHTML: ""
      title: ""
      container: "body"
      showArrow: false
      fullscreen: false

    @_config = $.extend {}, defaultConfig, config

    @_hgInstance = @_config.hgInstance
    @_hiventHandle = @_config.hiventHandle
    @_multimediaController = @_config.hgInstance.multimediaController
    @_multimedia = @_hiventHandle.getHivent().multimedia
    @_mode = @_hgInstance.abTest.config.hiventMarkerMode

    # ============================================================================
    @_screenWidth = @_config.hgInstance.getMapAreaSize().x
    @_screenHeight = @_config.hgInstance.getMapAreaSize().y

    @_width = BODY_DEFAULT_WIDTH
    @_height = BODY_DEFAULT_HEIGHT

    @_map_size = @_config.hgInstance.getMapAreaSize()

    @_widthFSBox = @_map_size.x - HIVENTLIST_OFFSET #- FULLSCREEN_BOX_LEFT_OFFSET
    @_heightFSBox = 0.82 * @_map_size.y

    @_mainDiv = document.createElement "div"
    @_mainDiv.className = "guiPopover"

    @_mainDiv.style.position = "absolute"
    @_mainDiv.style.top = "#{WINDOW_TO_ANCHOR_OFFSET_Y}px"
    @_mainDiv.style.visibility = "hidden"

    if @_config.fullscreen
      $(@_mainDiv).addClass("fullscreen")
    else
      @_mainDiv.style.left = "#{WINDOW_TO_ANCHOR_OFFSET_X}px"

    # Big HiventBox ===================================================
    @_bodyDivBig = document.createElement "div"
    @_bodyDivBig.className = "guiPopoverBodyBig"
    @_bodyDivBig.style.width = "#{0.6 * @_widthFSBox}px"
    @_bodyDivBig.style.height = "#{@_heightFSBox}px"

    contentBig = document.createElement "div"
    contentBig.className = "guiPopoverContentBig"
    contentBig.style.width = "#{0.4 * @_widthFSBox}px"
    contentBig.style.height = "#{@_heightFSBox}px"

    sourceBig = document.createElement "span"
    sourceBig.className = "source-big"
    #sourceBig.innerHTML = 'Quelle: ' + @_imgSource

    linkListBig = document.createElement "div"
    linkListBig.className = "info-links-big"

    linkListBig.appendChild sourceBig
    @_bodyDivBig.appendChild linkListBig

    # generate content for big HiventBox ==============================
    bodyBig = document.createElement "div"
    bodyBig.className = "hivent-body-big"

    titleDivBig = document.createElement "h4"
    titleDivBig.className = "guiPopoverTitleBig"
    titleDivBig.innerHTML = @_config.hiventHandle.getHivent().name
    bodyBig.appendChild titleDivBig

    textBig = document.createElement "div"
    textBig.className = "hivent-content-big"

    descriptionBig = @_config.hiventHandle.getHivent().description
    textBig.innerHTML = descriptionBig

    bodyBig.appendChild textBig
    contentBig.appendChild bodyBig

    locationStringBig = @_config.hiventHandle.getHivent().locationName[0] + ', '

    dateBig = document.createElement "span"
    dateBig.innerHTML = ' - ' + locationStringBig + @_config.hiventHandle.getHivent().displayDate #+ ' '
    textBig.appendChild dateBig

    gotoDateBig = document.createElement "i"
    gotoDateBig.className = "fa fa-clock-o"
    $(gotoDateBig).tooltip {title: "Springe zum Ereignisdatum", placement: "right", container:"#histoglobe"}
    gotoDateBig.addEventListener 'mouseup', () =>
      @_hgInstance.timeline.moveToDate @_config.hiventHandle.getHivent().startDate, 0.5
    dateBig.appendChild gotoDateBig

    # =================================================================
    @_bodyDiv = document.createElement "div"
    @_bodyDiv.className = "guiPopoverBodyV1"

    source = document.createElement "span"
    source.className = "source"
    #source.innerHTML = 'Quelle: ' + @_imgSource

    linkList = document.createElement "div"
    linkList.className = "info-links"

    linkList.appendChild source
    @_bodyDiv.appendChild linkList

    closeDiv = document.createElement "div"
    closeDiv.className = "close-button"

    # closeDiv = document.createElement "span"
    # closeDiv.className = "close-button"
    # closeDiv.innerHTML = "×"
    # closeDiv.style.color = "#D5C900"

    @_expandBox = document.createElement "div"
    @_expandBox.className = "expand2FS"
    @_expandBox.innerHTML = '<i class="fa fa-expand"></i>'
    # $(expandBox).tooltip {title: "Box vergrößern", placement: "left", container:"#histoglobe"}

    @_compressBox = document.createElement "div"
    @_compressBox.className = "compress2Normal"
    @_compressBox.innerHTML = '<i class="fa fa-compress"></i>'
    # $(compressBox).tooltip {title: "Zurück zur normalen Ansicht", placement: "left", container:"#histoglobe"}

    # ============================================================================

    if @_config.fullscreen
      $(@_bodyDiv).addClass("fullscreen")

    if @_config.content? or @_config.contentHTML isnt ""

      content = document.createElement "div"
      content.className = "guiPopoverContent"

      if @_config.content?
        content.appendChild @_config.content
      else
        content.innerHTML = @_config.contentHTML

      @_bodyDiv.appendChild content
      if content.offsetHeight < @_height
        @_bodyDiv.setAttribute "height", "#{@_height}px"

      if content.offsetWidth > @_width
        @_width = Math.min content.offsetWidth, BODY_MAX_WIDTH
        @_height = Math.min @_height, BODY_MAX_HEIGHT

    @_mainDiv.appendChild closeDiv
    @_mainDiv.appendChild @_bodyDiv
    @_bodyDivBig.appendChild contentBig

    @_parentDiv = $(@_config.container)[0]
    @_parentDiv.appendChild @_mainDiv

    @_centerPos =
      x: 0
      y: 0

    @_updateCenterPos()

    if @_config.fullscreen
      size = @_config.hgInstance.getMapAreaSize()
      @_onContainerSizeChange size

      @_config.hgInstance.onMapAreaSizeChangeEnd @, (width) =>
        if @_mainDiv.style.visibility is "visible"
          @_onContainerWidthChange width

      $(window).on 'resize', () =>
        if @_mainDiv.style.visibility is "visible"
          @updateSize()

  # ============================================================================

    $(".guiPopover").draggable()

    $(@_mainDiv).fadeIn(1000)

    @_mainDiv.style.height = "250px"  # #{@_height}"

    @_mainDiv.style.background = "#fff"
    @_bodyDiv.style.color = "#000"

  # ============================================================================

    if @_multimedia != "" and @_multimediaController?
      mmids = @_multimedia.split ","

      @_multimediaController.onMultimediaLoaded () =>

          for id in mmids
            id = id.trim() # removes whitespaces
            mm = @_multimediaController.getMultimediaById id

            if mm?

              if mm.type is "WEBIMAGE"
                console.log mm
                link = mm.link
                imgSource = mm.source

                @_mainDiv.style.height = "350px"
                @_mainDiv.style.backgroundImage = "url( #{link} )"
                @_mainDiv.style.backgroundSize = "cover"
                @_mainDiv.style.backgroundRepeat = "no-repeat"
                @_mainDiv.style.backgroundPosition = "center center"
                @_bodyDiv.className = "guiPopoverBodyV2"
                @_bodyDiv.style.height = "250px"
                @_bodyDiv.style.color = "#fff"
                #closeDiv.style.color = "#D5C900"

                source.innerHTML = 'Quelle: ' + imgSource
                sourceBig.innerHTML = 'Quelle: ' + imgSource

                @_mainDiv.appendChild @_expandBox
                @_bodyDivBig.style.color = "#fff"

  # ============================================================================

    @_expandBox.addEventListener 'mouseup', () =>
      @expand()
      @_mainDiv.replaceChild @_compressBox, @_expandBox

    @_compressBox.addEventListener 'mouseup', () =>
      @compress()
      @_mainDiv.replaceChild @_expandBox, @_compressBox

    closeDiv.addEventListener 'mouseup', () =>
      @hide()
      @close()
      @notifyAll "onClose"
    , false

  # ============================================================================
  expand: () ->
    @_mainDiv.className = "guiPopoverBig"
    @_mainDiv.style.pointerEvents = "none"
    @_mainDiv.style.width = "#{@_widthFSBox}px"
    @_mainDiv.style.height = "#{@_heightFSBox}px"
    @_mainDiv.style.top = "#{FULLSCREEN_BOX_TOP_OFFSET}px"
    @_mainDiv.style.left = "#{FULLSCREEN_BOX_LEFT_OFFSET}px"
    $(@_mainDiv).unbind('drag')

    @_mainDiv.replaceChild @_bodyDivBig, @_bodyDiv

  # ============================================================================
  compress: () ->
    @_mainDiv.className = "guiPopover"
    @_mainDiv.style.pointerEvents = "all"
    @_mainDiv.style.width = "#{@_width}px"
    @_mainDiv.style.height = "#{@_height}px"
    $(@_mainDiv).offset
      left: @_screenWidth / 2 - 0.74 * @_width
      top: @_screenHeight / 2 - 0.73 * @_height
    $(@_mainDiv).bind('drag')

    @_mainDiv.replaceChild @_bodyDiv, @_bodyDivBig

  # ============================================================================
  close: () ->
    if document.contains(@_bodyDivBig)
      @_mainDiv.removeChild @_bodyDivBig
      @_mainDiv.appendChild @_bodyDiv
      @_mainDiv.className = "guiPopover"
      @_mainDiv.style.width = "#{@_width}px"
      @_mainDiv.style.height = "#{@_height}px"
      @_mainDiv.replaceChild @_expandBox, @_compressBox

  # ============================================================================
  toggle: (position) =>
    if @_mainDiv.style.visibility is "visible"
      @hide position
    else
      @show position

  # ============================================================================
  show: (position) =>
    if @_config.fullscreen
      @updateSize()
    @_mainDiv.style.visibility = "visible"
    @_mainDiv.style.opacity = 1.0

    @updatePosition position

  # ============================================================================
  hide: =>
    # hideInfo = =>
      # @_mainDiv.style.visibility = "hidden"

    # window.setTimeout hideInfo, 200
    @_mainDiv.style.visibility = "hidden"
    @_mainDiv.style.opacity = 0.0
    @_placement = undefined

    if document.contains(@_bodyDivBig)
      @_mainDiv.removeChild @_bodyDivBig
      @_mainDiv.appendChild @_bodyDiv
      @_mainDiv.className = "guiPopover"
      @_mainDiv.style.width = "#{@_width}px"
      @_mainDiv.style.height = "#{@_height}px"
      @_mainDiv.replaceChild @_expandBox, @_compressBox


  # ============================================================================
  updatePosition: (position) ->
    @_position = position
    @_updateCenterPos()
    @_updateWindowPos()

  # ============================================================================
  updateSize:() ->
    size = @_config.hgInstance.getMapAreaSize()
    @_onContainerSizeChange size

  # ============================================================================
  destroy: () ->
    @_mainDiv.parentNode.removeChild @_mainDiv

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _onContainerSizeChange:(size) =>
    @_mainDiv.style.width = size.x-150 + "px"
    @_bodyDiv.style.maxHeight = size.y-200 + "px"

    @notifyAll "onResize"

  # ============================================================================
  _onContainerWidthChange:(width) =>
    @_mainDiv.style.width = width-150 + "px"

    @notifyAll "onResize"

  # ============================================================================
  _updateWindowPos: ->

    canvasOffset = $(@_parentDiv).offset()

    unless @_placement?
      if @_config.placement is "top"
        @_placement = {x:0, y:-1}

      else
        @_placement = {x:0, y:-1}
        console.warn "Invalid popover placement: ", @_config.placement

    if @_mode is "A"
      # default behavior
      $(@_mainDiv).offset
        left: @_position.x + canvasOffset.left +
              @_placement.x * (HGConfig.hivent_marker_2D_width.val / 2 + HGConfig.hivent_info_popover_arrow_height.val) +
              @_placement.x * ((@_width - @_width * @_placement.x) / 2) -
              Math.abs(@_placement.y) *  @_width / 2

        top:  @_position.y + canvasOffset.top +
              @_placement.y * (HGConfig.hivent_marker_2D_height.val / 2 + HGConfig.hivent_info_popover_arrow_height.val) +
              @_placement.y * ((@_mainDiv.offsetHeight - @_mainDiv.offsetHeight * @_placement.y) / 2) -
              Math.abs(@_placement.x) * @_mainDiv.offsetHeight / 2

    if @_mode is "B"
    # marker: center ~ 2/3 horizontally and ~ 2/3 vertically; hivent box above marker
      $(@_mainDiv).offset
        left: @_screenWidth / 2 - 0.74 * @_width
        top: @_screenHeight / 2 - 0.73 * @_height

    # unless @_config.fullscreen
    #   ...

    # else
    #   $(@_mainDiv).offset
    #     top:  5 + canvasOffset.top

  # ============================================================================
  _updateCenterPos: ->
    parentOffset = $(@_parentDiv).offset()
    @_centerPos =
      x:@_mainDiv.offsetLeft + @_mainDiv.offsetWidth/2 - parentOffset.left
      y:@_mainDiv.offsetTop  + @_mainDiv.offsetHeight/2 - parentOffset.top


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  WINDOW_TO_ANCHOR_OFFSET_X = 0
  WINDOW_TO_ANCHOR_OFFSET_Y = 0
  FULLSCREEN_BOX_TOP_OFFSET = 10
  FULLSCREEN_BOX_LEFT_OFFSET = 120
  HIVENTLIST_OFFSET = 400
  BODY_DEFAULT_WIDTH = 450
  BODY_MAX_WIDTH = 400
  BODY_DEFAULT_HEIGHT = 350
  BODY_MAX_HEIGHT = 400
