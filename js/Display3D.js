//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display3D = function(container, inMap, inHiventHandler) {

  var Shaders = {
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

  var camera, scene, sceneAtmosphere, renderer;
  var width, height;
  var offsetX, offsetY;
  var globe, atmosphere;

  var earthRadius = 200;
  var cameraDistance = 500;
  var maxCamLong = 80;

  var map = inMap;
  var hiventHandler = inHiventHandler;

  var overRenderer;

  var projector;
  var raycaster;
  
  var lastIntersected = [];

  var curZoomSpeed = 0;
  var zoomSpeed = 0.1;

  var mouse = { x: 0, y: 0 },
      mouseRel = { x: 0, y: 0 }, 
      clickMouse = null,
      rotation = { x: 0, y: 0 },
      camLongLat = { x: 0, y: 0 },
      clickLongLat = null;

  var fov = 90, fovTarget = 50;
  var padding = 40;
  var PI_HALF = Math.PI / 2;

  var mapTexture;
  
  var running = false;
   
  function init() {

    var shader, material, uniforms;
    width = $(container.parentNode).innerWidth();
    height = $(container.parentNode).innerHeight();

    offsetX = $(container.parentNode).offset().left;
    offsetY = $(container.parentNode).offset().top;	

    projector = new THREE.Projector();
    raycaster = new THREE.Raycaster();

    camera = new THREE.PerspectiveCamera(fov, width / height, 1, 10000);
    camera.position.z = cameraDistance;
    scene = new THREE.Scene();
    sceneAtmosphere = new THREE.Scene();

    var geometry = new THREE.SphereGeometry(earthRadius, 60, 30);

    shader = Shaders['earth'];
    uniforms = THREE.UniformsUtils.clone(shader.uniforms);

    mapTexture = new THREE.Texture(map.getCanvas());
    mapTexture.needsUpdate = true;
    uniforms['texture'].value = mapTexture;

    material = new THREE.ShaderMaterial({
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader,
      uniforms: uniforms
    });
    
    globe = new THREE.Mesh(geometry, material);
    globe.matrixAutoUpdate = false;
    scene.add(globe);

    
    shader = Shaders['atmosphere'];
    uniforms = THREE.UniformsUtils.clone(shader.uniforms);
    uniforms['bgColor'].value = new THREE.Vector3(0.92549, 0.92549, 0.92549);

    material = new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader
    });

    atmosphere = new THREE.Mesh(geometry, material);
    atmosphere.scale.x = atmosphere.scale.y = atmosphere.scale.z = 1.5;
    atmosphere.flipSided = true;
    atmosphere.matrixAutoUpdate = false;
    atmosphere.updateMatrix();
    sceneAtmosphere.add(atmosphere);

    initHivents();
    

    renderer = new THREE.WebGLRenderer({antialias: true});
    renderer.autoClear = false;
    renderer.setClearColor(0x000000, 0.0);
    renderer.setSize(width, height);

    renderer.domElement.style.position = 'absolute';

    container.appendChild(renderer.domElement);

    container.addEventListener('mousedown', onMouseDown, false);
    container.addEventListener('mousemove', onMouseMove, false);
    container.addEventListener('mouseup', onMouseUp, false);

    container.addEventListener('mousewheel', 
                  function(event) {
                    event.preventDefault();
                    onMouseWheel(event.wheelDelta);
                    return false;
                  }, false);
                  
    container.addEventListener('DOMMouseScroll', 
                  function(event) {
                    event.preventDefault();
                    onMouseWheel(-event.detail*30);
                    return false;
                  }, false);

    document.addEventListener('keydown', onDocumentKeyDown, false);

    window.addEventListener('resize', onWindowResize, false);

    container.addEventListener('mouseover', function() {
      overRenderer = true;
    }, false);

    container.addEventListener('mouseout', function() {
      overRenderer = false;
    }, false);
  }
  

  function onMouseDown(event) {
    if (running) {  
      event.preventDefault();

      clickMouse = {x: (event.clientX - offsetX) / width * 2 - 1,
                    y: (event.clientY - offsetY) / height * 2 - 1};
      
      clickLongLat = mouseToLongLat(clickMouse);
      
      if (clickLongLat) {
        
//        container.addEventListener('mouseout', onMouseOut, false);
        container.style.cursor = 'move';
      }
   }
  }

  function onMouseMove(event) {
    if (running) { 
      mouse     = {x: event.clientX,
                   y: event.clientY};
      mouseRel  = {x: (mouse.x - offsetX) / width * 2 - 1,
                   y: (mouse.y - offsetY) / height * 2 - 1};
    }
  }

  function onMouseUp(event) {
    if (running) { 
      event.preventDefault();
//      container.removeEventListener('mouseout', onMouseOut, false);
      container.style.cursor = 'auto';
      clickLongLat = null;
      
      if (lastIntersected.length == 0) {
        HG.deactivateAllHivents();
      } else {
        for (var i = 0; i < lastIntersected.length; i++)
          lastIntersected[i].active(mouse);
      }
    }
  }

