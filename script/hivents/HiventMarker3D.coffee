#include Extendable.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarker3D extends HG.HiventMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  #constructor: (hiventHandle, display, parent, scene, markerGroup, logos, latlng) ->
  constructor: (hiventHandle, display, parent, scene, logos) ->

    #HG.mixin @, HG.HiventMarker

    HG.HiventMarker.call @, hiventHandle, parent



    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onMarkerDestruction"


    @_scene = scene


    @ScreenCoordinates = null

    #new
    #hiventTexture = THREE.ImageUtils.loadTexture('data/hivent_icons/icon_join.png')
    #@_hiventTexture = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category))
    #@_hiventTextureHighlight = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category+"_highlight"))
    @_hiventTexture = logos.default
    @_hiventTextureHighlight = logos.highlight
    #console.log hiventHandle.getHivent().category
    hiventMaterial = new THREE.SpriteMaterial({
        map: @_hiventTexture,
        transparent:true,
        opacity: 1.0,
        useScreenCoordinates: false,
        scaleByViewport: true,
        sizeAttenuation: false,
        depthTest: false,
        affectedByDistance: true

        })
    @sprite = new THREE.Sprite(hiventMaterial)

    @sprite.MaxWidth = HGConfig.hivent_marker_2D_width.val
    @sprite.MaxHeight = HGConfig.hivent_marker_2D_height.val

    @sprite.scale.set(HGConfig.hivent_marker_2D_width.val,HGConfig.hivent_marker_2D_height.val,1.0)

    @_scene.add @sprite

    #@_latlng = latlng # for clustering purposes only
    #console.log "lat´lng in 3d marker", @_latlng


    #@_markergroup = markerGroup # clustering later!!! (TODO)
    #@_markergroup.addLayer(@)




    @getHiventHandle().onFocus(@, (mousePos) =>
      if display.isRunning()
        display.focus @getHiventHandle().getHivent()
    )

    @getHiventHandle().onMark @, (mousePos) =>
      #hiventTexture = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category+"_highlight"))
      @sprite.material.map = @_hiventTextureHighlight

    @getHiventHandle().onUnMark @, (mousePos) =>
      #hiventTexture = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category))
      @sprite.material.map = @_hiventTexture

    @getHiventHandle().onLink @, (mousePos) =>
      @sprite.material.map = @_hiventTextureHighlight

    @getHiventHandle().onUnLink @, (mousePos) =>
      @sprite.material.map = @_hiventTexture

    @getHiventHandle().onAgeChanged @, (age) =>
      @sprite.material.opacity = age


    @getHiventHandle().onDestruction @, @destroy
    @getHiventHandle().onVisibleFuture @, @destroy
    @getHiventHandle().onInvisible @, @destroy

    '''@enableShowName()
    @enableShowInfo()'''

  '''getLatLng:() ->#for clustering purposes only
    return @_latlng'''

  onclick:(pos) ->
    @getHiventHandle().toggleActive @,pos


  # ============================================================================
  getTooltipPos: ->
    if @ScreenCoordinates
      @ScreenCoordinates
    else
      console.log "No ScreenCoordinates!"

  # ============================================================================
  destroy: ->
    @notifyAll "onMarkerDestruction"
    @_destroy()


  # ============================================================================
  _destroy: ->

    #@_markergroup.removeLayer @
    @getHiventHandle().inActiveAll()
    @_scene.remove @sprite

    #@_onMarkerDestructionCallbacks = []
    @_hiventHandle.removeListener "onFocus", @
    @_hiventHandle.removeListener "onActive", @
    @_hiventHandle.removeListener "onInActive", @
    @_hiventHandle.removeListener "onLink", @
    @_hiventHandle.removeListener "onUnLink", @
    @_hiventHandle.removeListener "onVisibleFuture", @
    @_hiventHandle.removeListener "onInvisible", @
    @_hiventHandle.removeListener "onDestruction", @

    super()
    delete @;
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################



