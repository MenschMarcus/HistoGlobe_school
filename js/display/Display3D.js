//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display3D = function(inContainer, inMap, inHiventHandler) {
  
  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////
  
  /////////////////////////// STATIC CONSTANTS /////////////////////////////////
  
  // used for picking
  HG.Display3D.PROJECTOR = new THREE.Projector();
  HG.Display3D.RAYCASTER = new THREE.Raycaster();
  
  // radius of the globe
  HG.Display3D.EARTH_RADIUS = 200;
  
  // camera distance to globe, its maximum longitude a the zoom spped
  HG.Display3D.CAMERA_DISTANCE = 500;
  HG.Display3D.CAMERA_MAX_LONG = 80;
  HG.Display3D.CAMERA_ZOOM_SPEED = 0.1;
  
  // shaders for the globe and its atmosphere 
  HG.Display3D.SHADERS = {
    'earth' : {
      uniforms: {
        'texture': { type: 't', value: null}
      },
      vertexShader: [
      'varying vec3 vNormal;',
      'varying vec2 vUv;',
      'void main() {',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
        'vNormal = normalize( normalMatrix * normal );',
        'vUv = uv;',
      '}'
      ].join('\n'),
      fragmentShader: [
      'uniform sampler2D texture;',
      'varying vec3 vNormal;',
      'varying vec2 vUv;',
      'void main() {',
        'vec3 diffuse = texture2D( texture, vUv ).xyz;',
        'float specular = max(0.0, pow(dot( vNormal, normalize(vec3( -0.3, 0.4, 0.7)) ), 30.0));',
        'float atmosphere =  pow(1.0 - dot( vNormal, vec3( 0.0, 0.0, 1.0 ) ), 2.0) * 0.5;',
        'gl_FragColor = vec4( diffuse + atmosphere + specular * 0.1, 1.0 );',
      '}'
      ].join('\n')
    },
    'atmosphere' : {
      uniforms: {
        'bgColor': { type: 'v3', value: null}
      },
      vertexShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'vNormal = normalize( normalMatrix * normal );',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
      '}'
      ].join('\n'),
      fragmentShader: [
      'uniform vec3 bgColor;',
      'varying vec3 vNormal;',
      'void main() {',
        'float intensity = max(0.0, -0.05 + pow( -dot( vNormal, vec3( 0, 0, 1.0 ) ) + 0.5, 5.0 ));',
        'gl_FragColor = vec4(vec3( 1.0, 1.0, 1.0) * intensity + bgColor * (1.0-intensity), 1.0 );',
      '}'
      ].join('\n')
    },
    'hivent' : {
      uniforms: {
        'color': { type: 'v3', value: null}
      },
      vertexShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'vNormal = normalize( normalMatrix * normal );',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
      '}'
      ].join('\n'),
      fragmentShader: [
      'uniform vec3 color;',
      'varying vec3 vNormal;',
      'void main() {',
        'gl_FragColor = vec4(color, 1.0);',
      '}'
      ].join('\n')
    }
  };
  
  ////////////////////////////// FUNCTIONS /////////////////////////////////////
  
  // ===========================================================================
  this.create = function() {

    // init methods
    initWindowGeometry();
    initGlobe();
    initRenderer();
    initHivents();
    initEventHandling();
  }
  
  // ===========================================================================
  this.start = function() { 
    if (!myIsRunning) {  
      myIsRunning = true;
      myRenderer.domElement.style.display = "inline";
      animate();
    }
  }  
  
  // ===========================================================================
  this.stop = function() {  
    myIsRunning = false;
    HG.deactivateAllHivents();
    myRenderer.domElement.style.display = "none";
  }   
  
  // ===========================================================================
  this.isRunning = function() {
    return myIsRunning;
  } 
  
  // ===========================================================================
  this.getCanvas = function() {
    return myRenderer.domElement;
  }
  
  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////
  
  /////////////////////////// MEMBER VARIABLES /////////////////////////////////
  
  // THREE js
  var myCamera, myRenderer;
  var mySceneGlobe, mySceneAtmosphere;
  
  // window geometry
  var myWidth, myHeight;
  var myCanvasOffsetX, myCanvasOffsetY;

  var myLastIntersected = [];
  
  var myCurrentCameraPos = { x: 0, y: 0 };
  var myTargetCameraPos = { x: 10, y: 50 };

  var mouse = { x: 0, y: 0 };
  var myDragStartPos;

  var myCurrentFOV = 90, myTargetFOV = 50;

  var myMapTexture;
  
  var myIsRunning = false;
  
  ////////////////////////// INIT FUNCTIONS ////////////////////////////////////
  
  // ===========================================================================
  function initWindowGeometry() {
    myWidth = $(container.parentNode).innerWidth();
    myHeight = $(container.parentNode).innerHeight();

    myCanvasOffsetX = $(container.parentNode).offset().left;
    myCanvasOffsetY = $(container.parentNode).offset().top;	
  }
  
  // ===========================================================================
  function initGlobe() {
    myCamera = new THREE.PerspectiveCamera(myCurrentFOV, myWidth / myHeight, 1, 10000);
    myCamera.position.z = HG.Display3D.CAMERA_DISTANCE;
    mySceneGlobe = new THREE.Scene();
    mySceneAtmosphere = new THREE.Scene();

    var geometry = new THREE.SphereGeometry(HG.Display3D.EARTH_RADIUS, 60, 30);

    var shader = HG.Display3D.SHADERS['earth'];
    var uniforms = THREE.UniformsUtils.clone(shader.uniforms);

    myMapTexture = new THREE.Texture(inMap.getCanvas());
    myMapTexture.needsUpdate = true;
    uniforms['texture'].value = myMapTexture;

    var material = new THREE.ShaderMaterial({
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader,
      uniforms: uniforms
    });
    
    var globe = new THREE.Mesh(geometry, material);
    globe.matrixAutoUpdate = false;
    mySceneGlobe.add(globe);

    shader = HG.Display3D.SHADERS['atmosphere'];
    uniforms = THREE.UniformsUtils.clone(shader.uniforms);
    uniforms['bgColor'].value = new THREE.Vector3(0.92549, 0.92549, 0.92549);

    material = new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader
    });

    var atmosphere = new THREE.Mesh(geometry, material);
    atmosphere.scale.x = atmosphere.scale.y = atmosphere.scale.z = 1.5;
    atmosphere.flipSided = true;
    atmosphere.matrixAutoUpdate = false;
    atmosphere.updateMatrix();
    mySceneAtmosphere.add(atmosphere);
  }
  
  // ===========================================================================
  function initRenderer() {
    myRenderer = new THREE.WebGLRenderer({antialias: true});
    myRenderer.autoClear = false;
    myRenderer.setClearColor(0x000000, 0.0);
    myRenderer.setSize(myWidth, myHeight);

    myRenderer.domElement.style.position = 'absolute';

    container.appendChild(myRenderer.domElement);
  }
  
  // ===========================================================================
  function initEventHandling() {
    container.addEventListener('mousedown', onMouseDown, false);
    container.addEventListener('mousemove', onMouseMove, false);
    container.addEventListener('mouseup', onMouseUp, false);

    container.addEventListener('mousewheel', function(event) {
      event.preventDefault();
      onMouseWheel(event.wheelDelta);
      return false;
    }, false);
                  
    container.addEventListener('DOMMouseScroll', function(event) {
      event.preventDefault();
      onMouseWheel(-event.detail*30);
      return false;
    }, false);

    document.addEventListener('keydown', onDocumentKeyDown, false);

    window.addEventListener('resize', onWindowResize, false);
  }
  
  // ===========================================================================
  function initHivents() {
    
    inHiventHandler.onHiventsLoaded( function(handles) {
      
      for (var i=0; i<handles.length; i++) {
              
        var hivent = new HG.HiventMarker3D(handles[i]);
        mySceneGlobe.add(hivent);
        
        var position = longLatToCart(new THREE.Vector2(handles[i].getHivent().long, handles[i].getHivent().lat), HG.Display3D.EARTH_RADIUS);
        
        hivent.translateOnAxis(new THREE.Vector3(1,0,0), position.x);
        hivent.translateOnAxis(new THREE.Vector3(0,1,0), position.y);
        hivent.translateOnAxis(new THREE.Vector3(0,0,1), position.z);
      }
    });
  }
  
  /////////////////////////// MAIN FUNCTIONS ///////////////////////////////////
  
  // ===========================================================================
  function animate() {
    if (myIsRunning) {
      //inMap.redraw();
      //myMapTexture.needsUpdate = true;
      render();
      requestAnimationFrame(animate);
    }
  }
  
  // ===========================================================================
  function render() {
    
    var mouseRel  = {x: (mouse.x - myCanvasOffsetX) / myWidth * 2 - 1,
                     y: (mouse.y - myCanvasOffsetY) / myHeight * 2 - 1};
    
    // picking -----------------------------------------------------------------
    
    // test for hover and highlight hivents         
    var vector = new THREE.Vector3(mouseRel.x, -mouseRel.y, 0.5);
    HG.Display3D.PROJECTOR.unprojectVector(vector, myCamera);
    HG.Display3D.RAYCASTER.set(myCamera.position, vector.sub(myCamera.position).normalize());
    var intersects = HG.Display3D.RAYCASTER.intersectObjects(mySceneGlobe.children);

    for (var i = 0; i < intersects.length; i++) {
      if (intersects[i].object instanceof HG.HiventMarker3D) {
        var index = $.inArray(intersects[i].object, myLastIntersected);
        if (index >= 0) {
          myLastIntersected.splice(index, 1);
        }
      }
    }

    for (var i = 0; i < myLastIntersected.length; i++) {
      myLastIntersected[i].unHover(mouse);
    }
    
    myLastIntersected = [];

    for (var i = 0; i < intersects.length; i++) {
      if (intersects[i].object instanceof HG.HiventMarker3D) {
        myLastIntersected.push(intersects[i].object);
        intersects[i].object.hover(mouse);
      }
    }
    
    //myCamera.updateProjectionMatrix();
    
    // globe rotation ----------------------------------------------------------
    
    // if there is a drag going on - rotate globe
    if (myDragStartPos) {
      
      var longLatCurr = mouseToLongLat(mouseRel);
      
      // if mouse is still over the globe
      if (longLatCurr) {
      
        if (myDragStartPos.x - longLatCurr.x > 180) {
          myDragStartPos.x -= 360;
        } else if (myDragStartPos.x - longLatCurr.x < -180) {
          myDragStartPos.x += 360;
        }
  
        myTargetCameraPos.x += 0.3 * (myDragStartPos.x - longLatCurr.x);
        myTargetCameraPos.y += 0.3 * (myDragStartPos.y - longLatCurr.y);
        
        if (myTargetCameraPos.y > HG.Display3D.CAMERA_MAX_LONG) {
          myTargetCameraPos.y = HG.Display3D.CAMERA_MAX_LONG;
        }
        
        if (myTargetCameraPos.y < -HG.Display3D.CAMERA_MAX_LONG) {
          myTargetCameraPos.y = -HG.Display3D.CAMERA_MAX_LONG;
        }
        
      } else {
        myDragStartPos = null;
        container.style.cursor = 'auto';
      }
    }
    
    var smoothness = 0.7;
    
    myCurrentCameraPos.x = myCurrentCameraPos.x * (smoothness) + myTargetCameraPos.x * (1.0 - smoothness);
    myCurrentCameraPos.y = myCurrentCameraPos.y * (smoothness) + myTargetCameraPos.y * (1.0 - smoothness);
    
    var rotation = {x: myCurrentCameraPos.x * Math.PI / 180,
                    y: myCurrentCameraPos.y * Math.PI / 180};
   
    myCamera.position.x = HG.Display3D.CAMERA_DISTANCE * Math.sin(-rotation.x + Math.PI*0.5) * Math.cos(rotation.y);
    myCamera.position.y = HG.Display3D.CAMERA_DISTANCE * Math.sin(rotation.y);
    myCamera.position.z = HG.Display3D.CAMERA_DISTANCE * Math.cos(-rotation.x + Math.PI*0.5) * Math.cos(rotation.y);
    myCamera.lookAt(new THREE.Vector3(0,0,0));
    
    // zooming -----------------------------------------------------------------
    
    myCurrentFOV = myCurrentFOV * smoothness + myTargetFOV * (1.0 - smoothness);
    myCamera.fov = myCurrentFOV;
    myCamera.updateProjectionMatrix();
    
    // rendering ---------------------------------------------------------------
    
    myRenderer.clear();
    myRenderer.setFaceCulling(THREE.CullFaceBack);
    myRenderer.render(mySceneGlobe, myCamera);
    myRenderer.setFaceCulling(THREE.CullFaceFront);
    myRenderer.render(mySceneAtmosphere, myCamera);
  }
  
  // ===========================================================================
  function zoom(delta) {
    myTargetFOV -= delta*HG.Display3D.CAMERA_ZOOM_SPEED;
    myTargetFOV = myTargetFOV > 50 ? 50 : myTargetFOV;
    myTargetFOV = myTargetFOV < 10 ? 10 : myTargetFOV;
  }
  
  
  ////////////////////////// EVENT HANDLING ////////////////////////////////////
  
  // ===========================================================================
  function onMouseDown(event) {
    if (myIsRunning) {  
      event.preventDefault();

      var clickMouse = {x: (event.clientX - myCanvasOffsetX) / myWidth * 2 - 1,
                        y: (event.clientY - myCanvasOffsetY) / myHeight * 2 - 1};
      
      myDragStartPos = mouseToLongLat(clickMouse);
      
      if (myDragStartPos) {
        container.style.cursor = 'move';
      } 
   }
  }
  
  // ===========================================================================
  function onMouseMove(event) {
    if (myIsRunning) { 
      mouse = {x: event.clientX,
               y: event.clientY};
    }
  }
  
  // ===========================================================================
  function onMouseUp(event) {
    if (myIsRunning) { 
      event.preventDefault();
      container.style.cursor = 'auto';
      
      myDragStartPos = null;
      myDragStartCamera = null;
      
      if (myLastIntersected.length == 0) {
        HG.deactivateAllHivents();
      } else {
        for (var i = 0; i < myLastIntersected.length; i++) {
          myLastIntersected[i].active(mouse);
        }
      }
    }
  }
  
  // ===========================================================================
  function onMouseWheel(delta) {
    if (myIsRunning) { 
      zoom(delta * 0.3);
    }
    return false;
  }
  
  // ===========================================================================
  function onDocumentKeyDown(event) {
    if (myIsRunning) { 
      switch (event.keyCode) {
        case 38:
          zoom(100);
          event.preventDefault();
          break;
        case 40:
          zoom(-100);
          event.preventDefault();
          break;
      }
    }
  }
  
  // ===========================================================================
  function onWindowResize(event) {
    myCamera.aspect = $(container.parentNode).innerWidth() 
                    / $(container.parentNode).innerHeight();
    myCamera.updateProjectionMatrix();
    myRenderer.setSize($(container.parentNode).innerWidth(), 
                     $(container.parentNode).innerHeight());
    
    initWindowGeometry();
  }
  
  ///////////////////////// HELPER FUNCTIONS ///////////////////////////////////
  
  // ===========================================================================
  function mouseToLongLat(inMousePos) {
    var vector = new THREE.Vector3(inMousePos.x, -inMousePos.y, 0.5);
	  HG.Display3D.PROJECTOR.unprojectVector(vector, myCamera);
    HG.Display3D.RAYCASTER.set(myCamera.position, vector.sub(myCamera.position).normalize());
    
	  var intersects = HG.Display3D.RAYCASTER.intersectObjects(mySceneGlobe.children);
	
	  if (intersects.length > 0) {
	      return cartToLongLat(intersects[0].point.clone().normalize());
	  }
	  
	  return null;
  }
  
  // ===========================================================================
  function longLatToCart(longlat, radius) {
    var x = radius * Math.cos(longlat.y * Math.PI/180) 
                   * Math.cos(longlat.x * Math.PI/180); 
    var y = radius * Math.sin(longlat.y * Math.PI/180); 
    var z = radius * Math.cos(longlat.y * Math.PI/180) 
                   * Math.sin(longlat.x * Math.PI/180);
    
    return new THREE.Vector3(x,y,z);  
  }
  
  // ===========================================================================
  function cartToLongLat(coordinates) {
    var lat = Math.asin(coordinates.y) / Math.PI * 180;
    var long = -Math.atan(coordinates.x / coordinates.z) / Math.PI * 180 - 90;
    
    if (coordinates.z > 0) {
      long += 180;
    } 
  
    return new THREE.Vector2(long, lat);
  }
  
  // create the object!
  this.create();
  
  // all done!
  return this;

};

