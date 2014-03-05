window.HG ?= {}

class HG.HiventsOnGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    @_globe = null

    @_hiventController = null
    @_hiventMarkers = []
    @_onMarkerAddedCallbacks = []

    @_hiventLogos = []

    @_sceneInterface     = new THREE.Scene

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


         '''@_hiventLogos.group_new.src = "data/hivent_icons/icon_cluster_default.png"
         @_hiventLogos.group_highlight_new.src = "data/hivent_icons/icon_cluster_highlight.png"'''


         '''@_markerGroup = new HG.Marker3DClusterGroup(@,{maxClusterRadius:20})
         console.log @_markerGroup'''

         @_hiventController.onHiventAdded (handle) =>

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



          window.setTimeout(@_updateMarkerGroup,1);

    else
      console.error "Unable to show hivents on Globe: HiventController module not detected in HistoGlobe instance!"




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
