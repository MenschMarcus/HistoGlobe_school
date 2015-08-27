#include Extendable.coffee

window.HG ?= {}

class HG.HiventMarker3DGroup

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventMarkers, display, parent, scene, logos, hgInstance) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onMarkerDestruction"

    @_globe = display
    
    @_scene = scene

    @_hgInstance = hgInstance

    @ScreenCoordinates = null

    @_hiventTexture = logos.default
    @_hiventTextureHighlight = logos.highlight
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

    #@_scene.add @sprite

    @_hiventMarkers = hiventMarkers


  # ============================================================================
  addHiventCallbacks:() ->

    for marker in @_hiventMarkers

      if marker
        marker.getHiventHandle().onFocus(@, (mousePos) =>
          if display.isRunning()
            display.focus marker.getHiventHandle().getHivent()
        )

        marker.getHiventHandle().onMark @, (mousePos) =>
          #hiventTexture = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category+"_highlight"))
          @sprite.material.map = @_hiventTextureHighlight

        marker.getHiventHandle().onUnMark @, (mousePos) =>
          #hiventTexture = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category))
          @sprite.material.map = @_hiventTexture

        marker.getHiventHandle().onLink @, (mousePos) =>
          @sprite.material.map = @_hiventTextureHighlight

        marker.getHiventHandle().onUnLink @, (mousePos) =>
          @sprite.material.map = @_hiventTexture

        marker.getHiventHandle().onAgeChanged @, (age) =>
          #no more Opacity
          #@sprite.material.opacity = age
          0

        marker.getHiventHandle().onDestruction @, () =>
          @_delete_marker marker
        marker.getHiventHandle().onVisibleFuture @, () =>
          @_delete_marker marker
        marker.getHiventHandle().onInvisible @, () =>
          @_delete_marker marker


  # ============================================================================
  onMouseOver:(x,y) ->
    for marker in @_hiventMarkers
      marker.getHiventHandle().mark @, {x:x, y:y}
      #@getHiventHandle().mark hivent, getPosition()
      marker.getHiventHandle().linkAll {x:x, y:y}

  # ============================================================================
  onMouseOut:() ->
    for marker in @_hiventMarkers
      marker.getHiventHandle().unMark @
      marker.getHiventHandle().unLinkAll()

  # ============================================================================
  onClick:(pos) ->
    # TODO!!!
    #@getHiventHandle().toggleActive @,pos
    #@_hgInstance.hiventInfoAtTag?.setOption "event", @_hiventHandle.getHivent().id
    0

  # ============================================================================
  getPosition: ->
    unless @ScreenCoordinates
      @ScreenCoordinates = @_globe._getScreenCoordinates(@sprite.position)

    @ScreenCoordinates

  # ============================================================================
  getGPS: ->
    return [@_hiventMarkers[0].getHiventHandle().getHivent().lat[0],@_hiventMarkers[0].getHiventHandle().getHivent().long[0]]

  # ============================================================================
  addMarker:(marker) ->
    @_hiventMarkers.push(marker)
    marker.getHiventHandle().onFocus(@, (mousePos) =>
      if display.isRunning()
        display.focus marker.getHiventHandle().getHivent()
    )

    marker.getHiventHandle().onMark @, (mousePos) =>
      #hiventTexture = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category+"_highlight"))
      @sprite.material.map = @_hiventTextureHighlight

    marker.getHiventHandle().onUnMark @, (mousePos) =>
      #hiventTexture = THREE.ImageUtils.loadTexture(@_getIcon(hiventHandle.getHivent().category))
      @sprite.material.map = @_hiventTexture

    marker.getHiventHandle().onLink @, (mousePos) =>
      @sprite.material.map = @_hiventTextureHighlight

    marker.getHiventHandle().onUnLink @, (mousePos) =>
      @sprite.material.map = @_hiventTexture

    marker.getHiventHandle().onDestruction @, () =>
      @_delete_marker marker
    marker.getHiventHandle().onVisibleFuture @, () =>
      @_delete_marker marker
    marker.getHiventHandle().onInvisible @, () =>
      @_delete_marker marker
  

  # ============================================================================
  getDisplayPosition:->
    return @getPosition()

  # ============================================================================
  getHiventMarkers:->
    return @_hiventMarkers

  # ============================================================================
  destroy: ->
    @_destroy()


  # ============================================================================
  _delete_marker:(marker) ->
    marker.getHiventHandle().removeListener "onFocus", @
    marker.getHiventHandle().removeListener "onMark", @
    marker.getHiventHandle().removeListener "onUnMark", @
    marker.getHiventHandle().removeListener "onLink", @
    marker.getHiventHandle().removeListener "onUnLink", @
    marker.getHiventHandle().removeListener "onVisibleFuture", @
    marker.getHiventHandle().removeListener "onInvisible", @
    marker.getHiventHandle().removeListener "onDestruction", @
    index = @_hiventMarkers.indexOf(marker)
    @_hiventMarkers.splice index, 1 if index >= 0

    if @_hiventMarkers.length == 1
      @_hiventMarkers[0].getHiventHandle().removeListener "onFocus", @
      @_hiventMarkers[0].getHiventHandle().removeListener "onMark", @
      @_hiventMarkers[0].getHiventHandle().removeListener "onUnMark", @
      @_hiventMarkers[0].getHiventHandle().removeListener "onLink", @
      @_hiventMarkers[0].getHiventHandle().removeListener "onUnLink", @
      @_hiventMarkers[0].getHiventHandle().removeListener "onVisibleFuture", @
      @_hiventMarkers[0].getHiventHandle().removeListener "onInvisible", @
      @_hiventMarkers[0].getHiventHandle().removeListener "onDestruction", @
      @notifyAll "onMarkerDestruction",@



  # ============================================================================
  _destroy: ->

    #@_scene.remove @sprite

    @_hiventMarkers = []

    #@_onMarkerDestructionCallbacks = []

    delete @;
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################



