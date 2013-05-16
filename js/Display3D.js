/**
 * dat.globe Javascript WebGL Globe Toolkit
 * http://dataarts.github.com/dat.globe
 *
 * Copyright 2011 Data Arts Team, Google Creative Lab
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 */

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
      uniforms: {},
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
        'gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0 );',
      '}'
      ].join('\n')
    }
  };

  var camera, scene, sceneAtmosphere, renderer;
  var width, height;
  var offsetX, offsetY;
  var globe, atmosphere;

  var earthRadius = 200;

  var map = inMap;
  var hiventHandler = inHiventHandler;

  var overRenderer;

  var projector;
  var raycaster;

  var curZoomSpeed = 0;
  var zoomSpeed = 0.1;

  var mouse = { x: 0, y: 0 }, mouseOnDown = { x: 0, y: 0 };
  var rotation = { x: 0, y: 0 },
      target = { x: Math.PI*3/2, y: Math.PI / 6.0 },
      targetOnDown = { x: 0, y: 0 };

  var fov = 90, fovTarget = 50;
  var padding = 40;
  var PI_HALF = Math.PI / 2;

  var mapTexture;
  
  var running = false;
  
  init();
   
  function init() {

    var shader, material, uniforms;
    width = $(container.parentNode).innerWidth();
    height = $(container.parentNode).innerHeight();

    offsetX = $(container.parentNode).offset().left;
    offsetY = $(container.parentNode).offset().top;	

    projector = new THREE.Projector();
    raycaster = new THREE.Raycaster();

    camera = new THREE.PerspectiveCamera(fov, width / height, 1, 10000);
    camera.position.z = 500;
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

      container.addEventListener('mousemove', onMouseMove, false);
      container.addEventListener('mouseup', onMouseUp, false);
      container.addEventListener('mouseout', onMouseOut, false);

      mouseOnDown.x = (event.clientX - offsetX) / width * 2 - 1;
      mouseOnDown.y = (event.clientY - offsetY) / height * 2 - 1;
      
      targetOnDown.x = target.x;
      targetOnDown.y = target.y;

      container.style.cursor = 'move';
      
      var vector = new THREE.Vector3(mouseOnDown.x, -mouseOnDown.y, 0.5);
		  projector.unprojectVector( vector, camera );
      raycaster.set(camera.position, vector.sub(camera.position).normalize());
      
		  var intersects = raycaster.intersectObjects(scene.children);
		
		  if (intersects.length > 0) {
		      var longLat = cartToLongLat(intersects[0].point.clone().normalize());
		      
		      console.log("breite: " + longLat.y);
		      console.log("länge: " + longLat.x);
		  }
   }
  }

  function onMouseMove(event) {
    if (running) { 
      mouse.x = (event.clientX - offsetX) / width * 2 - 1;
      mouse.y = (event.clientY - offsetY) / height * 2-1;

      var zoomDamp = fov/3;

      target.x = targetOnDown.x - (mouse.x - mouseOnDown.x) * 0.1 * zoomDamp;
      target.y = targetOnDown.y + (mouse.y - mouseOnDown.y) * 0.1 * zoomDamp;

      target.y = target.y > PI_HALF ? PI_HALF : target.y;
      target.y = target.y < - PI_HALF ? - PI_HALF : target.y;
    }
  }

  function onMouseUp(event) {
    if (running) { 
      container.removeEventListener('mousemove', onMouseMove, false);
      container.removeEventListener('mouseup', onMouseUp, false);
      container.removeEventListener('mouseout', onMouseOut, false);
      container.style.cursor = 'auto';
    }
  }

  function onMouseOut(event) {
    if (running) { 
      container.removeEventListener('mousemove', onMouseMove, false);
      container.removeEventListener('mouseup', onMouseUp, false);
      container.removeEventListener('mouseout', onMouseOut, false);
    }
  }

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
  
    var geometry = new THREE.SphereGeometry(1, 10, 10);

    var shader = Shaders['hivent'];
    var uniforms = THREE.UniformsUtils.clone(shader.uniforms);

    var material = new THREE.ShaderMaterial({
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader,
      uniforms: uniforms
    });
    
    
    var hivents;
    
    hiventHandler.onHiventsLoaded(function(h){

      hivents = h;

      for (var i=0; i<hivents.length; i++) {
        hivent = new HG.HiventMarker3D(hivents[i], geometry, material);
        scene.add(hivent);
        
        var position = longLatToCart(new THREE.Vector2(hivents[i].long, hivents[i].lat),
                                     earthRadius);
        
        hivent.translateOnAxis(new THREE.Vector3(1,0,0), position.x);
        hivent.translateOnAxis(new THREE.Vector3(0,1,0), position.y);
        hivent.translateOnAxis(new THREE.Vector3(0,0,1), position.z);
      }
    });
  }

  function moveCamera(coordinates) {
    
  }

  function animate() {
    if (running) {
      requestAnimationFrame(animate);
      map.redraw();
      //mapTexture.needsUpdate = true;
      render();
    }
  }

  function render() {
    zoom(curZoomSpeed);

    rotation.x += (target.x - rotation.x) * 0.1;
    rotation.y += (target.y - rotation.y) * 0.1;
   
    camera.position.x = 500 * Math.sin(rotation.x) * Math.cos(rotation.y);
    camera.position.y = 500 * Math.sin(rotation.y);
    camera.position.z = 500 * Math.cos(rotation.x) * Math.cos(rotation.y);
    camera.lookAt(new THREE.Vector3(0,0,0));
    
    fov += (fovTarget - fov) * 0.1;
    camera.fov = fov;
    camera.updateProjectionMatrix();

    var vector = new THREE.Vector3(mouse.x, mouse.y, 1);
    //var vector = new THREE.Vector3(0,0, 1);
   // console.log(vector);	
		projector.unprojectVector( vector, camera );
		//console.log(vector);	
    raycaster.set(camera.position, vector.sub(camera.position).normalize());
		var intersects = raycaster.intersectObjects(scene.children);
		
		if (intersects.length > 0) {
		  if (intersects[0].object instanceof HG.HiventMarker3D) {
		    //console.log(intersects[0].point);
		    //console.log("huhu");			
		  }
		  
		}

    camera.matrixWorldNeedsUpdate = true;
		
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
    renderer.domElement.style.display = "none";
  }   
  
  this.isRunning = function() {
    return running;
  } 
  
  this.getCanvas = function() {
    return renderer.domElement;
  }

  return this;

};

