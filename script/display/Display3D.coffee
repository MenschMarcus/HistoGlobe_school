#include Display.js
#include HiventHandler.js
#include HiventMarker3D.js

window.HG ?= {}

class HG.Display3D extends HG.Display
  
  #////////////////////////////////////////////////////////////////////////////
  #                          PUBLIC INTERFACE                                //
  #////////////////////////////////////////////////////////////////////////////
  
  #///////////////////////// STATIC CONSTANTS /////////////////////////////////
  
  # used for picking
  
  # background color
  
  # radius of the globe
  
  # camera distance to globe, its maximum longitude a the zoom spped
  
  # shaders for the globe and its atmosphere
  
  #//////////////////////////// FUNCTIONS /////////////////////////////////////
  
  PROJECTOR = new THREE.Projector()
  RAYCASTER = new THREE.Raycaster()
  BACKGROUND = new THREE.Color(0xCCCCCC)
  TILE_PATH = "data/tiles/"
  EARTH_RADIUS = 200
  CAMERA_DISTANCE = 500
  CAMERA_MAX_ZOOM = 7
  CAMERA_MIN_ZOOM = 3
  CAMERA_MAX_FOV = 60
  CAMERA_MIN_FOV = 4
  CAMERA_MAX_LONG = 80
  CAMERA_ZOOM_SPEED = 0.1
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

      vertexShader: [
        "varying vec3 vNormal;"
        "varying vec2 vTexcoord;"
        "float convertCoords(float lat) {"
        "if (lat == 0.0) return 0.0;"
        "if (lat == 1.0) return 1.0;"
        "const float pi = 3.1415926535897932384626433832795;"
        "return log(tan(lat*0.5 * pi)) / (pi * 2.0) + 0.5;", "}"
        "void main() {"
        "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );"
        "vNormal = normalize( normalMatrix * normal );"
        "vTexcoord = vec2(uv.x, convertCoords(uv.y));"
        "}"
      ].join("\n")
      
      fragmentShader: ["uniform sampler2D tiles[16];", "uniform float opacity;", "uniform vec2 minUV;", "uniform vec2 maxUV;", "varying vec3 vNormal;", "varying vec2 vTexcoord;", "void main() {", "if (minUV.x > vTexcoord.x || maxUV.x < vTexcoord.x ||", "minUV.y > vTexcoord.y || maxUV.y < vTexcoord.y)", "discard;", "vec2 uv = (vTexcoord - minUV)/(maxUV - minUV);", "vec3 diffuse = vec3(0);", "float size = 0.25;", "if      (uv.x < 1.0*size && uv.y < 1.0*size)", "diffuse = texture2D( tiles[ 0], uv * 4.0 - vec2(1, 1) + vec2(1, 1)).xyz;", "else if (uv.x < 1.0*size && uv.y < 2.0*size)", "diffuse = texture2D( tiles[ 1], uv * 4.0 - vec2(1, 2) + vec2(1, 1)).xyz;", "else if (uv.x < 1.0*size && uv.y < 3.0*size)", "diffuse = texture2D( tiles[ 2], uv * 4.0 - vec2(1, 3) + vec2(1, 1)).xyz;", "else if (uv.x < 1.0*size && uv.y < 4.0*size)", "diffuse = texture2D( tiles[ 3], uv * 4.0 - vec2(1, 4) + vec2(1, 1)).xyz;", "else if (uv.x < 2.0*size && uv.y < 1.0*size)", "diffuse = texture2D( tiles[ 4], uv * 4.0 - vec2(2, 1) + vec2(1, 1)).xyz;", "else if (uv.x < 2.0*size && uv.y < 2.0*size)", "diffuse = texture2D( tiles[ 5], uv * 4.0 - vec2(2, 2) + vec2(1, 1)).xyz;", "else if (uv.x < 2.0*size && uv.y < 3.0*size)", "diffuse = texture2D( tiles[ 6], uv * 4.0 - vec2(2, 3) + vec2(1, 1)).xyz;", "else if (uv.x < 2.0*size && uv.y < 4.0*size)", "diffuse = texture2D( tiles[ 7], uv * 4.0 - vec2(2, 4) + vec2(1, 1)).xyz;", "else if (uv.x < 3.0*size && uv.y < 1.0*size)", "diffuse = texture2D( tiles[ 8], uv * 4.0 - vec2(3, 1) + vec2(1, 1)).xyz;", "else if (uv.x < 3.0*size && uv.y < 2.0*size)", "diffuse = texture2D( tiles[ 9], uv * 4.0 - vec2(3, 2) + vec2(1, 1)).xyz;", "else if (uv.x < 3.0*size && uv.y < 3.0*size)", "diffuse = texture2D( tiles[10], uv * 4.0 - vec2(3, 3) + vec2(1, 1)).xyz;", "else if (uv.x < 3.0*size && uv.y < 4.0*size)", "diffuse = texture2D( tiles[11], uv * 4.0 - vec2(3, 4) + vec2(1, 1)).xyz;", "else if (uv.x < 4.0*size && uv.y < 1.0*size)", "diffuse = texture2D( tiles[12], uv * 4.0 - vec2(4, 1) + vec2(1, 1)).xyz;", "else if (uv.x < 4.0*size && uv.y < 2.0*size)", "diffuse = texture2D( tiles[13], uv * 4.0 - vec2(4, 2) + vec2(1, 1)).xyz;", "else if (uv.x < 4.0*size && uv.y < 3.0*size)", "diffuse = texture2D( tiles[14], uv * 4.0 - vec2(4, 3) + vec2(1, 1)).xyz;", "else", "diffuse = texture2D( tiles[15], uv * 4.0 - vec2(4, 4) + vec2(1, 1)).xyz;", "float phong      = max(0.0, pow(dot( vNormal, normalize(vec3( -0.3, 0.4, 0.7))), 0.6))*0.4 + 0.65;", "float specular   = max(0.0, pow(dot( vNormal, normalize(vec3( -0.3, 0.4, 0.7)) ), 60.0));", "float atmosphere = pow(1.0 - dot( vNormal, vec3( 0.0, 0.0, 1.0 ) ), 2.0) * 0.7;", "gl_FragColor     = vec4( phong * diffuse + atmosphere + specular * 0.1, opacity );", "}"].join("\n")

    atmosphere:
      uniforms:
        bgColor:
          type: "v3"
          value: null

      vertexShader: ["varying vec3 vNormal;", "void main() {", "vNormal = normalize( normalMatrix * normal );", "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );", "}"].join("\n")
      fragmentShader: ["uniform vec3 bgColor;", "varying vec3 vNormal;", "void main() {", "float intensity = max(0.0, -0.05 + pow( -dot( vNormal, vec3( 0, 0, 1.0 ) ) + 0.5, 5.0 ));", "gl_FragColor = vec4(vec3( 1.0, 1.0, 1.0) * intensity + bgColor * (1.0-intensity), 1.0 );", "}"].join("\n")

  
  constructor: (@inContainer, @inHiventHandler) ->
    
    @myWidth = undefined
    @myHeight = undefined
    @mySelf = this
    @myCamera = undefined
    @myRenderer = undefined
    @mySceneGlobe = undefined
    @mySceneAtmosphere = undefined
    @myCanvasOffsetX = undefined
    @myCanvasOffsetY = undefined
    @myLastIntersected = []
    @myCurrentCameraPos =
      x: 0
      y: 0

    @myTargetCameraPos =
      x: 0
      y: 0

    @myMousePos =
      x: 0
      y: 0

    @myMousePosLastFrame =
      x: 0
      y: 0

    @myMouseSpeed =
      x: 0
      y: 0

    @myDragStartPos = undefined
    @mySpringiness = 0.9
    @myCurrentFOV = 0
    @myTargetFOV = 0
    @myGlobeTextures = []
    @myGlobeUniforms = undefined
    @myIsRunning = false
    @myCurrentZoom = CAMERA_MIN_ZOOM
    @myIsZooming = false

    @initWindowGeometry()
    
    console.log @myWidth
    
    @initGlobe()
    @initRenderer()
    @initHivents()
    @initEventHandling()
    @zoom()
    @center
      x: 10
      y: 50
    

  start: ->
    unless @myIsRunning
      @myIsRunning = true
      @myRenderer.domElement.style.display = "inline"
      
      animate = =>
        if @myIsRunning
          @render()
          requestAnimationFrame animate
          
      animate()
    

  stop: ->
    @myIsRunning = false
    HG.deactivateAllHivents()
    @myRenderer.domElement.style.display = "none"

  isRunning: ->
    @myIsRunning

  getCanvas: ->
    @myRenderer.domElement

  center: (latLong) ->
    @myTargetCameraPos.x = latLong.x
    @myTargetCameraPos.y = latLong.y
  
  # ===========================================================================
  initWindowGeometry: ->
    @myWidth = @inContainer.parentNode.offsetWidth
    @myHeight = @inContainer.parentNode.offsetHeight
    @myCanvasOffsetX = @inContainer.parentNode.offsetLeft
    @myCanvasOffsetY = @inContainer.parentNode.offsetTop
  
  # ===========================================================================
  
  # init methods
  
  # ===========================================================================
  
  # ===========================================================================
  
  # ===========================================================================
  
  # ===========================================================================
  
  # ===========================================================================
  
  #////////////////////////////////////////////////////////////////////////////
  #                         PRIVATE INTERFACE                                //
  #////////////////////////////////////////////////////////////////////////////
  
  #///////////////////////// MEMBER VARIABLES /////////////////////////////////
  
  # THREE js
  
  # window geometry
  
  #//////////////////////// INIT FUNCTIONS ////////////////////////////////////
  
  
  
  # ===========================================================================
  initGlobe: ->
    
    # build texture quad tree
    initTile = (minLatLong, size, zoom, x, y) =>
      if zoom is CAMERA_MAX_ZOOM
        return (
          textures: null
          loadedTextureCount: 0
          opacity: 1.0
          x: x * 4
          y: y * 4
          z: zoom
          minLatLong:
            x: minLatLong.x
            y: minLatLong.y

          maxLatLong:
            x: minLatLong.x + size
            y: minLatLong.y + size

          children: null
        )
      node =
        textures: null
        loadedTextureCount: 0
        opacity: 1.0
        x: x * 4
        y: y * 4
        z: zoom
        minLatLong:
          x: minLatLong.x
          y: minLatLong.y

        maxLatLong:
          x: minLatLong.x + size
          y: minLatLong.y + size

        children: []

      node.children.push initTile(
        x: minLatLong.x
        y: minLatLong.y + size * 0.5
      , size * 0.5, zoom + 1, x * 2, y * 2)
      node.children.push initTile(
        x: minLatLong.x + size * 0.5
        y: minLatLong.y + size * 0.5
      , size * 0.5, zoom + 1, x * 2 + 1, y * 2)
      node.children.push initTile(
        x: minLatLong.x
        y: minLatLong.y
      , size * 0.5, zoom + 1, x * 2, y * 2 + 1)
      node.children.push initTile(
        x: minLatLong.x + size * 0.5
        y: minLatLong.y
      , size * 0.5, zoom + 1, x * 2 + 1, y * 2 + 1)
      node
    @myCamera = new THREE.PerspectiveCamera(@myCurrentFOV, @myWidth / @myHeight, 1, 10000)
    @myCamera.position.z = CAMERA_DISTANCE
    @mySceneGlobe = new THREE.Scene()
    @mySceneAtmosphere = new THREE.Scene()
    geometry = new THREE.SphereGeometry(EARTH_RADIUS, 64, 32)
    shader = SHADERS["earth"]
    @myGlobeUniforms = THREE.UniformsUtils.clone(shader.uniforms)
    @myGlobeTextures = initTile(
      x: 0.0
      y: 0.0
    , 1.0, 2, 0, 0)
    material = new THREE.ShaderMaterial(
      vertexShader: shader.vertexShader
      fragmentShader: shader.fragmentShader
      uniforms: @myGlobeUniforms
      transparent: true
    )
    globe = new THREE.Mesh(geometry, material)
    globe.matrixAutoUpdate = false
    @mySceneGlobe.add globe
    shader = SHADERS["atmosphere"]
    uniforms = THREE.UniformsUtils.clone(shader.uniforms)
    uniforms["bgColor"].value = new THREE.Vector3(BACKGROUND.r, BACKGROUND.g, BACKGROUND.b)
    material = new THREE.ShaderMaterial(
      uniforms: uniforms
      vertexShader: shader.vertexShader
      fragmentShader: shader.fragmentShader
    )
    atmosphere = new THREE.Mesh(geometry, material)
    atmosphere.scale.x = atmosphere.scale.y = atmosphere.scale.z = 1.5
    atmosphere.flipSided = true
    atmosphere.matrixAutoUpdate = false
    atmosphere.updateMatrix()
    @mySceneAtmosphere.add atmosphere
  
  # ===========================================================================
  initRenderer: ->
    @myRenderer = new THREE.WebGLRenderer(antialias: true)
    @myRenderer.autoClear = false
    @myRenderer.setClearColor BACKGROUND, 1.0
    @myRenderer.setSize @myWidth, @myHeight
    @myRenderer.domElement.style.position = "absolute"
    @inContainer.appendChild @myRenderer.domElement
  
  # ===========================================================================
  initEventHandling: ->
    @myRenderer.domElement.addEventListener "mousedown", @onMouseDown, false
    @myRenderer.domElement.addEventListener "mousemove", @onMouseMove, false
    @myRenderer.domElement.addEventListener "mouseup", @onMouseUp, false
    @myRenderer.domElement.addEventListener "mousewheel", ((event) =>
      event.preventDefault()
      @onMouseWheel event.wheelDelta
      false
    ), false
    @myRenderer.domElement.addEventListener "DOMMouseScroll", ((event) =>
      event.preventDefault()
      @onMouseWheel -event.detail * 30
      false
    ), false
    document.addEventListener "keydown", @onDocumentKeyDown, false
    window.addEventListener "resize", @onWindowResize, false
  
  # ===========================================================================
  initHivents: ->
    @inHiventHandler.onHiventsLoaded (handles) =>
      i = 0

      while i < handles.length
        hivent = new HG.HiventMarker3D(handles[i], this, @inContainer)
        @mySceneGlobe.add hivent
        position = @latLongToCart(new THREE.Vector2(handles[i].getHivent().long, handles[i].getHivent().lat))
        hivent.translateOnAxis new THREE.Vector3(1, 0, 0), position.x
        hivent.translateOnAxis new THREE.Vector3(0, 1, 0), position.y
        hivent.translateOnAxis new THREE.Vector3(0, 0, 1), position.z
        i++

  
  #///////////////////////// MAIN FUNCTIONS ///////////////////////////////////

  # ===========================================================================
  render: ->
    mouseRel =
      x: (@myMousePos.x - @myCanvasOffsetX) / @myWidth * 2 - 1
      y: (@myMousePos.y - @myCanvasOffsetY) / @myHeight * 2 - 1

    # picking -----------------------------------------------------------------
    
    # test for mark and highlight hivents
    vector = new THREE.Vector3(mouseRel.x, -mouseRel.y, 0.5)
    PROJECTOR.unprojectVector vector, @myCamera
    RAYCASTER.set @myCamera.position, vector.sub(@myCamera.position).normalize()
    intersects = RAYCASTER.intersectObjects(@mySceneGlobe.children)
    i = 0

    while i < intersects.length
      if intersects[i].object instanceof HG.HiventMarker3D
        index = $.inArray(intersects[i].object, @myLastIntersected)
        @myLastIntersected.splice index, 1  if index >= 0
      i++
    i = 0

    while i < @myLastIntersected.length
      @myLastIntersected[i].getHiventHandle().unMark @myLastIntersected[i], @myMousePos
      @myLastIntersected[i].getHiventHandle().unLinkAll @myMousePos
      i++
    @myLastIntersected = []
    i = 0

    while i < intersects.length
      if intersects[i].object instanceof HG.HiventMarker3D
        @myLastIntersected.push intersects[i].object
        pos =
          x: @myMousePos.x - @myCanvasOffsetX
          y: @myMousePos.y - @myCanvasOffsetY

        intersects[i].object.getHiventHandle().mark intersects[i].object, pos
        intersects[i].object.getHiventHandle().linkAll pos
      i++
    
    # globe rotation ----------------------------------------------------------
    
    # if there is a drag going on - rotate globe
    if @myDragStartPos
      
      # update mouse speed
      @myMouseSpeed =
        x: 0.5 * @myMouseSpeed.x + 0.5 * (@myMousePos.x - @myMousePosLastFrame.x)
        y: 0.5 * @myMouseSpeed.y + 0.5 * (@myMousePos.y - @myMousePosLastFrame.y)

      @myMousePosLastFrame.x = @myMousePos.x
      @myMousePosLastFrame.y = @myMousePos.y
      latLongCurr = @pixelToLatLong(mouseRel)
      
      # if mouse is still over the globe
      if latLongCurr
        xOffset = @myDragStartPos.x - latLongCurr.x
        yOffset = @myDragStartPos.y - latLongCurr.y
        if yOffset > 180
          yOffset -= 360
        else yOffset += 360  if yOffset < -180
        @myTargetCameraPos.y += 0.5 * (xOffset)
        @myTargetCameraPos.x -= 0.5 * (yOffset)
        @clampCameraPos()
      else
        @myDragStartPos = null
        container.style.cursor = "auto"
    else if @myMouseSpeed.x isnt 0.0 and @myMouseSpeed.y isnt 0.0
      
      # if the globe has been "thrown" --- for "flicking"
      @myTargetCameraPos.x -= @myMouseSpeed.x * @myCurrentFOV * 0.02
      @myTargetCameraPos.y += @myMouseSpeed.y * @myCurrentFOV * 0.02
      @clampCameraPos()
      @myMouseSpeed =
        x: 0.0
        y: 0.0
    @myCurrentCameraPos.x = @myCurrentCameraPos.x * (@mySpringiness) + @myTargetCameraPos.x * (1.0 - @mySpringiness)
    @myCurrentCameraPos.y = @myCurrentCameraPos.y * (@mySpringiness) + @myTargetCameraPos.y * (1.0 - @mySpringiness)
    rotation =
      x: @myCurrentCameraPos.x * Math.PI / 180
      y: @myCurrentCameraPos.y * Math.PI / 180

    @myCamera.position.x = CAMERA_DISTANCE * Math.sin(rotation.x + Math.PI * 0.5) * Math.cos(rotation.y)
    @myCamera.position.y = CAMERA_DISTANCE * Math.sin(rotation.y)
    @myCamera.position.z = CAMERA_DISTANCE * Math.cos(rotation.x + Math.PI * 0.5) * Math.cos(rotation.y)
    @myCamera.lookAt new THREE.Vector3(0, 0, 0)
    
    # zooming -----------------------------------------------------------------
    unless @myCurrentFOV is @myTargetFOV
      smoothness = 0.8
      @myCurrentFOV = @myCurrentFOV * smoothness + @myTargetFOV * (1.0 - smoothness)
      @myCamera.fov = @myCurrentFOV
      @myCamera.updateProjectionMatrix()
      @myIsZooming = true
      if Math.abs(@myCurrentFOV - @myTargetFOV) < 0.05
        @myCurrentFOV = @myTargetFOV
        @myIsZooming = false
    
    # rendering ---------------------------------------------------------------
    @myRenderer.clear()
    @myRenderer.setFaceCulling THREE.CullFaceBack
    @myRenderer.setDepthTest false
    @myRenderer.setBlending THREE.AlphaBlending
    @renderTile @myGlobeTextures
    @myRenderer.setDepthTest true
    @myRenderer.setFaceCulling THREE.CullFaceFront
    @myRenderer.render @mySceneAtmosphere, @myCamera
  
  # ===========================================================================
  zoom: ->
    @myTargetFOV = (CAMERA_MAX_ZOOM - @myCurrentZoom) / (CAMERA_MAX_ZOOM - CAMERA_MIN_ZOOM) * (CAMERA_MAX_FOV - CAMERA_MIN_FOV) + CAMERA_MIN_FOV
  
  #//////////////////////// EVENT HANDLING ////////////////////////////////////
  
  # ===========================================================================
  onMouseDown: (event) =>
  
    if @myIsRunning
  
      event.preventDefault()
      clickMouse =
        x: (event.clientX - @myCanvasOffsetX) / @myWidth * 2 - 1
        y: (event.clientY - @myCanvasOffsetY) / @myHeight * 2 - 1

      @myDragStartPos = @pixelToLatLong(clickMouse)
      if @myDragStartPos
        @inContainer.style.cursor = "move"
        @mySpringiness = 0.1
        @myTargetCameraPos.x = @myCurrentCameraPos.x
        @myTargetCameraPos.y = @myCurrentCameraPos.y
        @myMousePosLastFrame.x = @myMousePos.x
        @myMousePosLastFrame.y = @myMousePos.y
  
  # ===========================================================================
  onMouseMove: (event) =>
    if @myIsRunning
      @myMousePos =
        x: event.clientX
        y: event.clientY
  
  # ===========================================================================
  onMouseUp: (event) =>
    if @myIsRunning
      event.preventDefault()
      @inContainer.style.cursor = "auto"
      @mySpringiness = 0.9
      @myDragStartPos = null
      @myDragStartCamera = null
      if @myLastIntersected.length is 0
        HG.deactivateAllHivents()
      else
        i = 0

        while i < @myLastIntersected.length
          pos =
            x: @myMousePos.x - @myCanvasOffsetX
            y: @myMousePos.y - @myCanvasOffsetY

          @myLastIntersected[i].getHiventHandle().activeAll pos
          i++
  
  # ===========================================================================
  onMouseWheel: (delta) =>
    if @myIsRunning
      @myCurrentZoom = Math.max(Math.min(@myCurrentZoom + delta * 0.005, CAMERA_MAX_ZOOM), CAMERA_MIN_ZOOM)
      @zoom()
    false
  
  # ===========================================================================
  onDocumentKeyDown: (event) ->
    if @myIsRunning
      switch event.keyCode
        when 38
          @zoom 100
          event.preventDefault()
        when 40
          @zoom -100
          event.preventDefault()
  
  # ===========================================================================
  onWindowResize: (event) ->
    @myCamera.aspect = @inContainer.parentNode.offsetWidth / @inContainer.parentNode.offsetHeight
    @myCamera.updateProjectionMatrix()
    @myRenderer.setSize @inContainer.parentNode.offsetWidth, @inContainer.parentNode.offsetHeight
    @initWindowGeometry()
  
  #/////////////////////// HELPER FUNCTIONS ///////////////////////////////////
  
  # ===========================================================================
  clampCameraPos: ->
    @myTargetCameraPos.y = CAMERA_MAX_LONG  if @myTargetCameraPos.y > CAMERA_MAX_LONG
    @myTargetCameraPos.y = -CAMERA_MAX_LONG  if @myTargetCameraPos.y < -CAMERA_MAX_LONG
  
  # ===========================================================================
  pixelToLatLong: (inPixel) ->
    vector = new THREE.Vector3(inPixel.x, -inPixel.y, 0.5)
    PROJECTOR.unprojectVector vector, @myCamera
    RAYCASTER.set @myCamera.position, vector.sub(@myCamera.position).normalize()
    intersects = RAYCASTER.intersectObjects(@mySceneGlobe.children)
    return @cartToLatLong(intersects[0].point.clone().normalize())  if intersects.length > 0
    null
  
  # ===========================================================================
  latLongToCart: (latLong) ->
    x = EARTH_RADIUS * Math.cos(latLong.y * Math.PI / 180) * Math.cos(-latLong.x * Math.PI / 180)
    y = EARTH_RADIUS * Math.sin(latLong.y * Math.PI / 180)
    z = EARTH_RADIUS * Math.cos(latLong.y * Math.PI / 180) * Math.sin(-latLong.x * Math.PI / 180)
    new THREE.Vector3(x, y, z)
  
  # ===========================================================================
  latLongToPixel: (latLong) ->
    pos = @latLongToCart(latLong)
    PROJECTOR.projectVector pos, @myCamera
    pos
  
  # ===========================================================================
  cartToLatLong: (coordinates) ->
    lat = Math.asin(coordinates.y) / Math.PI * 180
    long = -Math.atan(coordinates.x / coordinates.z) / Math.PI * 180 - 90
    long += 180  if coordinates.z > 0
    new THREE.Vector2(lat, long)
  
  # ===========================================================================
  isTileVisible: (minNormalizedLatLong, maxNormalizedLatLong) ->
    if @isFrontFacingTile(minNormalizedLatLong, maxNormalizedLatLong)
      min = @normalizedMercatusToNormalizedLatLong(minNormalizedLatLong)
      max = @normalizedMercatusToNormalizedLatLong(maxNormalizedLatLong)
      a = @latLongToPixel(@unNormalizeLatLong(
        x: min.x
        y: min.y
      ))
      b = @latLongToPixel(@unNormalizeLatLong(
        x: max.x
        y: min.y
      ))
      c = @latLongToPixel(@unNormalizeLatLong(
        x: max.x
        y: max.y
      ))
      d = @latLongToPixel(@unNormalizeLatLong(
        x: min.x
        y: max.y
      ))
      minX = Math.min(Math.min(Math.min(a.x, b.x), c.x), d.x)
      maxX = Math.max(Math.max(Math.max(a.x, b.x), c.x), d.x)
      minY = Math.min(Math.min(Math.min(a.y, b.y), c.y), d.y)
      maxY = Math.max(Math.max(Math.max(a.y, b.y), c.y), d.y)
      return not (minX > 1.0 or minY > 1.0 or maxX < -1.0 or maxY < -1.0)
    false
  
  # ===========================================================================
  isFrontFacingTile: (minNormalizedLatLong, maxNormalizedLatLong) ->
    isOnFrontSide = (pos) =>
      diff = Math.acos(Math.sin((pos.y - 0.5) * Math.PI) * Math.sin((@myCurrentCameraPos.y) * Math.PI / 180.0) + Math.cos((pos.y - 0.5) * Math.PI) * Math.cos((@myCurrentCameraPos.y) * Math.PI / 180.0) * Math.cos(-(pos.x - 0.5) * 2.0 * Math.PI + (@myCurrentCameraPos.x) * Math.PI / 180.0))
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

    isOnFrontSide(a) or isOnFrontSide(b) or isOnFrontSide(c) or isOnFrontSide(d)
  
  # ===========================================================================
  tileChildrenLoaded: (tile) ->
    i = 0
    j = tile.children.length

    while i < j
      return false  if tile.children[i].loadedTextureCount < 16
      i++
    true
  
  # ===========================================================================
  tileLoad: (tile) ->
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
  
  # ===========================================================================
  tileLoadChildren: (tile) ->
    i = 0
    j = tile.children.length

    while i < j
      @tileLoad tile.children[i]  unless tile.children[i].textures?
      i++
  
  # ===========================================================================
  renderTile: (tile) ->
    if @isTileVisible(tile.minLatLong, tile.maxLatLong)
      if tile.z < @myCurrentZoom - 0.5 and tile.children?
        if @tileChildrenLoaded(tile)
          i = 0
          j = tile.children.length

          while i < j
            @renderTile tile.children[i]
            i++
          if tile.opacity < 0.05
            tile.opacity = 0.0
            return
          else tile.opacity = tile.opacity * 0.9  unless @myIsZooming
        @tileLoadChildren tile  unless @myIsZooming
      else
        tile.opacity = 1.0
      @tileLoad tile  unless tile.textures?
      @myGlobeUniforms["tiles"].value = tile.textures
      @myGlobeUniforms["opacity"].value = tile.opacity
      @myGlobeUniforms["minUV"].value = tile.minLatLong
      @myGlobeUniforms["maxUV"].value = tile.maxLatLong
      @myRenderer.render @mySceneGlobe, @myCamera
  
  # ===========================================================================
  normalizedLatLongToNormalizedMercatus: (latLong) ->
    return new THREE.Vector2(latLong.x, 0.0)  if latLong.y is 0.0
    return new THREE.Vector2(latLong.x, 1.0)  if latLong.y is 1.0
    new THREE.Vector2(latLong.x, Math.log(Math.tan(latLong.y * 0.5 * Math.PI)) / (Math.PI * 2.0) + 0.5)
  
  # ===========================================================================
  normalizedMercatusToNormalizedLatLong: (mercatus) ->
    return new THREE.Vector2(mercatus.x, 0.0)  if mercatus.y is 0.0
    return new THREE.Vector2(mercatus.x, 1.0)  if mercatus.y is 1.0
    new THREE.Vector2(mercatus.x, 2.0 / Math.PI * Math.atan(Math.exp(2 * Math.PI * (mercatus.y - 0.5))))
  
  # ===========================================================================
  normalizeLatLong: (latLong) ->
    new THREE.Vector2(latLong.x / 360.0 + 0.5, latLong.y / 180.0 + 0.5)
  
  # ===========================================================================
  unNormalizeLatLong: (normalizedLatLong) ->
    new THREE.Vector2(normalizedLatLong.x * 360.0 - 180.0, normalizedLatLong.y * 180.0 - 90.0)
    
    

