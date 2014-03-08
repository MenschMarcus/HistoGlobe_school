window.HG ?= {}

class HG.HiventsOnGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    @_globe                   = null

    @_hiventController        = null
    @_hiventMarkers           = []
    @_onMarkerAddedCallbacks  = []

    @_hiventLogos             = []

    @_lastIntersected         = []

    @_sceneInterface          = new THREE.Scene

    @_backupFOV               = null
    @_backupZoom              = null
    @_backupCenter            = null

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.hiventsOnGlobe = @

    if hgInstance.categoryIconMapping
      for category in hgInstance.categoryIconMapping.getCategories()
        icons = hgInstance.categoryIconMapping.getIcons(category)
        @_hiventLogos[category] = THREE.ImageUtils.loadTexture(icons["default"])
        @_hiventLogos[category+"_highlighted"] = THREE.ImageUtils.loadTexture(icons["highlighted"])

    #console.log "@_hiventLogos ",@_hiventLogos


    @_globeCanvas = hgInstance._map_canvas

    @_globe = hgInstance.globe

    @_hiventController = hgInstance.hiventController

    if @_globe
      @_globe.onLoaded @, @_initHivents

    else
      console.log "Unable to show hivents on Globe: Globe module not detected in HistoGlobe instance!"

  # ============================================================================
  onMarkerAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onMarkerAddedCallbacks.push callbackFunc

      if @_markersLoaded
        callbackFunc marker for marker in @_hiventMarkers


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################
  # ============================================================================
  _initHivents: ->

    if @_hiventController

      @_globe.addSceneToRenderer(@_sceneInterface)

      @_globe.onMove @, @_updateHiventSizes
      @_globe.onMove @, @_deactivateAllHivents
      @_globe.onZoom @, @_deactivateAllHivents
      window.addEventListener   "mouseup",  @_onMouseUp,         false #for hivent intersections
      window.addEventListener   "mousedown",@_onMouseDown,       false #for hivent intersections


      '''@_hiventLogos.group_new.src = "data/hivent_icons/icon_cluster_default.png"
      @_hiventLogos.group_highlight_new.src = "data/hivent_icons/icon_cluster_highlight.png"'''


      '''@_markerGroup = new HG.Marker3DClusterGroup(@,{maxClusterRadius:20})
      console.log @_markerGroup'''

      @_hiventController.onHiventAdded (handle) =>
        handle.onShow @, (self) =>
          logos =
            default:@_hiventLogos[handle.getHivent().category]
            highlight:@_hiventLogos[handle.getHivent().category+"_highlighted"]

          '''hivent    = new HG.HiventMarker3D handle, this, HG.Display.CONTAINER, @_sceneInterface, @_markerGroup, logos,
                          L.latLng(handle.getHivent().lat, handle.getHivent().long)'''
          marker    = new HG.HiventMarker3D(handle, @_globe, HG.Display.CONTAINER, @_sceneInterface, logos)
          position  =  @_globe._latLongToCart(
            x:handle.getHivent().long
            y:handle.getHivent().lat,
            @_globe.getGlobeRadius()+0.2)

          marker.sprite.position.set(position.x,position.y,position.z)

          @_sceneInterface.add marker.sprite

          @_hiventMarkers.push marker

          @_markersLoaded = @_hiventController._hiventsLoaded
          callback marker for callback in @_onMarkerAddedCallbacks

          marker.onDestruction @,() =>
            index = $.inArray(marker, @_hiventMarkers)
            @_hiventMarkers.splice index, 1  if index >= 0


          @_updateHiventSizes()



      @_hiventController.showVisibleHivents() # force all hivents to show

      setInterval(@_animate, 100)

    else
      console.error "Unable to show hivents on Globe: HiventController module not detected in HistoGlobe instance!"


  # ============================================================================
  _deactivateAllHivents:() =>
    HG.HiventHandle.DEACTIVATE_ALL_HIVENTS()

  # ============================================================================
  _animate:() =>
    if @_globe._isRunning
      @_evaluate()


  # ============================================================================
  _updateHiventSizes:->
    #for hivent in @_markerGroup.getVisibleHivents()
    for hivent in @_hiventMarkers
        cam_pos = new THREE.Vector3(@_globe._camera.position.x,@_globe._camera.position.y,@_globe._camera.position.z).normalize()
        hivent_pos = new THREE.Vector3(hivent.sprite.position.x,hivent.sprite.position.y,hivent.sprite.position.z).normalize()
        #perspective compensation
        dot = (cam_pos.dot(hivent_pos)-0.4)/0.6

        if dot > 0.0
          hivent.sprite.scale.set(hivent.sprite.MaxWidth*dot,hivent.sprite.MaxHeight*dot,1.0)
        else
          hivent.sprite.scale.set(0.0,0.0,1.0)

  # ============================================================================
  _onMouseDown: (event) =>

    @_backupFOV = @_globe._currentFOV
    @_backupZoom = @_globe._currentZoom
    @_backupCenter = @_globe._targetCameraPos

    if @_lastIntersected.length is 0
        HG.HiventHandle.DEACTIVATE_ALL_HIVENTS()


  # ============================================================================
  _onMouseUp: (event) =>

    if @_lastIntersected.length > 0

      for hivent in @_lastIntersected
        pos =
          x: @_globe._mousePos.x - @_globe._canvasOffsetX
          y: @_globe._mousePos.y - @_globe._canvasOffsetY

        #hivent.getHiventHandle().active pos
        hivent.onclick(pos)

      #freeze globe because of area intersection etc
      @_globe._targetFOV = @_backupFOV
      @_globe._currentZoom = @_backupZoom
      @_globe._targetCameraPos =  @_backupCenter

  # ============================================================================
  _evaluate: () =>

    #offset = 0
    #rightOffset = parseFloat($(@_globeCanvas).css("right").replace('px',''))
    #offset = rightOffset if rightOffset

    mouseRel =
      x: (@_globe._mousePos.x - @_globe._canvasOffsetX) / @_globe._width * 2 - 1
      y: (@_globe._mousePos.y - @_globe._canvasOffsetY) / @_globe._myHeight * 2 - 1


    # picking ------------------------------------------------------------------
    vector = new THREE.Vector3 mouseRel.x, -mouseRel.y, 0.5
    projector = @_globe.getProjector()
    projector.unprojectVector vector, @_globe._camera

    raycaster = @_globe.getRaycaster()

    raycaster.set @_globe._camera.position, vector.sub(@_globe._camera.position).normalize()



    tmp_intersects = []
    #for hivent in @_markerGroup.getVisibleHivents()
    for hivent in @_hiventMarkers

      if hivent.sprite.visible and hivent.sprite.scale.x isnt 0.0 and hivent.sprite.scale.y isnt 0.0

        ScreenCoordinates = @_globe._getScreenCoordinates(hivent.sprite.position)

        if ScreenCoordinates
          hivent.ScreenCoordinates = ScreenCoordinates
          x = ScreenCoordinates.x
          y = ScreenCoordinates.y

          h = hivent.sprite.scale.y
          w = hivent.sprite.scale.x

          if @_globe._mousePos.x > x - (w/2) and @_globe._mousePos.x < x + (w/2) and
          @_globe._mousePos.y > y - (h/2) and @_globe._mousePos.y < y + (h/2)
            handle = hivent.getHiventHandle()
            if handle
              #hivent.getHiventHandle().mark hivent, {x:x, y:y}
              hivent.getHiventHandle().mark hivent, hivent.getTooltipPos()
              hivent.getHiventHandle().linkAll {x:x, y:y}
            tmp_intersects.push hivent
            index = $.inArray(hivent, @_lastIntersected)
            @_lastIntersected.splice index, 1  if index >= 0
            HG.Display.CONTAINER.style.cursor = "pointer"

    for hivent in @_lastIntersected
      handle = hivent.getHiventHandle()
      if handle
        handle.unMark hivent
        handle.unLinkAll()

    if tmp_intersects.length is 0
      HG.Display.CONTAINER.style.cursor = "auto"
    @_lastIntersected = tmp_intersects


    #intersects = RAYCASTER.intersectObjects @_sceneGlobe.children
    #intersects2 = RAYCASTER.intersectObjects @_sceneInterface.children

    #newIntersects = []

    '''for intersect in intersects2
      if intersect.object instanceof HG.HiventMarker3D
        index = $.inArray(intersect.object, @_lastIntersected)
        @_lastIntersected.splice index, 1  if index >= 0

    # unmark previous hits
    for intersect in @_lastIntersected
      intersect.getHiventHandle().unMark intersect
      intersect.getHiventHandle().unLinkAll()

    @_lastIntersected = []

    # hover intersected objects
    for intersect in intersects2

      console.log intersect

      if intersect.object instanceof HG.HiventMarker3D
        @_lastIntersected.push intersect.object
        pos =
          x: @_mousePos.x - @_canvasOffsetX
          y: @_mousePos.y - @_canvasOffsetY

        intersect.object.getHiventHandle().mark intersect.object, pos
        intersect.object.getHiventHandle().linkAll pos'''