//  function onMouseOut(event) {
//    if (running) { 
//      container.removeEventListener('mouseout', onMouseOut, false);
//    }
//  }

  function onMouseWheel(delta) {
    if (running) { 
      if (overRenderer) {
        zoom(delta * 0.3);
      }
    }
    return false;
  }

  function onDocumentKeyDown(event) {
    if (running) { 
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

  function onWindowResize( event ) {
    camera.aspect = $(container.parentNode).innerWidth() / $(container.parentNode).innerHeight();
    camera.updateProjectionMatrix();
    renderer.setSize($(container.parentNode).innerWidth(), $(container.parentNode).innerHeight());
    
    width = $(container.parentNode).innerWidth();
    height = $(container.parentNode).innerHeight();

    offsetX = $(container.parentNode).offset().left;
    offsetY = $(container.parentNode).offset().top;
  }

  function zoom(delta) {
    fovTarget -= delta*zoomSpeed;
    fovTarget = fovTarget > 50 ? 50 : fovTarget;
    fovTarget = fovTarget < 10 ? 10 : fovTarget;
  }
  

  function initHivents() {
      
    var hivents;
    
    hiventHandler.onHiventsLoaded(function(h){

      hivents = h;
      
      for (var i=0; i<hivents.length; i++) {
              
        var hivent = new HG.HiventMarker3D(hivents[i]);
        scene.add(hivent);
        
        var position = longLatToCart(new THREE.Vector2(hivents[i].long, hivents[i].lat), earthRadius);
        
        hivent.translateOnAxis(new THREE.Vector3(1,0,0), position.x);
        hivent.translateOnAxis(new THREE.Vector3(0,1,0), position.y);
        hivent.translateOnAxis(new THREE.Vector3(0,0,1), position.z);
      }
    });
  }
  
  function mouseToLongLat(mousePos) {
    var vector = new THREE.Vector3(mousePos.x, -mousePos.y, 0.5);
	  projector.unprojectVector(vector, camera);
    raycaster.set(camera.position, vector.sub(camera.position).normalize());
    
	  var intersects = raycaster.intersectObjects(scene.children);
	
	  if (intersects.length > 0) {
	      return cartToLongLat(intersects[0].point.clone().normalize());
	  }
	  
	  return null;
  }

  function animate() {
    if (running) {
//      map.redraw();
      //mapTexture.needsUpdate = true;
      render();
      requestAnimationFrame(animate);
    }
  }

  function render() {
    zoom(curZoomSpeed);
    
    // test for hover
    var vector = new THREE.Vector3(mouseRel.x, -mouseRel.y, 0.5);
    projector.unprojectVector(vector, camera);
    raycaster.set(camera.position, vector.sub(camera.position).normalize());
    var intersects = raycaster.intersectObjects(scene.children);

    for (var i = 0; i < intersects.length; i++) {
      if (intersects[i].object instanceof HG.HiventMarker3D) {
        var index = $.inArray(intersects[i].object, lastIntersected);
        if (index >= 0) {
          lastIntersected.splice(index, 1);
        }
      }
    }

    for (var i = 0; i < lastIntersected.length; i++) {
      lastIntersected[i].unHover(mouse);
    }
    
    lastIntersected = [];

    for (var i = 0; i < intersects.length; i++) {
      if (intersects[i].object instanceof HG.HiventMarker3D) {
        lastIntersected.push(intersects[i].object);
        intersects[i].object.hover(mouse);
      }
    }
    
    // if there is a drag going on
    if (clickLongLat) {
      var longLatCurr = mouseToLongLat(mouseRel);
      
      if (longLatCurr) {
      
        if (clickLongLat.x - longLatCurr.x > 180)
          clickLongLat.x -= 360;
        else if (clickLongLat.x - longLatCurr.x < -180)
          clickLongLat.x += 360;
      
        camLongLat.x += 10.0*(clickLongLat.x - longLatCurr.x);
        camLongLat.y += 10.0*(clickLongLat.y - longLatCurr.y);
        
        if (camLongLat.y > maxCamLong) camLongLat.y = maxCamLong;
        if (camLongLat.y < -maxCamLong) camLongLat.y = -maxCamLong;
        
        clickLongLat = longLatCurr;
        
      } else {
        clickLongLat = null;
        container.style.cursor = 'auto';
      }
    }
    
    var newRotation = {x: camLongLat.x * Math.PI / 180,
                       y: camLongLat.y * Math.PI / 180};

    rotation.x += (newRotation.x - rotation.x) * 0.1;
    rotation.y += (newRotation.y - rotation.y) * 0.1;
   
    camera.position.x = cameraDistance * Math.sin(-rotation.x + Math.PI*0.5) * Math.cos(rotation.y);
    camera.position.y = cameraDistance * Math.sin(rotation.y);
    camera.position.z = cameraDistance * Math.cos(-rotation.x + Math.PI*0.5) * Math.cos(rotation.y);
    camera.lookAt(new THREE.Vector3(0,0,0));
    
    fov += (fovTarget - fov) * 0.1;
    camera.fov = fov;
    camera.updateProjectionMatrix();
    	
    renderer.clear();
    renderer.setFaceCulling(THREE.CullFaceBack);
    renderer.render(scene, camera);
    renderer.setFaceCulling(THREE.CullFaceFront);
    renderer.render(sceneAtmosphere, camera);
  }
  

  function longLatToCart(longlat, radius) {
    var x = radius * Math.cos(longlat.y * Math.PI/180) 
                   * Math.cos(longlat.x * Math.PI/180); 
    var y = radius * Math.sin(longlat.y * Math.PI/180); 
    var z = radius * Math.cos(longlat.y * Math.PI/180) 
                   * Math.sin(longlat.x * Math.PI/180);
    
    return new THREE.Vector3(x,y,z);  
  }

  function cartToLongLat(coordinates) {
    var lat = Math.asin(coordinates.y) / Math.PI * 180;
    var long = -Math.atan(coordinates.x / coordinates.z) / Math.PI * 180 - 90;
    
    if (coordinates.z > 0) {
      long += 180;
    } 
  
    return new THREE.Vector2(long, lat);
  }
  
  this.start = function() { 
    if (!running) {  
      running = true;
      renderer.domElement.style.display = "inline";
      animate();
    }
  }  
 
  this.stop = function() {  
    running = false;
    HG.deactivateAllHivents();
    renderer.domElement.style.display = "none";
  }   
  
  this.isRunning = function() {
    return running;
  } 
  
  this.getCanvas = function() {
    return renderer.domElement;
  }

  init();

  return this;

};

