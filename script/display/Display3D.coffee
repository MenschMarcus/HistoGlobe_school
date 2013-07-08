#include Display.js
#include HiventHandler.js
#include HiventMarker3D.js

window.HG ?= {}

class HG.Display3D extends HG.Display
  
  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################
    
  constructor: (inContainer, inHiventHandler) ->

    this.inContainer = inContainer
    this.inHiventHandler = inHiventHandler

    this._initMembers()
    this._initWindowGeometry()
    this._initGlobe()
    this._initRenderer()
    this._initHivents()
    this._initEventHandling()
    this._zoom()

    this.center x: 10, y: 50
        
  # ============================================================================
  start: ->
    unless this._myIsRunning
      this._myIsRunning = true
      this._myRenderer.domElement.style.display = "inline"
      
      animate = =>
        if this._myIsRunning
          this._render()
          requestAnimationFrame animate
          
      animate()

  # ============================================================================
  stop: ->
    this._myIsRunning = false
    HG.deactivateAllHivents()
    this._myRenderer.domElement.style.display = "none"
  
  # ============================================================================
  isRunning: -> this._myIsRunning
  
  # ============================================================================
  getCanvas: -> this._myRenderer.domElement
  
  # ============================================================================
  center: (latLong) ->
    this._myTargetCameraPos.x = latLong.x
    this._myTargetCameraPos.y = latLong.y
  


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################
  




  # ============================================================================
  _initMembers: ->
    this._myWidth                = null
    this._myHeight               = null
    this._myCamera               = null
    this._myRenderer             = null
    this._mySceneGlobe           = null
    this._mySceneAtmosphere      = null
    this._myCanvasOffsetX        = null
    this._myCanvasOffsetY        = null
    this._myLastIntersected      = []
    this._myCurrentCameraPos     = x: 0, y: 0
    this._myTargetCameraPos      = x: 0, y: 0
    this._myMousePos             = x: 0, y: 0
    this._myMousePosLastFrame    = x: 0, y: 0
    this._myMouseSpeed           = x: 0, y: 0
    this._myDragStartPos         = null
    this._mySpringiness          = 0.9
    this._myCurrentFOV           = 0
    this._myTargetFOV            = 0
    this._myGlobeTextures        = []
    this._myGlobeUniforms        = null
    this._myIsRunning            = false
    this._myCurrentZoom          = CAMERA_MIN_ZOOM
    this._myIsZooming            = false
  
  # ============================================================================
  _initWindowGeometry: ->
    this._myWidth                = this.inContainer.parentNode.offsetWidth
    this._myHeight               = this.inContainer.parentNode.offsetHeight
    this._myCanvasOffsetX        = this.inContainer.parentNode.offsetLeft
    this._myCanvasOffsetY        = this.inContainer.parentNode.offsetTop

  # ============================================================================
  _initGlobe: ->
    # build texture quad tree
    initTile = (minLatLong, size, zoom, x, y) =>
      node =
        textures: null
        loadedTextureCount: 0
        opacity: 1.0
        x: x * 4
        y: y * 4
        z: zoom
        minLatLong: x: minLatLong.x,        y: minLatLong.y
        maxLatLong: x: minLatLong.x + size, y: minLatLong.y + size
        children: null
        
      unless zoom is CAMERA_MAX_ZOOM
        node.children = []

        node.children.push initTile(
          x: minLatLong.x
          y: minLatLong.y + size*0.5,
        size*0.5, zoom+1, x*2, y*2)
        
        node.children.push initTile( 
          x: minLatLong.x + size*0.5
          y: minLatLong.y + size*0.5,
        size*0.5, zoom+1, x*2+1, y*2)
        
        node.children.push initTile(
          x: minLatLong.x
          y: minLatLong.y,
        size*0.5, zoom+1, x*2, y*2+1)
        
        node.children.push initTile(
          x: minLatLong.x + size*0.5
          y: minLatLong.y,
        size*0.5, zoom+1, x*2+1, y*2+1)
        
      return node
    
    # create globe -------------------------------------------------------------
    geometry = new THREE.SphereGeometry EARTH_RADIUS, 64, 32
    shader = SHADERS.earth
    
    this._myCamera             = new THREE.PerspectiveCamera this._myCurrentFOV, 
                                                        this._myWidth / this._myHeight, 
                                                        1, 10000
    this._myCamera.position.z  = CAMERA_DISTANCE
    this._mySceneGlobe         = new THREE.Scene
    this._mySceneAtmosphere    = new THREE.Scene
    this._myGlobeUniforms      = THREE.UniformsUtils.clone shader.uniforms
    this._myGlobeTextures      = initTile {x: 0.0, y: 0.0}, 1.0, 2, 0, 0
    
    material = new THREE.ShaderMaterial(
      vertexShader:   shader.vertexShader
      fragmentShader: shader.fragmentShader
      uniforms:       this._myGlobeUniforms
      transparent:    true
    )
    
    globe = new THREE.Mesh geometry, material
    globe.matrixAutoUpdate = false
    
    this._mySceneGlobe.add globe
    
    # create atmosphere --------------------------------------------------------
    shader = SHADERS.atmosphere
    uniforms = THREE.UniformsUtils.clone shader.uniforms
    uniforms.bgColor.value = new THREE.Vector3 BACKGROUND.r, 
                                               BACKGROUND.g, 
                                               BACKGROUND.b
    material = new THREE.ShaderMaterial(
      uniforms:       uniforms
      vertexShader:   shader.vertexShader
      fragmentShader: shader.fragmentShader
    )
    
    atmosphere                  = new THREE.Mesh geometry, material 
    atmosphere.scale.x          = atmosphere.scale.y = atmosphere.scale.z = 1.5
    atmosphere.flipSided        = true
    atmosphere.matrixAutoUpdate = false
    atmosphere.updateMatrix()
    
    this._mySceneAtmosphere.add atmosphere
  
  # ============================================================================
  _initRenderer: ->
    this._myRenderer = new THREE.WebGLRenderer(antialias: true)
    this._myRenderer.autoClear                 = false
    this._myRenderer.setClearColor             BACKGROUND, 1.0
    this._myRenderer.setSize                   this._myWidth, this._myHeight
    this._myRenderer.domElement.style.position = "absolute"
    
    this.inContainer.appendChild this._myRenderer.domElement
  
  # ============================================================================
  _initEventHandling: ->
    this._myRenderer.domElement.addEventListener "mousedown", this.onMouseDown, false
    this._myRenderer.domElement.addEventListener "mousemove", this.onMouseMove, false
    
    this._myRenderer.domElement.addEventListener "mousewheel", ((event) =>
      event.preventDefault()
      this._onMouseWheel event.wheelDelta
      return false
    ), false
    
    this._myRenderer.domElement.addEventListener "DOMMouseScroll", ((event) =>
      event.preventDefault()
      this._onMouseWheel -event.detail * 30
      return false
    ), false
    
    window.addEventListener   "resize",   this._onWindowResize,    false
    window.addEventListener   "mouseup",  this.onMouseUp,         false
  
  # ============================================================================
  _initHivents: ->
    this.inHiventHandler.onHiventsLoaded (handles) =>
      for handle in handles
        hivent    = new HG.HiventMarker3D handle, this, this.inContainer
        position  = this._latLongToCart 
                      x:handle.getHivent().long
                      y:handle.getHivent().lat
        
        hivent.translateOnAxis new THREE.Vector3(1, 0, 0), position.x
        hivent.translateOnAxis new THREE.Vector3(0, 1, 0), position.y
        hivent.translateOnAxis new THREE.Vector3(0, 0, 1), position.z
  
        this._mySceneGlobe.add hivent
        

  ############################# MAIN FUNCTIONS #################################



  # ============================================================================
  _render: ->
    mouseRel =
      x: (this._myMousePos.x - this._myCanvasOffsetX) / this._myWidth * 2 - 1
      y: (this._myMousePos.y - this._myCanvasOffsetY) / this._myHeight * 2 - 1

    # picking ------------------------------------------------------------------
    # test for mark and highlight hivents
    vector = new THREE.Vector3 mouseRel.x, -mouseRel.y, 0.5
    PROJECTOR.unprojectVector vector, this._myCamera
    RAYCASTER.set this._myCamera.position, vector.sub(this._myCamera.position).normalize()
    intersects = RAYCASTER.intersectObjects this._mySceneGlobe.children
    
    newIntersects = []
    
    for intersect in intersects
      if intersect.object instanceof HG.HiventMarker3D
        index = $.inArray(intersect.object, this._myLastIntersected)
        this._myLastIntersected.splice index, 1  if index >= 0
    
    # unmark previous hits
    for intersect in this._myLastIntersected
      intersect.getHiventHandle().unMark intersect
      intersect.getHiventHandle().unLinkAll()

    this._myLastIntersected = []
    
    # hover intersected objects
    for intersect in intersects
      if intersect.object instanceof HG.HiventMarker3D
        this._myLastIntersected.push intersect.object
        pos =
          x: this._myMousePos.x - this._myCanvasOffsetX
          y: this._myMousePos.y - this._myCanvasOffsetY

        intersect.object.getHiventHandle().mark intersect.object, pos
        intersect.object.getHiventHandle().linkAll pos
    
    # globe rotation -----------------------------------------------------------
    # if there is a drag going on - rotate globe
    if this._myDragStartPos
      # update mouse speed
      this._myMouseSpeed =
        x: 0.5 * this._myMouseSpeed.x + 0.5 * (this._myMousePos.x - this._myMousePosLastFrame.x)
        y: 0.5 * this._myMouseSpeed.y + 0.5 * (this._myMousePos.y - this._myMousePosLastFrame.y)

      this._myMousePosLastFrame = 
        x: this._myMousePos.x
        y: this._myMousePos.y
        
      latLongCurr = this._pixelToLatLong mouseRel
      
      # if mouse is still over the globe
      if latLongCurr
        offset = 
          x: this._myDragStartPos.x - latLongCurr.x
          y: this._myDragStartPos.y - latLongCurr.y
        
        if offset.y > 180
          offset.y -= 360
        else if offset.y < -180
          yOffset += 360  
          
        this._myTargetCameraPos.y += 0.5 * offset.x
        this._myTargetCameraPos.x -= 0.5 * offset.y
        
        this._clampCameraPos()
        
      else
        this._myDragStartPos = null
        container.style.cursor = "auto"
        
    else if this._myMouseSpeed.x isnt 0.0 and this._myMouseSpeed.y isnt 0.0
      # if the globe has been "thrown" --- for "flicking"
      this._myTargetCameraPos.x -= this._myMouseSpeed.x * this._myCurrentFOV * 0.02
      this._myTargetCameraPos.y += this._myMouseSpeed.y * this._myCurrentFOV * 0.02
      
      this._clampCameraPos()
      
      this._myMouseSpeed =
        x: 0.0
        y: 0.0
    
    this._myCurrentCameraPos = 
      x: this._myCurrentCameraPos.x * (this._mySpringiness) + this._myTargetCameraPos.x * (1.0 - this._mySpringiness)
      y: this._myCurrentCameraPos.y * (this._mySpringiness) + this._myTargetCameraPos.y * (1.0 - this._mySpringiness)
    
    rotation =
      x: this._myCurrentCameraPos.x * Math.PI / 180
      y: this._myCurrentCameraPos.y * Math.PI / 180

    this._myCamera.position.x = CAMERA_DISTANCE * Math.sin(rotation.x + Math.PI * 0.5) * Math.cos(rotation.y)
    this._myCamera.position.y = CAMERA_DISTANCE * Math.sin(rotation.y)
    this._myCamera.position.z = CAMERA_DISTANCE * Math.cos(rotation.x + Math.PI * 0.5) * Math.cos(rotation.y)
    
    this._myCamera.lookAt new THREE.Vector3 0, 0, 0
    
    # zooming ------------------------------------------------------------------
    unless this._myCurrentFOV is this._myTargetFOV
      smoothness = 0.8
      this._myCurrentFOV = this._myCurrentFOV * smoothness + this._myTargetFOV * (1.0 - smoothness)
      this._myCamera.fov = this._myCurrentFOV
      this._myCamera.updateProjectionMatrix()
      this._myIsZooming = true
      
      if Math.abs(this._myCurrentFOV - this._myTargetFOV) < 0.05
        this._myCurrentFOV = this._myTargetFOV
        this._myIsZooming  = false
    
    # rendering ----------------------------------------------------------------
    this._myRenderer.clear()
    this._myRenderer.setFaceCulling  THREE.CullFaceBack
    this._myRenderer.setDepthTest    false
    this._myRenderer.setBlending     THREE.AlphaBlending
    this._renderTile                 this._myGlobeTextures
    this._myRenderer.setDepthTest    true
    this._myRenderer.setFaceCulling  THREE.CullFaceFront
    this._myRenderer.render          this._mySceneAtmosphere, this._myCamera
  
  # ============================================================================
  _zoom: ->
    this._myTargetFOV = (CAMERA_MAX_ZOOM - this._myCurrentZoom) / 
                   (CAMERA_MAX_ZOOM - CAMERA_MIN_ZOOM) * 
                   (CAMERA_MAX_FOV - CAMERA_MIN_FOV) + CAMERA_MIN_FOV
  

  ############################ EVENT FUNCTIONS #################################
  


  # ============================================================================
  onMouseDown: (event) =>
  
    if this._myIsRunning
      event.preventDefault()
      clickMouse =
        x: (event.clientX - this._myCanvasOffsetX) / this._myWidth * 2 - 1
        y: (event.clientY - this._myCanvasOffsetY) / this._myHeight * 2 - 1

      this._myDragStartPos = this._pixelToLatLong(clickMouse)
      if this._myDragStartPos
        this.inContainer.style.cursor = "move"
        this._mySpringiness = 0.1
        this._myTargetCameraPos.x = this._myCurrentCameraPos.x
        this._myTargetCameraPos.y = this._myCurrentCameraPos.y
        this._myMousePosLastFrame.x = this._myMousePos.x
        this._myMousePosLastFrame.y = this._myMousePos.y
  
  # ============================================================================
  onMouseMove: (event) =>
    if this._myIsRunning
      this._myMousePos =
        x: event.clientX
        y: event.clientY
  
  # ============================================================================
  onMouseUp: (event) =>
    if this._myIsRunning
      event.preventDefault()
      this.inContainer.style.cursor = "auto"
      this._mySpringiness = 0.9
      this._myDragStartPos = null
      this._myDragStartCamera = null
      
      if this._myLastIntersected.length is 0
        HG.deactivateAllHivents()
        
      else for intersect in this._myLastIntersected
        pos =
          x: this._myMousePos.x - this._myCanvasOffsetX
          y: this._myMousePos.y - this._myCanvasOffsetY

        intersect.getHiventHandle().activeAll pos
          
      return true
  
  # ============================================================================
  _onMouseWheel: (delta) =>
    if this._myIsRunning
      this._myCurrentZoom = Math.max(Math.min(this._myCurrentZoom + delta * 0.005, CAMERA_MAX_ZOOM), CAMERA_MIN_ZOOM)
      this._zoom()
    
    return true
  
  # ============================================================================
  _onWindowResize: (event) ->
    this._myCamera.aspect = this.inContainer.parentNode.offsetWidth / this.inContainer.parentNode.offsetHeight
    this._myCamera.updateProjectionMatrix()
    this._myRenderer.setSize this.inContainer.parentNode.offsetWidth, this.inContainer.parentNode.offsetHeight
    this._initWindowGeometry()
  

  ############################ HELPER FUNCTIONS ################################
  


  # ============================================================================
  _clampCameraPos: ->
    this._myTargetCameraPos.y = CAMERA_MAX_LONG  if this._myTargetCameraPos.y > CAMERA_MAX_LONG
    this._myTargetCameraPos.y = -CAMERA_MAX_LONG  if this._myTargetCameraPos.y < -CAMERA_MAX_LONG

    # ============================================================================
  _isTileVisible: (minNormalizedLatLong, maxNormalizedLatLong) ->
    if this._isFrontFacingTile(minNormalizedLatLong, maxNormalizedLatLong)
      min = this._normalizedMercatusToNormalizedLatLong(minNormalizedLatLong)
      max = this._normalizedMercatusToNormalizedLatLong(maxNormalizedLatLong)
      a = this._latLongToPixel(this._unNormalizeLatLong(
        x: min.x
        y: min.y
      ))
      b = this._latLongToPixel(this._unNormalizeLatLong(
        x: max.x
        y: min.y
      ))
      c = this._latLongToPixel(this._unNormalizeLatLong(
        x: max.x
        y: max.y
      ))
      d = this._latLongToPixel(this._unNormalizeLatLong(
        x: min.x
        y: max.y
      ))
      minX = Math.min(Math.min(Math.min(a.x, b.x), c.x), d.x)
      maxX = Math.max(Math.max(Math.max(a.x, b.x), c.x), d.x)
      minY = Math.min(Math.min(Math.min(a.y, b.y), c.y), d.y)
      maxY = Math.max(Math.max(Math.max(a.y, b.y), c.y), d.y)
      return not (minX > 1.0 or minY > 1.0 or maxX < -1.0 or maxY < -1.0)
    false
  
  # ============================================================================
  _isFrontFacingTile: (minNormalizedLatLong, maxNormalizedLatLong) ->
    isOnFrontSide = (pos) =>
      diff = Math.acos(Math.sin((pos.y - 0.5) * Math.PI) * 
             Math.sin((this._myCurrentCameraPos.y) * Math.PI / 180.0) + 
             Math.cos((pos.y-0.5)*Math.PI) * Math.cos((this._myCurrentCameraPos.y) * 
             Math.PI / 180.0) * Math.cos(-(pos.x - 0.5) * 2.0 * Math.PI + 
             (this._myCurrentCameraPos.x) * Math.PI / 180.0))

      Math.PI * 0.5 > diff
    a =
      x: minNormalizedLatLong.x
      y: minNormalizedLatLong.y

    b =
      x: maxNormalizedLatLong.x
      y: minNormalizedLatLong.y

    c =
      x: maxNormalizedLatLong.x
      y: maxNormalizedLatLong.y

    d =
      x: minNormalizedLatLong.x
      y: maxNormalizedLatLong.y

    return isOnFrontSide(a) or isOnFrontSide(b) or 
           isOnFrontSide(c) or isOnFrontSide(d)
  
  # ============================================================================
  _tileChildrenLoaded: (tile) ->
    for child in tile.children
      return false if child.loadedTextureCount < 16

    return true
  
  # ============================================================================
  _tileLoad: (tile) ->
    tile.textures = []
    dx = 0

    while dx < 4
      dy = 0

      while dy < 4
        x = tile.x + dx
        y = tile.y + (3 - dy)
        file = TILE_PATH + tile.z + "/" + x + "/" + y + ".png"
        tex = THREE.ImageUtils.loadTexture(file, new THREE.UVMapping(), ->
          tile.loadedTextureCount++
        )
        tile.textures.push tex
        ++dy

      ++dx
  
  # ============================================================================
  _tileLoadChildren: (tile) ->
    for child in tile.children
      this._tileLoad child unless child.textures?
  
  # ============================================================================
  _renderTile: (tile) ->
    if this._isTileVisible tile.minLatLong, tile.maxLatLong
      if tile.z < this._myCurrentZoom - 0.5 and tile.children?
        if this._tileChildrenLoaded tile
          
          unless tile.opacity is 1.0
            for child in tile.children
              this._renderTile child 

          if tile.opacity < 0.05
            tile.opacity = 0.0
            return
            
          tile.opacity = tile.opacity * 0.9 unless this._myIsZooming
            
        this._tileLoadChildren tile unless this._myIsZooming
        
      else tile.opacity = 1.0
        
      this._tileLoad tile unless tile.textures?
      
      this._myGlobeUniforms.tiles.value    = tile.textures
      this._myGlobeUniforms.opacity.value  = tile.opacity
      this._myGlobeUniforms.minUV.value    = tile.minLatLong
      this._myGlobeUniforms.maxUV.value    = tile.maxLatLong
      
      this._myRenderer.render this._mySceneGlobe, this._myCamera
  
  # ============================================================================
  _pixelToLatLong: (inPixel) ->
    vector = new THREE.Vector3(inPixel.x, -inPixel.y, 0.5)
    PROJECTOR.unprojectVector vector, this._myCamera
    RAYCASTER.set this._myCamera.position, vector.sub(this._myCamera.position).normalize()
    intersects = RAYCASTER.intersectObjects(this._mySceneGlobe.children)
    return this._cartToLatLong(intersects[0].point.clone().normalize()) if intersects.length > 0
    return null
  
  # ============================================================================
  _latLongToCart: (latLong) ->
    x = EARTH_RADIUS * Math.cos(latLong.y * Math.PI / 180) * Math.cos(-latLong.x * Math.PI / 180)
    y = EARTH_RADIUS * Math.sin(latLong.y * Math.PI / 180)
    z = EARTH_RADIUS * Math.cos(latLong.y * Math.PI / 180) * Math.sin(-latLong.x * Math.PI / 180)
    new THREE.Vector3(x, y, z)
  
  # ============================================================================
  _latLongToPixel: (latLong) ->
    pos = this._latLongToCart(latLong)
    PROJECTOR.projectVector pos, this._myCamera
    return pos
  
  # ============================================================================
  _cartToLatLong: (coordinates) ->
    lat = Math.asin(coordinates.y) / Math.PI * 180
    long = -Math.atan(coordinates.x / coordinates.z) / Math.PI * 180 - 90
    long += 180  if coordinates.z > 0
    new THREE.Vector2(lat, long)
  
  # ============================================================================
  _normalizedLatLongToNormalizedMercatus: (latLong) ->
    return new THREE.Vector2(latLong.x, 0.0) if latLong.y is 0.0
    return new THREE.Vector2(latLong.x, 1.0) if latLong.y is 1.0
    
    new THREE.Vector2(latLong.x, 
                      Math.log(Math.tan(latLong.y * 0.5 * Math.PI)) / 
                              (Math.PI * 2.0) + 0.5)
  
  # ============================================================================
  _normalizedMercatusToNormalizedLatLong: (mercatus) ->
    return new THREE.Vector2(mercatus.x, 0.0) if mercatus.y is 0.0
    return new THREE.Vector2(mercatus.x, 1.0) if mercatus.y is 1.0
    
    new THREE.Vector2(mercatus.x, 2.0 / Math.PI * Math.atan(Math.exp(2 * Math.PI * (mercatus.y - 0.5))))
  
  # ============================================================================
  _normalizeLatLong: (latLong) ->
    new THREE.Vector2(latLong.x / 360.0 + 0.5, latLong.y / 180.0 + 0.5)
  
  # ============================================================================
  _unNormalizeLatLong: (normalizedLatLong) ->
    new THREE.Vector2(normalizedLatLong.x * 360.0 - 180.0, normalizedLatLong.y * 180.0 - 90.0)




  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################
  

  # used for picking
  PROJECTOR = new THREE.Projector()
  RAYCASTER = new THREE.Raycaster()
  
  # background color
  BACKGROUND = new THREE.Color(0xCCCCCC)
  TILE_PATH = "data/tiles/"
  
  # radius of the globe
  EARTH_RADIUS = 200
  
  # camera parameters
  CAMERA_DISTANCE = 500
  CAMERA_MAX_ZOOM = 7
  CAMERA_MIN_ZOOM = 3
  CAMERA_MAX_FOV = 60
  CAMERA_MIN_FOV = 4
  CAMERA_MAX_LONG = 80
  CAMERA_ZOOM_SPEED = 0.1
  
  # shaders for the globe and its atmosphere
  SHADERS =
    earth:
      uniforms:
        tiles:
          type: "tv"
          value: []

        opacity:
          type: "f"
          value: 0.0

        minUV:
          type: "v2"
          value: null

        maxUV:
          type: "v2"
          value: null

      vertexShader: '''
        varying vec3 vNormal;
        varying vec2 vTexcoord;
        
        float convertCoords(float lat) {
          if (lat == 0.0) return 0.0;
          if (lat == 1.0) return 1.0;
          const float pi = 3.1415926535897932384626433832795;
          return log(tan(lat*0.5 * pi)) / (pi * 2.0) + 0.5;
        }
        
        void main() {
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
          vNormal = normalize( normalMatrix * normal );
          vTexcoord = vec2(uv.x, convertCoords(uv.y));
        }
      '''
      
      fragmentShader: '''
        uniform sampler2D tiles[16];
        uniform float opacity;
        uniform vec2 minUV;
        uniform vec2 maxUV;
        varying vec3 vNormal;
        varying vec2 vTexcoord;
        
        void main() {
          
          if (minUV.x > vTexcoord.x || maxUV.x < vTexcoord.x ||
              minUV.y > vTexcoord.y || maxUV.y < vTexcoord.y)
                discard;
          
          vec2 uv = (vTexcoord - minUV)/(maxUV - minUV);
          vec3 diffuse = vec3(0);
          float size = 0.25;
          
          if      (uv.x < 1.0*size && uv.y < 1.0*size)
            diffuse = texture2D( tiles[ 0], uv * 4.0 - vec2(1, 1) + vec2(1, 1)).xyz;
          else if (uv.x < 1.0*size && uv.y < 2.0*size)
            diffuse = texture2D( tiles[ 1], uv * 4.0 - vec2(1, 2) + vec2(1, 1)).xyz;
          else if (uv.x < 1.0*size && uv.y < 3.0*size)
            diffuse = texture2D( tiles[ 2], uv * 4.0 - vec2(1, 3) + vec2(1, 1)).xyz;
          else if (uv.x < 1.0*size && uv.y < 4.0*size)
            diffuse = texture2D( tiles[ 3], uv * 4.0 - vec2(1, 4) + vec2(1, 1)).xyz;
          else if (uv.x < 2.0*size && uv.y < 1.0*size)
            diffuse = texture2D( tiles[ 4], uv * 4.0 - vec2(2, 1) + vec2(1, 1)).xyz;
          else if (uv.x < 2.0*size && uv.y < 2.0*size)
            diffuse = texture2D( tiles[ 5], uv * 4.0 - vec2(2, 2) + vec2(1, 1)).xyz;
          else if (uv.x < 2.0*size && uv.y < 3.0*size)
            diffuse = texture2D( tiles[ 6], uv * 4.0 - vec2(2, 3) + vec2(1, 1)).xyz;
          else if (uv.x < 2.0*size && uv.y < 4.0*size)
            diffuse = texture2D( tiles[ 7], uv * 4.0 - vec2(2, 4) + vec2(1, 1)).xyz;
          else if (uv.x < 3.0*size && uv.y < 1.0*size)
            diffuse = texture2D( tiles[ 8], uv * 4.0 - vec2(3, 1) + vec2(1, 1)).xyz;
          else if (uv.x < 3.0*size && uv.y < 2.0*size)
            diffuse = texture2D( tiles[ 9], uv * 4.0 - vec2(3, 2) + vec2(1, 1)).xyz;
          else if (uv.x < 3.0*size && uv.y < 3.0*size)
            diffuse = texture2D( tiles[10], uv * 4.0 - vec2(3, 3) + vec2(1, 1)).xyz;
          else if (uv.x < 3.0*size && uv.y < 4.0*size)
            diffuse = texture2D( tiles[11], uv * 4.0 - vec2(3, 4) + vec2(1, 1)).xyz;
          else if (uv.x < 4.0*size && uv.y < 1.0*size)
            diffuse = texture2D( tiles[12], uv * 4.0 - vec2(4, 1) + vec2(1, 1)).xyz;
          else if (uv.x < 4.0*size && uv.y < 2.0*size)
            diffuse = texture2D( tiles[13], uv * 4.0 - vec2(4, 2) + vec2(1, 1)).xyz;
          else if (uv.x < 4.0*size && uv.y < 3.0*size)
            diffuse = texture2D( tiles[14], uv * 4.0 - vec2(4, 3) + vec2(1, 1)).xyz;
          else
            diffuse = texture2D( tiles[15], uv * 4.0 - vec2(4, 4) + vec2(1, 1)).xyz;
          
          float phong      = max(0.0, pow(dot( vNormal, normalize(vec3( -0.3, 0.4, 0.7))), 0.6))*0.4 + 0.65;
          float specular   = max(0.0, pow(dot( vNormal, normalize(vec3( -0.3, 0.4, 0.7)) ), 60.0));
          float atmosphere = pow(1.0 - dot( vNormal, vec3( 0.0, 0.0, 1.0 ) ), 2.0) * 0.7;
          gl_FragColor     = vec4( phong * diffuse + atmosphere + specular * 0.1, opacity );
        }
      '''

    atmosphere:
      uniforms:
        bgColor:
          type: "v3"
          value: BACKGROUND

      vertexShader: '''
        varying vec3 vNormal;
        void main() {
          vNormal = normalize( normalMatrix * normal );
          gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
        }
      '''
      
      fragmentShader: '''
        uniform vec3 bgColor;
        varying vec3 vNormal;
        
        void main() {
          float intensity = max(0.0, -0.05 + pow( -dot( vNormal, vec3( 0, 0, 1.0 ) ) + 0.5, 5.0 ));
          gl_FragColor = vec4(vec3( 1.0, 1.0, 1.0) * intensity + bgColor * (1.0-intensity), 1.0 );
        }
      '''