//include Display.js
//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display3D = function(inContainer, inHiventHandler) {

  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// STATIC CONSTANTS /////////////////////////////////

  // used for picking
  HG.Display3D.PROJECTOR = new THREE.Projector();
  HG.Display3D.RAYCASTER = new THREE.Raycaster();
  
  // background color
  HG.Display3D.BACKGROUND = new THREE.Color(0xCCCCCC);
  HG.Display3D.TILE_PATH  = "data/tiles/";
  
  // radius of the globe
  HG.Display3D.EARTH_RADIUS = 200;

  // camera distance to globe, its maximum longitude a the zoom spped
  HG.Display3D.CAMERA_DISTANCE = 500;
  HG.Display3D.CAMERA_MAX_ZOOM = 5;
  HG.Display3D.CAMERA_MIN_ZOOM = 2;
  HG.Display3D.CAMERA_MAX_LONG = 80;
  HG.Display3D.CAMERA_ZOOM_SPEED = 0.1;
  
  
  // shaders for the globe and its atmosphere
  HG.Display3D.SHADERS = {
    'earth' : {
      uniforms: {
        'tiles': { type: 'tv', value: []},
        'minUV': { type: 'v2', value: null},
        'maxUV': { type: 'v2', value: null}
      },
      vertexShader: [
      'varying vec3 vNormal;',
      'varying vec2 vTexcoord;',
      
      'float convertCoords(float lat) {',
        'if (lat == 0.0) return 0.0;',
        'if (lat == 1.0) return 1.0;',
        'const float pi = 3.1415926535897932384626433832795;',
        'return log(tan(lat*0.5 * pi)) / (pi * 2.0) + 0.5;',
      '}',
      
      'void main() {',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
        'vNormal = normalize( normalMatrix * normal );',
        'vTexcoord = vec2(uv.x, convertCoords(uv.y));',
      '}'
      ].join('\n'),
      fragmentShader: [
      'uniform sampler2D tiles[16];',
      'uniform vec2 minUV;',
      'uniform vec2 maxUV;',
      'varying vec3 vNormal;',
      'varying vec2 vTexcoord;',
      'void main() {',
        'if (minUV.x > vTexcoord.x || maxUV.x < vTexcoord.x ||',
            'minUV.y > vTexcoord.y || maxUV.y < vTexcoord.y)',
              'discard;',
        'vec2 uv = (vTexcoord - minUV)/(maxUV - minUV);',
        //'gl_FragColor     = vec4( uv, 0.0, 1.0 ); return;',
         
        'vec3 diffuse = vec3(0);',
        'float size = 0.25;',
        
        'if      (uv.x < 1.0*size && uv.y < 1.0*size)',
          'diffuse = texture2D( tiles[ 0], uv * 4.0 - vec2(1, 1) + vec2(1, 1)).xyz;',
        'else if (uv.x < 1.0*size && uv.y < 2.0*size)',
          'diffuse = texture2D( tiles[ 1], uv * 4.0 - vec2(1, 2) + vec2(1, 1)).xyz;',
        'else if (uv.x < 1.0*size && uv.y < 3.0*size)',
          'diffuse = texture2D( tiles[ 2], uv * 4.0 - vec2(1, 3) + vec2(1, 1)).xyz;',
        'else if (uv.x < 1.0*size && uv.y < 4.0*size)',
          'diffuse = texture2D( tiles[ 3], uv * 4.0 - vec2(1, 4) + vec2(1, 1)).xyz;',
        'else if (uv.x < 2.0*size && uv.y < 1.0*size)',
          'diffuse = texture2D( tiles[ 4], uv * 4.0 - vec2(2, 1) + vec2(1, 1)).xyz;',
        'else if (uv.x < 2.0*size && uv.y < 2.0*size)',
          'diffuse = texture2D( tiles[ 5], uv * 4.0 - vec2(2, 2) + vec2(1, 1)).xyz;',
        'else if (uv.x < 2.0*size && uv.y < 3.0*size)',
          'diffuse = texture2D( tiles[ 6], uv * 4.0 - vec2(2, 3) + vec2(1, 1)).xyz;',
        'else if (uv.x < 2.0*size && uv.y < 4.0*size)',
          'diffuse = texture2D( tiles[ 7], uv * 4.0 - vec2(2, 4) + vec2(1, 1)).xyz;',
        'else if (uv.x < 3.0*size && uv.y < 1.0*size)',
          'diffuse = texture2D( tiles[ 8], uv * 4.0 - vec2(3, 1) + vec2(1, 1)).xyz;',
        'else if (uv.x < 3.0*size && uv.y < 2.0*size)',
          'diffuse = texture2D( tiles[ 9], uv * 4.0 - vec2(3, 2) + vec2(1, 1)).xyz;',
        'else if (uv.x < 3.0*size && uv.y < 3.0*size)',
          'diffuse = texture2D( tiles[10], uv * 4.0 - vec2(3, 3) + vec2(1, 1)).xyz;',
        'else if (uv.x < 3.0*size && uv.y < 4.0*size)',
          'diffuse = texture2D( tiles[11], uv * 4.0 - vec2(3, 4) + vec2(1, 1)).xyz;',
        'else if (uv.x < 4.0*size && uv.y < 1.0*size)',
          'diffuse = texture2D( tiles[12], uv * 4.0 - vec2(4, 1) + vec2(1, 1)).xyz;',
        'else if (uv.x < 4.0*size && uv.y < 2.0*size)',
          'diffuse = texture2D( tiles[13], uv * 4.0 - vec2(4, 2) + vec2(1, 1)).xyz;',
        'else if (uv.x < 4.0*size && uv.y < 3.0*size)',
          'diffuse = texture2D( tiles[14], uv * 4.0 - vec2(4, 3) + vec2(1, 1)).xyz;',
        'else',
          'diffuse = texture2D( tiles[15], uv * 4.0 - vec2(4, 4) + vec2(1, 1)).xyz;',

        'float phong      = max(0.0, pow(dot( vNormal, normalize(vec3( -0.3, 0.4, 0.7))), 0.6))*0.4 + 0.65;',
        'float specular   = max(0.0, pow(dot( vNormal, normalize(vec3( -0.3, 0.4, 0.7)) ), 60.0));',
        'float atmosphere = pow(1.0 - dot( vNormal, vec3( 0.0, 0.0, 1.0 ) ), 2.0) * 0.7;',
        'gl_FragColor     = vec4( phong * diffuse + atmosphere + specular * 0.1, 1.0 );',
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

		zoom();
    this.center({x:10, y:50});
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

  // ===========================================================================
  this.center = function(latLong) {
    myTargetCameraPos.x = latLong.x;
    myTargetCameraPos.y = latLong.y;
  }

  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// MEMBER VARIABLES /////////////////////////////////

  var mySelf = this;

  // THREE js
  var myCamera, myRenderer;
  var mySceneGlobe, mySceneAtmosphere;

  // window geometry
  var myWidth, myHeight;
  var myCanvasOffsetX, myCanvasOffsetY;

  var myLastIntersected = [];

  var myCurrentCameraPos = { x: 0, y: 0 };
  var myTargetCameraPos = { x: 0, y: 0 };

  var myMousePos = { x: 0, y: 0 };
  var myMousePosLastFrame = { x: 0, y: 0 };
  var myMouseSpeed = { x: 0, y: 0 };
  var myDragStartPos;
  var mySpringiness = 0.9;

  var myCurrentFOV = 0, myTargetFOV = 0;

  var myGlobeTextures = [];
  var myGlobeUniforms;

  var myIsRunning = false;
  var myCurrentZoom = HG.Display3D.CAMERA_MIN_ZOOM;
  var myCurrentTextureZoom = HG.Display3D.CAMERA_MIN_ZOOM;

  ////////////////////////// INIT FUNCTIONS ////////////////////////////////////

  // ===========================================================================
  function initWindowGeometry() {
    myWidth = $(inContainer.parentNode).innerWidth();
    myHeight = $(inContainer.parentNode).innerHeight();

    myCanvasOffsetX = $(inContainer.parentNode).offset().left;
    myCanvasOffsetY = $(inContainer.parentNode).offset().top;
  }

  // ===========================================================================
  function initGlobe() {
    myCamera = new THREE.PerspectiveCamera(myCurrentFOV, myWidth / myHeight, 1, 10000);
    myCamera.position.z = HG.Display3D.CAMERA_DISTANCE;
    mySceneGlobe = new THREE.Scene();
    mySceneAtmosphere = new THREE.Scene();

    var geometry = new THREE.SphereGeometry(HG.Display3D.EARTH_RADIUS, 64, 32);

    var shader = HG.Display3D.SHADERS['earth'];
    myGlobeUniforms = THREE.UniformsUtils.clone(shader.uniforms);
    
    
    for (var z = HG.Display3D.CAMERA_MIN_ZOOM; z<=HG.Display3D.CAMERA_MAX_ZOOM; ++z) {
			var zoomLevel = [];
			for (var x=0; x<Math.pow(2, z); ++x) {
				column = [];
				for (var y=0; y<Math.pow(2, z); ++y) {
					column.push(null);
				}			
				zoomLevel.push(column);		
			}
			myGlobeTextures.push(zoomLevel);			
		}
    
    var material = new THREE.ShaderMaterial({
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader,
      uniforms: myGlobeUniforms
    });

    var globe = new THREE.Mesh(geometry, material);
    globe.matrixAutoUpdate = false;
    mySceneGlobe.add(globe);

    shader = HG.Display3D.SHADERS['atmosphere'];
    var uniforms = THREE.UniformsUtils.clone(shader.uniforms);
    uniforms['bgColor'].value = new THREE.Vector3(HG.Display3D.BACKGROUND.r, 
                                                  HG.Display3D.BACKGROUND.g, 
                                                  HG.Display3D.BACKGROUND.b);

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
    myRenderer.setClearColor(HG.Display3D.BACKGROUND, 1.0);
    myRenderer.setSize(myWidth, myHeight);

    myRenderer.domElement.style.position = 'absolute';

    inContainer.appendChild(myRenderer.domElement);
  }

  // ===========================================================================
  function initEventHandling() {
    inContainer.addEventListener('mousedown', onMouseDown, false);
    inContainer.addEventListener('mousemove', onMouseMove, false);
    inContainer.addEventListener('mouseup', onMouseUp, false);

    inContainer.addEventListener('mousewheel', function(event) {
      event.preventDefault();
      onMouseWheel(event.wheelDelta);
      return false;
    }, false);

    inContainer.addEventListener('DOMMouseScroll', function(event) {
      event.preventDefault();
      onMouseWheel(-event.detail*30);
      return false;
    }, false);

    document.addEventListener('keydown', onDocumentKeyDown, false);

    window.addEventListener('resize', onWindowResize, false);
  }

  // ===========================================================================
  function initHivents() {

    inHiventHandler.onHiventsChanged( function(handles) {

      for (var i=0; i<handles.length; i++) {

        var hivent = new HG.HiventMarker3D(handles[i], mySelf, inContainer);

        mySceneGlobe.add(hivent);

        var position = latLongToCart(new THREE.Vector2(handles[i].getHivent().long, handles[i].getHivent().lat));

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
      render();
      requestAnimationFrame(animate);
    }
  }

  // ===========================================================================
  function render() {

    var mouseRel  = {x: (myMousePos.x - myCanvasOffsetX) / myWidth * 2 - 1,
                     y: (myMousePos.y - myCanvasOffsetY) / myHeight * 2 - 1};

    // picking -----------------------------------------------------------------

    // test for mark and highlight hivents
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
      myLastIntersected[i].getHiventHandle().unMark(myLastIntersected[i], myMousePos);
      myLastIntersected[i].getHiventHandle().unLinkAll(myMousePos);
    }

    myLastIntersected = [];

    for (var i = 0; i < intersects.length; i++) {
      if (intersects[i].object instanceof HG.HiventMarker3D) {
        myLastIntersected.push(intersects[i].object);
        var pos = {
						x : myMousePos.x - myCanvasOffsetX,
						y : myMousePos.y - myCanvasOffsetY,
				};
        intersects[i].object.getHiventHandle().mark(intersects[i].object, pos);
        intersects[i].object.getHiventHandle().linkAll(pos);
      }
    }

    // globe rotation ----------------------------------------------------------              
    
    // if there is a drag going on - rotate globe
    if (myDragStartPos) {
      // update mouse speed
      myMouseSpeed = {x: 0.5*myMouseSpeed.x + 0.5*(myMousePos.x - myMousePosLastFrame.x),
                      y: 0.5*myMouseSpeed.y + 0.5*(myMousePos.y - myMousePosLastFrame.y)};
      myMousePosLastFrame.x = myMousePos.x;
      myMousePosLastFrame.y = myMousePos.y;
      
      var latLongCurr = pixelToLatLong(mouseRel);

      // if mouse is still over the globe
      if (latLongCurr) {

        var xOffset = myDragStartPos.x - latLongCurr.x;
        var yOffset = myDragStartPos.y - latLongCurr.y;
  
        if (yOffset > 180) {
          yOffset -= 360;
        } else if (yOffset < -180) {
          yOffset += 360;
        }

        myTargetCameraPos.y += 0.5 * (xOffset);
        myTargetCameraPos.x -= 0.5 * (yOffset);

        clampCameraPos();

      } else {
        myDragStartPos = null;
        container.style.cursor = 'auto';
      }
    } else if (myMouseSpeed.x != 0.0 && myMouseSpeed.y != 0.0) {
      // if the globe has been "thrown" --- for "flicking"
      
      myTargetCameraPos.x -= myMouseSpeed.x * myCurrentFOV * 0.02;
      myTargetCameraPos.y += myMouseSpeed.y * myCurrentFOV * 0.02;
      
      clampCameraPos();
      
      myMouseSpeed = {x: 0.0, y: 0.0};
    }

    myCurrentCameraPos.x = myCurrentCameraPos.x * (mySpringiness) + myTargetCameraPos.x * (1.0 - mySpringiness);
    myCurrentCameraPos.y = myCurrentCameraPos.y * (mySpringiness) + myTargetCameraPos.y * (1.0 - mySpringiness);

    var rotation = {x: myCurrentCameraPos.x * Math.PI / 180,
                    y: myCurrentCameraPos.y * Math.PI / 180};

    myCamera.position.x = HG.Display3D.CAMERA_DISTANCE * Math.sin(rotation.x + Math.PI*0.5) * Math.cos(rotation.y);
    myCamera.position.y = HG.Display3D.CAMERA_DISTANCE * Math.sin(rotation.y);
    myCamera.position.z = HG.Display3D.CAMERA_DISTANCE * Math.cos(rotation.x + Math.PI*0.5) * Math.cos(rotation.y);
    myCamera.lookAt(new THREE.Vector3(0,0,0));

    // zooming -----------------------------------------------------------------
    if (myCurrentFOV != myTargetFOV) {
      var smoothness = 0.7;
      myCurrentFOV = myCurrentFOV * smoothness + myTargetFOV * (1.0 - smoothness);
      myCamera.fov = myCurrentFOV;
      myCamera.updateProjectionMatrix();
      
      if (Math.abs(myCurrentFOV - myTargetFOV) < 0.1) {
        myCurrentFOV = myTargetFOV;
        myCurrentTextureZoom = myCurrentZoom;
      }
    }

    // rendering ---------------------------------------------------------------
    myRenderer.clear();
    myRenderer.setFaceCulling(THREE.CullFaceBack);
    
    var size = 1.0/Math.pow(2, myCurrentTextureZoom);
    
    var count = 0;
    
    for (var x=0; x<Math.pow(2, myCurrentTextureZoom); x+=4) {
      for (var y=0; y<Math.pow(2, myCurrentTextureZoom); y+=4) {
      
        var textures = [];
        
        for (var dx=0; dx<4; ++dx) {
          for (var dy=0; dy<4; ++dy) {
            textures.push(getTextureTile(x+dx, y+(3-dy), myCurrentTextureZoom));
          }
        }
        
        var minUV = new THREE.Vector2(x*size, 1.0 - (y+4)*size);
        var maxUV = new THREE.Vector2((x+4)*size, 1.0 - y*size);
        
        if (isTileVisible(minUV, maxUV)) {
          myGlobeUniforms['tiles'].value = textures;
          myGlobeUniforms['minUV'].value = minUV;
          myGlobeUniforms['maxUV'].value = maxUV;
          
          myRenderer.render(mySceneGlobe, myCamera);
          ++count;
        }
      }
    }
    
    myRenderer.setFaceCulling(THREE.CullFaceFront);
    myRenderer.render(mySceneAtmosphere, myCamera);
  }

  // ===========================================================================
  function zoom() {
    myTargetFOV = (HG.Display3D.CAMERA_MAX_ZOOM + 1.0 - myCurrentZoom) * 15; 
  }


  ////////////////////////// EVENT HANDLING ////////////////////////////////////

  // ===========================================================================
  function onMouseDown(event) {
    if (myIsRunning) {
      event.preventDefault();

      var clickMouse = {x: (event.clientX - myCanvasOffsetX) / myWidth * 2 - 1,
                        y: (event.clientY - myCanvasOffsetY) / myHeight * 2 - 1};

      myDragStartPos = pixelToLatLong(clickMouse);

      if (myDragStartPos) {
        inContainer.style.cursor = 'move';
        mySpringiness = 0.1;
        myTargetCameraPos.x = myCurrentCameraPos.x;
        myTargetCameraPos.y = myCurrentCameraPos.y;
        
        myMousePosLastFrame.x = myMousePos.x;
        myMousePosLastFrame.y = myMousePos.y;
      }
   }
  }

  // ===========================================================================
  function onMouseMove(event) {
    if (myIsRunning) {
      myMousePos = {x: event.clientX, y: event.clientY};
    }
  }

  // ===========================================================================
  function onMouseUp(event) {
    if (myIsRunning) {
      event.preventDefault();
      inContainer.style.cursor = 'auto';
      mySpringiness = 0.9;
      
      myDragStartPos = null;
      myDragStartCamera = null;

      if (myLastIntersected.length == 0) {
        HG.deactivateAllHivents();
      } else {
        for (var i = 0; i < myLastIntersected.length; i++) {
					var pos = {
						x : myMousePos.x - myCanvasOffsetX,
						y : myMousePos.y - myCanvasOffsetY,
					};
          myLastIntersected[i].getHiventHandle().activeAll(pos);
        }
      }
    }
  }

  // ===========================================================================
  function onMouseWheel(delta) {
    if (myIsRunning) {
			if (delta > 0)
				myCurrentZoom = Math.min(myCurrentZoom + 1, HG.Display3D.CAMERA_MAX_ZOOM);
			else
				myCurrentZoom = Math.max(myCurrentZoom - 1, HG.Display3D.CAMERA_MIN_ZOOM);
			
			zoom();
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
    myCamera.aspect = $(inContainer.parentNode).innerWidth()
                    / $(inContainer.parentNode).innerHeight();
    myCamera.updateProjectionMatrix();
    myRenderer.setSize($(inContainer.parentNode).innerWidth(),
                     $(inContainer.parentNode).innerHeight());

    initWindowGeometry();
  }

  ///////////////////////// HELPER FUNCTIONS ///////////////////////////////////
  
  // ===========================================================================
  function clampCameraPos() {
    if (myTargetCameraPos.y > HG.Display3D.CAMERA_MAX_LONG) {
      myTargetCameraPos.y = HG.Display3D.CAMERA_MAX_LONG;
    }

    if (myTargetCameraPos.y < -HG.Display3D.CAMERA_MAX_LONG) {
      myTargetCameraPos.y = -HG.Display3D.CAMERA_MAX_LONG;
    }
  }
  
  // ===========================================================================
  function pixelToLatLong(inPixel) {
    var vector = new THREE.Vector3(inPixel.x, -inPixel.y, 0.5);
	  HG.Display3D.PROJECTOR.unprojectVector(vector, myCamera);
    HG.Display3D.RAYCASTER.set(myCamera.position, vector.sub(myCamera.position).normalize());

	  var intersects = HG.Display3D.RAYCASTER.intersectObjects(mySceneGlobe.children);

	  if (intersects.length > 0) {
	      return cartToLatLong(intersects[0].point.clone().normalize());
	  }

	  return null;
  }

  // ===========================================================================
  function latLongToCart(latLong) {
    var x = HG.Display3D.EARTH_RADIUS * Math.cos( latLong.y * Math.PI/180)
                                      * Math.cos(-latLong.x * Math.PI/180);
    var y = HG.Display3D.EARTH_RADIUS * Math.sin( latLong.y * Math.PI/180);
    var z = HG.Display3D.EARTH_RADIUS * Math.cos( latLong.y * Math.PI/180)
                                      * Math.sin(-latLong.x * Math.PI/180);

    return new THREE.Vector3(x,y,z);
  }
  
  // ===========================================================================
  function latLongToPixel(latLong) {
    var pos = latLongToCart(latLong);
    HG.Display3D.PROJECTOR.projectVector(pos, myCamera);
    
    return pos;
  }

  // ===========================================================================
  function cartToLatLong(coordinates) {
    var lat = Math.asin(coordinates.y) / Math.PI * 180;
    var long = -Math.atan(coordinates.x / coordinates.z) / Math.PI * 180 - 90;

    if (coordinates.z > 0) {
      long += 180;
    }

    return new THREE.Vector2(lat, long);
  }

	// ===========================================================================
	function getTextureTile(x, y, zoom) {
		if (myGlobeTextures[zoom - HG.Display3D.CAMERA_MIN_ZOOM][x][y] == null) {
			myGlobeTextures[zoom - HG.Display3D.CAMERA_MIN_ZOOM][x][y] = THREE.ImageUtils.loadTexture(HG.Display3D.TILE_PATH + zoom + "/" + x + "/" + y + ".png");
		}
		return myGlobeTextures[zoom - HG.Display3D.CAMERA_MIN_ZOOM][x][y];
	}
	
	// ===========================================================================
	function isTileVisible(minNormalizedLatLong, maxNormalizedLatLong) {
	  
	  if (isFrontFacingTile(minNormalizedLatLong, maxNormalizedLatLong)) {
	    var min = normalizedMercatusToNormalizedLatLong(minNormalizedLatLong);
      var max = normalizedMercatusToNormalizedLatLong(maxNormalizedLatLong);
	
	    var a = latLongToPixel(unNormalizeLatLong({x: min.x, y: min.y}));
	    var b = latLongToPixel(unNormalizeLatLong({x: max.x, y: min.y}));
	    var c = latLongToPixel(unNormalizeLatLong({x: max.x, y: max.y}));
	    var d = latLongToPixel(unNormalizeLatLong({x: min.x, y: max.y}));

      var minX = Math.min(Math.min(Math.min(a.x, b.x), c.x), d.x);
      var maxX = Math.max(Math.max(Math.max(a.x, b.x), c.x), d.x);
      
      var minY = Math.min(Math.min(Math.min(a.y, b.y), c.y), d.y);
      var maxY = Math.max(Math.max(Math.max(a.y, b.y), c.y), d.y);
   
      return !(minX > 1.0 || minY > 1.0 || maxX < -1.0 || maxY < -1.0);
    }
    
    return false;
	}
	
	// ===========================================================================
	function isFrontFacingTile(minNormalizedLatLong, maxNormalizedLatLong) {
	  
	  var a = {x: minNormalizedLatLong.x, y: minNormalizedLatLong.y};
    var b = {x: maxNormalizedLatLong.x, y: minNormalizedLatLong.y};
    var c = {x: maxNormalizedLatLong.x, y: maxNormalizedLatLong.y};
    var d = {x: minNormalizedLatLong.x, y: maxNormalizedLatLong.y};
    
    function isOnFrontSide(pos) {
      var diff = Math.acos(Math.sin((pos.y - 0.5) * Math.PI)
                          *Math.sin((myCurrentCameraPos.y) * Math.PI / 180.0) 
                          +Math.cos((pos.y - 0.5) * Math.PI)
                          *Math.cos((myCurrentCameraPos.y) * Math.PI / 180.0)
                          *Math.cos(-(pos.x - 0.5) * 2.0 * Math.PI + (myCurrentCameraPos.x) * Math.PI / 180.0));
      
      return Math.PI*0.5 > diff;
    }
    
    return isOnFrontSide(a) || isOnFrontSide(b) || isOnFrontSide(c) || isOnFrontSide(d);
	}
	
	// ===========================================================================
	function normalizedLatLongToNormalizedMercatus(latLong) {
	  if (latLong.y == 0.0) return new THREE.Vector2(latLong.x, 0.0);
    if (latLong.y == 1.0) return new THREE.Vector2(latLong.x, 1.0);
    
    return new THREE.Vector2(latLong.x, Math.log(Math.tan(latLong.y*0.5 * Math.PI)) / (Math.PI * 2.0) + 0.5);
	}
	
	// ===========================================================================
	function normalizedMercatusToNormalizedLatLong(mercatus) {
	  if (mercatus.y == 0.0) return new THREE.Vector2(mercatus.x, 0.0);
    if (mercatus.y == 1.0) return new THREE.Vector2(mercatus.x, 1.0);
    
    return new THREE.Vector2(mercatus.x, 2.0 / Math.PI * Math.atan(Math.exp(2 * Math.PI * (mercatus.y-0.5))));
	}
	
	// ===========================================================================
	function normalizeLatLong(latLong) {
	  return new THREE.Vector2(latLong.x/360.0 + 0.5, latLong.y/180.0 + 0.5);
	}
	
	// ===========================================================================
	function unNormalizeLatLong(normalizedLatLong) {
	  return new THREE.Vector2(normalizedLatLong.x * 360.0 - 180.0, normalizedLatLong.y * 180.0 - 90.0);
	}
  
  // call base class constructor
  HG.Display.call(this);

  // create the object
  this.create();

  // all done
  return this;

};

HG.Display3D.prototype = Object.create(HG.Display.prototype);

