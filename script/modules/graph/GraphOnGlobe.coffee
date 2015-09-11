window.HG ?= {}

class HG.GraphOnGlobe

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    @_globe = null
    @_graphNodeController = null

    @_sceneGraphNode              = new THREE.Scene
    @_sceneGraphNodeConnection    = new THREE.Scene

    @_graphLight             = null

    @_intersectedNodes       = []

    @_visibleNodes           = []

    @_dragStartPos           = null

    @_blockHighlighting      = false

    @_nodeOfInterest         = null

    @_secondNodeOfInterest   = null

    @_highlightedConnections = []

    @_hgInstance = null


    # bundle tests:
    @_connectionMaterials = []
    @_controlPoints = []
    @_controlPoints.push(191.0) # pivot element
    @_controlSize = 20.0
    @_controlFunction = 0.0 # sine



  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areasOnGlobe = @

    @_hgInstance = hgInstance

    @_globe = hgInstance.globe

    @_globeCanvas = hgInstance.mapCanvas

    @_graphController = hgInstance.graphController


    if @_globe
      @_globe.onLoaded @, @_initGraph

    else
      console.log "Unable to show areas on Map: Globe module not detected in HistoGlobe instance!"


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initGraph:() ->

    if @_graphController


      @_graphLight         = new THREE.DirectionalLight( 0xffffff, 1.0);
      @_graphLight.position.set 0, 0, 300
      @_sceneGraphNode.add   @_graphLight
      @_sceneGraphNodeConnection.add   @_graphLight

      if @_hgInstance.graph_button?
        button = @_hgInstance.graph_button
        button.onShowGraph @, () =>
          @_globe.addSceneToRenderer(@_sceneGraphNodeConnection)
          @_globe.addSceneToRenderer(@_sceneGraphNode)
        button.onHideGraph @, () =>
          @_globe.removeSceneFromRenderer(@_sceneGraphNodeConnection)
          @_globe.removeSceneFromRenderer(@_sceneGraphNode)

      else
        @_globe.addSceneToRenderer(@_sceneGraphNodeConnection)
        @_globe.addSceneToRenderer(@_sceneGraphNode)

      window.addEventListener   "mouseup",  @_onMouseUp,         false #for node intersections
      window.addEventListener   "mousedown",@_onMouseDown,       false #for node intersections

      # bundle tests
      window.addEventListener   "keydown",@_onKeyDown,       false
      
      @_graphController.onShowGraphNodeConnection @, (c) =>
        @_showGraphNodeConnection c

      @_graphController.onHideGraphNodeConnection @, (c) =>
        @_hideGraphNodeConnection c

      nodelist = @_graphController.getActiveGraphNodes()
      for key,value of nodelist
        @_showGraphNode value

      conlist = @_graphController.getActiveGraphNodeConnections()
      for c in conlist
        @_showGraphNodeConnection c

      @_graphController.onShowGraphNode @, (node) =>
        @_showGraphNode node

      setInterval(@_animate, 100)

      @_graphController.onHideGraphNode @, (node) =>
        @_hideGraphNode node


    else
      console.error "Unable to show graph on globe: GraphController module not detected in HistoGlobe instance!"

  # ============================================================================
  _animate:() =>
    if @_globe._isRunning
      @_evaluate()

  # ============================================================================
  _showGraphNode: (node) ->

    material = new THREE.MeshBasicMaterial({
      #color: 0x0000ff,
      color: 0x000000,
      side: THREE.DoubleSide,
      opacity     : 0.25,
      transparent : true,
    })

    radius = node._radius
    segments = 32

    circleGeometry = new THREE.CircleGeometry( radius, segments );
    
    circleGeometry.applyMatrix( new THREE.Matrix4().makeScale( Math.pow(1.0 + (Math.abs(node._position[0])/3500),25), 1.0, 1.0) );
    
    mesh = new THREE.Mesh( circleGeometry, material );

    #gps to cart mapping:
    random_height_offset = Math.random()

    for vertex in mesh.geometry.vertices
      cart_coords = @_globe._latLongToCart(
          x:vertex.x + node._position[1]
          y:vertex.y + node._position[0],
          @_globe.getGlobeRadius()+random_height_offset) #remove z fighting
      vertex.x = cart_coords.x
      vertex.y = cart_coords.y
      vertex.z = cart_coords.z

    mesh.geometry.verticesNeedUpdate = true;
    mesh.geometry.normalsNeedUpdate = true;
    mesh.geometry.computeVertexNormals();
    mesh.geometry.computeFaceNormals();
    mesh.geometry.computeBoundingSphere();
    
    @_sceneGraphNode.add( mesh );

    node.Mesh3D = mesh
    mesh.Node = node

    node.Mesh3D.Radius = node._radius

    @_visibleNodes.push node

    #add control point displacing edges:
    @_addControlPoint(@_controlFunction,radius*3.0,node._position[1],node._position[0])

    node.onRadiusChange @, (node) =>
        @_onGraphNodeChanged node

  
  # ============================================================================
  _showGraphNodeConnection: (connection) ->

    connectionOpacity = OPACITY_MIN

    showConnection = true

    isHighlightedConnection = false

    if @_secondNodeOfInterest

      linkedNodes = connection.getLinkedNodes()
      if linkedNodes[0] is @_nodeOfInterest and linkedNodes[1] is @_secondNodeOfInterest or
      linkedNodes[1] is @_nodeOfInterest and linkedNodes[0] is @_secondNodeOfInterest

        connectionOpacity = OPACITY_MAX
        linkedNodes[0].Mesh3D.material.opacity = OPACITY_MAX
        linkedNodes[1].Mesh3D.material.opacity = OPACITY_MAX

        isHighlightedConnection = true

      else
        showConnection = false

    else

      if @_nodeOfInterest
        linkedNodes = connection.getLinkedNodes()
        if(linkedNodes[0] isnt @_nodeOfInterest and linkedNodes[1] isnt @_nodeOfInterest)
           showConnection = false
        else
          connectionOpacity = OPACITY_MAX
          linkedNodes[0].Mesh3D.material.opacity = OPACITY_MAX
          linkedNodes[1].Mesh3D.material.opacity = OPACITY_MAX

    latlngA = connection.startPoint
    latlngB = connection.endPoint

    lineGeometry = new THREE.Geometry

    currentPosLat = latlngA[0]
    currentPosLng = latlngA[1]

    # equidistant interpolation:
    # location range
    lat_diff = latlngB[0]-latlngA[0]
    lng_diff = latlngB[1]-latlngA[1]
    if Math.abs(lng_diff)>180
      lng_diff =(360 - Math.abs(latlngA[1]) - Math.abs(latlngB[1]))/-1

    # location interpolation direction
    dir = new THREE.Vector2 lat_diff,lng_diff
    dir.normalize()

    stepLat = dir.x*0.05
    stepLng = dir.y*0.05

    alphaLat = Math.abs(stepLat)
    alphaLng = Math.abs(stepLng)
    while(currentPosLat < latlngB[0]-(1.1*alphaLat) or currentPosLat > latlngB[0] + (1.1*alphaLat) or
    currentPosLng < latlngB[1]-(1.1*alphaLng) or currentPosLng > latlngB[1] + (1.1*alphaLng) )
      
      # forward coordinate transformation to shader:
      lineGeometry.vertices.push new THREE.Vector3(currentPosLat, currentPosLng, 1.0)

      currentPosLat+= stepLat
      currentPosLng+= stepLng
      if currentPosLng > 180.0 
        currentPosLng = -180.0 + (currentPosLng-180.0)
      if currentPosLng < -180.0
        currentPosLng = 180.0 - (currentPosLng+180.0)



    shader = SHADERS.bundle

    uniforms      = THREE.UniformsUtils.clone shader.uniforms
    uniforms.opacity.value  = connectionOpacity

    uniforms.line_begin.value = lineGeometry.vertices[0]
    uniforms.line_end.value = lineGeometry.vertices[lineGeometry.vertices.length-1]

    # arc:
    uniforms.max_offset.value = 0.0
    line_center = lineGeometry.vertices[Math.round(lineGeometry.vertices.length/2)]
    uniforms.line_center.value = line_center

    # connection group offset:
    dir = new THREE.Vector3 uniforms.line_end.value.x, uniforms.line_end.value.y, uniforms.line_end.value.z
    dir = dir.sub(uniforms.line_begin.value).normalize()
    linked_nodes = connection.getLinkedNodes()
    connection_group = linked_nodes[0].getConnectionsWithNode(linked_nodes[1])
    index = connection_group.indexOf(connection)
    center_index = Math.round(lineGeometry.vertices.length/2)
    for i in [0..lineGeometry.vertices.length-1]

      offset = 1 - Math.pow((Math.abs(center_index-i)/center_index),2)
      offset*= 0.1 # a tenth of a gps degree offset   
      vertex = lineGeometry.vertices[i]
      
      # offset in orthogonal direction to connection:
      vertex.x += offset*index*dir.y
      vertex.y += offset*index*-dir.x


    lineMaterial = new THREE.ShaderMaterial(
      vertexShader:   shader.vertexShader
      fragmentShader: shader.fragmentShader
      uniforms:       uniforms
      transparent:    true
    )

    #reduce number of potential/nearest control points:
    personalPoints = []
    personalPoints.push(191.0) # pivot element
    lineMaterial.maxLat = Math.max(lineGeometry.vertices[0].x,lineGeometry.vertices[lineGeometry.vertices.length-1].x)
    lineMaterial.minLat = Math.min(lineGeometry.vertices[0].x,lineGeometry.vertices[lineGeometry.vertices.length-1].x)
    lineMaterial.maxLng = Math.max(lineGeometry.vertices[0].y,lineGeometry.vertices[lineGeometry.vertices.length-1].y)
    lineMaterial.minLng = Math.min(lineGeometry.vertices[0].y,lineGeometry.vertices[lineGeometry.vertices.length-1].y)
    for i in [0..@_controlPoints.length] by 4
      lat = @_controlPoints[i]
      lng = @_controlPoints[i+1]
      size = @_controlPoints[i+2]
      func = @_controlPoints[i+3]

      if(lat < lineMaterial.maxLat+BUNDLE_TOLERANCE and
      lat > lineMaterial.minLat-BUNDLE_TOLERANCE and
      lng < lineMaterial.maxLng+BUNDLE_TOLERANCE and
      lng > lineMaterial.minLng-BUNDLE_TOLERANCE)
        personalPoints.unshift(func)
        personalPoints.unshift(size)
        personalPoints.unshift(lng)
        personalPoints.unshift(lat)

    lineMaterial.uniforms.control_points.value = personalPoints

    @_connectionMaterials.push(lineMaterial)
  
    connectionLine = new THREE.Line( lineGeometry, lineMaterial)
    if showConnection
      @_sceneGraphNodeConnection.add connectionLine
      connection.isVisible = true
    else
      connection.isVisible = false

    connection.Mesh3D = connectionLine

    if isHighlightedConnection
       @_highlightedConnections.push connection
       @_showGraphNodeConnectionInfo connection

  # ============================================================================
  _hideGraphNodeConnection: (connection) ->
    
    connection.isVisible = false
    if @_secondNodeOfInterest
      linkedNodes = connection.getLinkedNodes()
      linkedNodes[0].Mesh3D.material.opacity = OPACITY_MIN
      linkedNodes[1].Mesh3D.material.color.opacity = OPACITY_MIN

      @_nodeOfInterest.Mesh3D.material.opacity = OPACITY_MAX
      @_secondNodeOfInterest.Mesh3D.material.opacity = OPACITY_MAX
    else
      if @_nodeOfInterest
        linkedNodes = connection.getLinkedNodes()
        if linkedNodes[0] is @_nodeOfInterest
          linkedNodes[1].Mesh3D.material.opacity = OPACITY_MIN
          for c in linkedNodes[1].getConnections()
            if c.isVisible
              linkedNodes[1].Mesh3D.material.opacity = OPACITY_MAX
              break
        if linkedNodes[1] is @_nodeOfInterest
          linkedNodes[0].Mesh3D.material.opacity = OPACITY_MIN
          for c in linkedNodes[0].getConnections()
            if c.isVisible
              linkedNodes[0].Mesh3D.material.opacity = OPACITY_MAX
              break

    if connection.Mesh3D
      index = @_connectionMaterials.indexOf(connection.Mesh3D.material)
      @_connectionMaterials.splice(index, 1) if index > -1
    @_sceneGraphNodeConnection.remove connection.Mesh3D
    connection.Mesh3D = null

    for c in @_highlightedConnections
      if c is connection
        @_sceneGraphNodeConnection.remove c.Label3D


  # ============================================================================
  _showGraphNodeConnectionInfo: (connection) ->

    if connection.Mesh3D

      unless connection.Label3D

        text = "Alliance Type: "
        for t,v of connection.getInfoForShow()
          text+=t if v
          text+=" " if v

        metrics = TEST_CONTEXT.measureText(text)
        textWidth = metrics.width+(2*(TEXT_HEIGHT/10))
        textHeight = TEXT_HEIGHT+(2*(TEXT_HEIGHT/10))

        canvas = document.createElement('canvas')
        canvas.width = textWidth
        canvas.height = textHeight

        context = canvas.getContext('2d')
        context.textAlign = 'center'
        context.font = TEXT_FONT

        context.shadowColor = "#ffffff"
        context.shadowOffsetX = -TEXT_HEIGHT/10
        context.shadowOffsetY = -TEXT_HEIGHT/10

        context.fillText(text,textWidth/2,textHeight*0.75)

        context.shadowOffsetX =  TEXT_HEIGHT/10
        context.shadowOffsetY = -TEXT_HEIGHT/10

        context.fillText(text,textWidth/2,textHeight*0.75)

        context.shadowOffsetX = -TEXT_HEIGHT/10
        context.shadowOffsetY =  TEXT_HEIGHT/10

        context.fillText(text,textWidth/2,textHeight*0.75)

        context.shadowOffsetX =  TEXT_HEIGHT/10
        context.shadowOffsetY =  TEXT_HEIGHT/10

        context.fillStyle="#000000";
        context.fillText(text,textWidth/2,textHeight*0.75)

        texture = new THREE.Texture(canvas)
        texture.needsUpdate = true
        material = new THREE.SpriteMaterial({
          map: texture,
          transparent:false,
          useScreenCoordinates: false,
          scaleByViewport: true,
          sizeAttenuation: false,
          depthTest: false,
          affectedByDistance: false
          })

        sprite = new THREE.Sprite(material)
        sprite.textWidth = textWidth

        @_sceneGraphNodeConnection.add sprite
        sprite.scale.set(textWidth,textHeight,1.0)
        #sprite.position.set position.x,position.y,position.z

        # position
        vertices = connection.Mesh3D.geometry.vertices
        index = @_highlightedConnections.indexOf(connection)
        position = vertices[Math.round(vertices.length*((index+1.0)/(@_highlightedConnections.length+1.0)))]
        cart_coords = @_globe._latLongToCart(
          x:position.y
          y:position.x,
          @_globe.getGlobeRadius())
        sprite.position.set cart_coords.x,cart_coords.y,cart_coords.z

        sprite.MaxWidth = textWidth
        sprite.MaxHeight = textHeight

        connection.Label3D = sprite
      
      else
        @_sceneGraphNodeConnection.add connection.Label3D
        # update position
        vertices = connection.Mesh3D.geometry.vertices
        index = @_highlightedConnections.indexOf(connection)
        position = vertices[Math.round(vertices.length*((index+1.0)/(@_highlightedConnections.length+1.0)))]
        cart_coords = @_globe._latLongToCart(
          x:position.y
          y:position.x,
          @_globe.getGlobeRadius())
        connection.Label3D.position.set cart_coords.x,cart_coords.y,cart_coords.z


  # ============================================================================
  #_hideGraphNode: (node) ->

  # ============================================================================
  #_onNodeChange: (node) =>

  # ============================================================================
  _addControlPoint: (functionID,size,lng,lat) =>

    # remove potential old one
    for i in [0 .. @_controlPoints.length-1] by 4
      if @_controlPoints[i] is lat and @_controlPoints[i+1] is lng
        @_controlPoints.splice(i, 4);
        break

    # interactive point:
    interactive_point = null
    if @_controlPoints.length >= 4
      interactive_point = @_controlPoints.splice(0,4)

    #new point
    new_point = [lat,lng,size,functionID]
    @_controlPoints = new_point.concat(@_controlPoints)

    # individual cp lists of connections
    for mat in @_connectionMaterials

      if(lat < mat.maxLat+BUNDLE_TOLERANCE and
      lat > mat.minLat-BUNDLE_TOLERANCE and
      lng < mat.maxLng+BUNDLE_TOLERANCE and
      lng > mat.minLng-BUNDLE_TOLERANCE)

        mat.uniforms.control_points.value.splice(0,4) if mat.uniforms.control_points.value.length >= 4
        # remove potential old one
        found_old = false
        for i in [0 .. mat.uniforms.control_points.value.length-1] by 4
          if mat.uniforms.control_points.value[i] is lat and mat.uniforms.control_points.value[i+1] is lng
            mat.uniforms.control_points.value[i+2] = size
            mat.uniforms.control_points.value[i+3] = functionID
            found_old = true
            #mat.uniforms.control_points.value.splice(i, 4);
            break
        mat.uniforms.control_points.value = new_point.concat(mat.uniforms.control_points.value) if not found_old
        mat.uniforms.control_points.value = interactive_point.concat(mat.uniforms.control_points.value) if interactive_point isnt null

    # interactive point:
    if interactive_point != null
      @_controlPoints = interactive_point.concat(@_controlPoints)

        

  # ============================================================================
  #bundle tests
  _onKeyDown: (key) =>
    if key.keyCode is 187 # +
      @_controlSize += 1
    if key.keyCode is 189 # -
      @_controlSize -= 1
    if key.keyCode is 13 # ENTER
      @_addControlPoint(@_controlPoints[3],@_controlPoints[2],@_controlPoints[1],@_controlPoints[0])
    if key.keyCode is 70 # F
      @_controlFunction += 1.0
      @_controlFunction = @_controlFunction % 2
      console.log @_controlFunction


  # ============================================================================
  _onMouseDown: (event) =>

    event.preventDefault()
    clickMouse =
      x: (@_globe._mousePos.x - @_globe._canvasOffsetX) / @_globe._width * 2 - 1
      y: (@_globe._mousePos.y - @_globe._canvasOffsetY) / @_globe._myHeight * 2 - 1

    @_dragStartPos = @_globe._pixelToLatLong(clickMouse)


  # ============================================================================
  _onMouseUp: (event) =>

    clickMouse =
      x: (@_globe._mousePos.x - @_globe._canvasOffsetX) / @_globe._width * 2 - 1
      y: (@_globe._mousePos.y - @_globe._canvasOffsetY) / @_globe._myHeight * 2 - 1

    clickPos = @_globe._pixelToLatLong(clickMouse)

    raycaster = @_globe.getRaycaster()

    if clickPos? and @_dragStartPos?
      if (clickPos.x - @_dragStartPos.x is 0) and (clickPos.y - @_dragStartPos.y is 0)

        nodeIntersects = raycaster.intersectObjects @_sceneGraphNode.children
        
        if nodeIntersects.length is 0 or @_secondNodeOfInterest
          #show all
          for c in @_graphController.getActiveGraphNodeConnections()
             @_sceneGraphNodeConnection.add c.Mesh3D if not c.isVisible and c.Mesh3D
             c.isVisible = true
          @_blockHighlighting = false
          @_nodeOfInterest = null
          @_secondNodeOfInterest = null

          for c in @_highlightedConnections
            @_sceneGraphNodeConnection.remove c.Label3D
          @_highlightedConnections = []

          @_evaluate()
        
        #hide uninvolved
        if nodeIntersects.length > 0

          if @_nodeOfInterest and nodeIntersects[0].object.Node isnt @_nodeOfInterest
            @_secondNodeOfInterest = @_nodeOfInterest
            @_intersectedNodes.push nodeIntersects[0].object
            @_nodeOfInterest = nodeIntersects[0].object.Node
            for c in @_secondNodeOfInterest.getConnections()

              #info:
              if c.isActive() and c.getLinkedNodes()[0] is @_nodeOfInterest and c.getLinkedNodes()[1] is @_secondNodeOfInterest or
              c.getLinkedNodes()[1] is @_nodeOfInterest and c.getLinkedNodes()[0] is @_secondNodeOfInterest
                @_highlightedConnections.push c

              for node in c.getLinkedNodes()
                if node isnt @_nodeOfInterest and node isnt @_secondNodeOfInterest
                  #c_color = c.getColor()
                  c.Mesh3D.material.uniforms.max_offset.value = 0.0 if c.Mesh3D
                  c.Mesh3D.material.uniforms.opacity.value = OPACITY_MIN if c.Mesh3D
                  node.Mesh3D.material.opacity = OPACITY_MIN if node.Mesh3D

            @_nodeOfInterest.Mesh3D.material.opacity = OPACITY_MAX

            for hc in @_highlightedConnections 
              @_showGraphNodeConnectionInfo(hc)

          @_nodeOfInterest = nodeIntersects[0].object.Node

          to_be_removed = [].concat(@_graphController.getActiveGraphNodeConnections())
          for c in nodeIntersects[0].object.Node.getConnections()

            index = $.inArray(c, to_be_removed)
            to_be_removed.splice index, 1  if index >= 0
            c.Mesh3D.material.uniforms.max_offset.value = 30.0  if c.Mesh3D


          @_blockHighlighting = true

          for c in to_be_removed
            @_sceneGraphNodeConnection.remove c.Mesh3D if c.Mesh3D
            c.isVisible = false

  # ============================================================================
  _onGraphNodeChanged: (node) =>

    if node.Mesh3D.Radius isnt node._radius
      old_color = node.Mesh3D.material.color
      @_sceneGraphNode.remove node.Mesh3D
      @_showGraphNode node
      node.Mesh3D.material.color=old_color

  # ============================================================================
  _evaluate: () =>

    unless @_blockHighlighting

      mouseRel =
      x: (@_globe._mousePos.x - @_globe._canvasOffsetX) / @_globe._width * 2 - 1
      y: (@_globe._mousePos.y - @_globe._canvasOffsetY) / @_globe._myHeight * 2 - 1


      # ###############
      # # bundle tests:
      # # interactive mouse lense
      # latLongCurr = @_globe._pixelToLatLong mouseRel
      # if latLongCurr isnt null
      #   if @_controlPoints.length > 1
      #     @_controlPoints.slice(0,4)

      #   updated_point = [latLongCurr.x,-latLongCurr.y,@_controlSize,@_controlFunction]
      #   @_controlPoints = updated_point.concat(@_controlPoints)
      #   for mat in @_connectionMaterials
      #     mat.uniforms.control_points.value.splice(0,4)
      #     mat.uniforms.control_points.value = updated_point.concat(mat.uniforms.control_points.value)
      #     #mat.uniforms.control_points.value = @_controlPoints
      # ###############


      # picking ------------------------------------------------------------------
      # test for mark and highlight hivents
      vector = new THREE.Vector3 mouseRel.x, -mouseRel.y, 0.5
      projector = @_globe.getProjector()
      projector.unprojectVector vector, @_globe._camera

      raycaster = @_globe.getRaycaster()

      raycaster.set @_globe._camera.position, vector.sub(@_globe._camera.position).normalize()

      nodeIntersects = raycaster.intersectObjects @_sceneGraphNode.children

      if nodeIntersects.length > 0
        HG.Display.CONTAINER.style.cursor = "pointer"
      else
        HG.Display.CONTAINER.style.cursor = "auto"

      for intersect in @_intersectedNodes

        for c in intersect.Node.getConnections()
          c.Mesh3D.material.uniforms.max_offset.value = 0.0  if c.Mesh3D
          c.Mesh3D.material.uniforms.opacity.value =  OPACITY_MIN if c.Mesh3D
          for node in c.getLinkedNodes()
            node.Mesh3D.material.opacity = OPACITY_MIN if node.Mesh3D
        intersect.Node.Mesh3D.material.opacity = OPACITY_MIN

      #hover countries
      for intersect in nodeIntersects 
        index = $.inArray(intersect.object, @_intersectedNodes)
        @_intersectedNodes.splice index, 1  if index >= 0

      @_intersectedNodes = []
      # hover intersected countries
      for intersect in nodeIntersects

        for c in intersect.object.Node.getConnections()
          if c.isVisible
            c.Mesh3D.material.uniforms.opacity.value = OPACITY_MAX if c.Mesh3D

            for node in c.getLinkedNodes()
              node.Mesh3D.material.opacity = OPACITY_MAX if node.Mesh3D

        intersect.object.material.opacity = OPACITY_MAX
      
        @_intersectedNodes.push intersect.object

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################
  TEXT_HEIGHT = 14
  TEXT_FONT = "#{TEXT_HEIGHT}px Lobster"

  #testCanvas for Sprites
  TEST_CANVAS = document.createElement('canvas')
  TEST_CANVAS.width = 1
  TEST_CANVAS.height = 1
  TEST_CONTEXT = TEST_CANVAS.getContext('2d')
  TEST_CONTEXT.textAlign = 'center'
  TEST_CONTEXT.font = TEXT_FONT

  OPACITY_MIN = 0.1
  OPACITY_MAX = 0.6

  BUNDLE_TOLERANCE = 2.0 # degree

  # shaders for the graph node connections
  SHADERS =
    arc:
      uniforms:

        max_offset:
          type: "f"
          value: 0.0

        line_center:
          type: "v3"
          value: null

        line_begin:
          type: "v3"
          value: null

        line_end:
          type: "v3"
          value: null  

        opacity:
          type: "f"
          value: 0.0

      vertexShader: '''
        uniform float max_offset;
        uniform vec3 line_center;
        uniform vec3 line_begin;
        uniform vec3 line_end;

        varying vec3 vColor;

        void main() {
          float dist1 = abs(length(line_center-position));
          float dist_begin = abs(length(line_center-line_begin));
          float dist_end = abs(length(line_center-line_end));
          float dist2 = max(dist_begin,dist_end);
          
          if(abs(length(line_begin-position)) < abs(length(line_end-position))){
            dist2 = dist_begin;
          }
          else{
            dist2 =dist_end;
          }

          float factor = dist1/dist2;

          vec3 out_dir = -1.0 * normalize(vec3(0.0,0.0,0.0)-position);
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position + ((1.0-pow(factor,2.0)) * max_offset * out_dir), 1.0);

          if(dist1 <= dist2){
            vColor = vec3(0.0,1.0,0.0);
          }
          else{
            vColor = vec3(1.0,0.0,0.0);
          }
        }
      '''

      fragmentShader: '''
        uniform float opacity;

        varying vec3 vColor;

        void main() {
          gl_FragColor     = vec4( 0.0,0.0,0.0, opacity );
          //gl_FragColor     = vec4( vColor.xyz, opacity );
        }
      '''

    bundle:
      uniforms:

        control_points:
          type: "fv1"
          value: []

        control_size:
          type: "f"
          value: 20.0

        opacity:
          type: "f"
          value: 0.0

        line_begin:
          type: "v3"
          value: null

        line_end:
          type: "v3"
          value: null

        max_offset:
          type: "f"
          value: 0.0

        line_center:
          type: "v3"
          value: null

      vertexShader: '''

        uniform float control_points[1000];
        uniform float control_size;
        uniform vec3 line_begin;
        uniform vec3 line_end;

        //arc:
        uniform float max_offset;
        uniform vec3 line_center;

        varying vec3 vColor;


        void main() {

          vec2 gps_point = vec2(position.y,position.x);

          if (max_offset == 0.0){

            float bundle_offset_lat = 0.0;
            float bundle_offset_lng = 0.0;

            for(int i = 0 ; i < 1000; i+=4){

              if(control_points[i]<190.0){

                vec2 point_of_interest = vec2(control_points[i+1],control_points[i]);
                //vec2 gps_point = vec2(position.x,position.y);
                vec2 dir = point_of_interest - gps_point;
                float dist = length(dir);
                float reach = control_points[i+2];

                if(dist <= reach){ 

                  dir = normalize(dir);

                  vec2 distStart_vec = point_of_interest - vec2(line_begin.y,line_begin.x);
                  float distStart = length(distStart_vec);
                  vec2 distEnd_vec = point_of_interest - vec2(line_end.y,line_end.x);
                  float distEnd = length(distEnd_vec);

                  float strength = reach/2.0;
                  //float strength = reach/3.14159265358979323846264;
                  float power = 2.0;
                   
                  if(distStart > reach && distEnd > reach){
                     
                      float x_value = 1.0-(dist/reach);

                      if(control_points[i+3] == 0.0){
                        bundle_offset_lat += pow(sin(x_value*3.14159265358979323846264*0.5),power)*-1.0*dir.x*strength;
                        bundle_offset_lng += pow(sin(x_value*3.14159265358979323846264*0.5),power)*-1.0*dir.y*strength;
                      }
                      else{
                        bundle_offset_lat += pow(x_value,power)*-1.0*dir.x*strength;
                        bundle_offset_lng += pow(x_value,power)*-1.0*dir.y*strength;
                      }
                  }
                }
              }
              else{
                break;
              }
            }

            gps_point.x += bundle_offset_lat;
            gps_point.y += bundle_offset_lng;
          }

          float x = 200.0 * cos(gps_point.y * 3.14159265358979323846264 / 180.0) * cos(-gps_point.x * 3.14159265358979323846264 / 180.0);
          float y = 200.0 * sin(gps_point.y * 3.14159265358979323846264 / 180.0);
          float z = 200.0 * cos(gps_point.y * 3.14159265358979323846264 / 180.0) * sin(-gps_point.x * 3.14159265358979323846264 / 180.0);

          //gl_Position = projectionMatrix * modelViewMatrix * vec4(x,y,z,1.0);

          //arc:
          float x_center = 200.0 * cos(line_center.x * 3.14159265358979323846264 / 180.0) * cos(-line_center.y * 3.14159265358979323846264 / 180.0);
          float y_center = 200.0 * sin(line_center.x * 3.14159265358979323846264 / 180.0);
          float z_center = 200.0 * cos(line_center.x * 3.14159265358979323846264 / 180.0) * sin(-line_center.y * 3.14159265358979323846264 / 180.0);
          float x_begin = 200.0 * cos(line_begin.x * 3.14159265358979323846264 / 180.0) * cos(-line_begin.y * 3.14159265358979323846264 / 180.0);
          float y_begin = 200.0 * sin(line_begin.x * 3.14159265358979323846264 / 180.0);
          float z_begin = 200.0 * cos(line_begin.x * 3.14159265358979323846264 / 180.0) * sin(-line_begin.y * 3.14159265358979323846264 / 180.0);
          float x_end = 200.0 * cos(line_end.x * 3.14159265358979323846264 / 180.0) * cos(-line_end.y * 3.14159265358979323846264 / 180.0);
          float y_end = 200.0 * sin(line_end.x * 3.14159265358979323846264 / 180.0);
          float z_end = 200.0 * cos(line_end.x * 3.14159265358979323846264 / 180.0) * sin(-line_end.y * 3.14159265358979323846264 / 180.0);

          vec3 line_center_xyz = vec3(x_center,y_center,z_center);
          vec3 line_begin_xyz = vec3(x_begin,y_begin,z_begin);
          vec3 line_end_xyz = vec3(x_end,y_end,z_end);
          vec3 position_xyz = vec3(x,y,z);
          
          float dist1 = abs(length(line_center_xyz-position_xyz));
          float dist_begin = abs(length(line_center_xyz-line_begin_xyz));
          float dist_end = abs(length(line_center_xyz-line_end_xyz));
          float dist2 = max(dist_begin,dist_end);
          if(abs(length(line_begin_xyz-position_xyz)) < abs(length(line_end_xyz-position_xyz))){
            dist2 = dist_begin;
          }
          else{
            dist2 =dist_end;
          }
          float factor = dist1/dist2;
          vec3 out_dir = -1.0 * normalize(vec3(0.0,0.0,0.0)-vec3(x,y,z));

          gl_Position = projectionMatrix * modelViewMatrix * vec4(vec3(x,y,z) + ((1.0-pow(factor,2.0)) * max_offset * out_dir), 1.0);

        }
      '''

      fragmentShader: '''
        uniform float opacity;

        varying vec3 vColor;

        void main() {
          //gl_FragColor     = vec4( 0.0,0.0,0.0, opacity );
          gl_FragColor     = vec4( vColor.xyz, opacity );
        }
      '''
