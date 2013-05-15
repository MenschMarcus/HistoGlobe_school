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

var HG = HG || {};

HG.Display3D = function(container, inMap) {

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
        '//gl_FragColor = vec4( diffuse + atmosphere + specular * 0.1, 1.0 );',
        'gl_FragColor = vec4(diffuse, 1.0);',
      '}'
      ].join('\n')
    },
    'atmosphere' : {
      uniforms: {},
      vertexShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'vNormal = normalize( normalMatrix * normal );',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
      '}'
      ].join('\n'),
      fragmentShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'float intensity = max(0.0, -0.05 + pow( -dot( vNormal, vec3( 0, 0, 1.0 ) ) + 0.5, 5.0 ));',
        'gl_FragColor = vec4( 1.0, 1.0, 1.0, 0.8 * intensity );',
      '}'
      ].join('\n')
    }
  };

  var camera, scene, sceneAtmosphere, renderer, w, h;
  var mesh, atmosphere;

  var map = inMap;
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
    w = $(container.parentNode).innerWidth();
    h = $(container.parentNode).innerHeight();

    camera = new THREE.PerspectiveCamera(fov, w / h, 1, 10000);
    camera.position.z = 500;
    scene = new THREE.Scene();
    sceneAtmosphere = new THREE.Scene();

    var geometry = new THREE.SphereGeometry(200, 60, 60);
    console.log(geometry);

    shader = Shaders['earth'];
    uniforms = THREE.UniformsUtils.clone(shader.uniforms);

    mapTexture = new THREE.Texture(map.getCanvas());
    mapTexture.needsUpdate = true;
    uniforms['texture'].value = mapTexture;
    //console.log(uniforms['texture'].value);

    material = new THREE.ShaderMaterial({
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader,
      uniforms: uniforms
    });
    

    projector = new THREE.Projector();

    testHivent = new HG.Hivent("horst", "", 0, 0, 0, []);
  //  mesh = new HG.HiventMarker3D(testHivent, geometry, material);
    mesh = new THREE.Mesh(geometry, material);
    mesh.matrixAutoUpdate = false;
    scene.add(mesh);
  
    /*    
    shader = Shaders['atmosphere'];
    uniforms = THREE.UniformsUtils.clone(shader.uniforms);

    material = new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader
    });

    mesh = new THREE.Mesh(geometry, material);
    mesh.scale.x = mesh.scale.y = mesh.scale.z = 1.5;
    mesh.flipSided = true;
    mesh.matrixAutoUpdate = false;
    mesh.updateMatrix();
    sceneAtmosphere.add(mesh);

    geometry = new THREE.CubeGeometry(0.75, 0.75, 1, 1, 1, 1, null, false, { px: true,
                              nx: true, py: true, ny: true, pz: false, nz: true});

    for (var i = 0; i < geometry.vertices.length; i++) {
      //var vertex = geometry.vertices[i];
      geometry.vertices[i].z += 0.5;
    }
    */

    renderer = new THREE.WebGLRenderer({antialias: true});
    renderer.autoClear = false;
    renderer.setClearColor(0x000000, 0.0);
    renderer.setSize(w, h);

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

      mouseOnDown.x = - event.clientX;
      mouseOnDown.y = event.clientY;

      targetOnDown.x = target.x;
      targetOnDown.y = target.y;

      container.style.cursor = 'move';
   }
  }

  function onMouseMove(event) {
    if (running) { 
      mouse.x = - event.clientX;
      mouse.y = event.clientY;

      var zoomDamp = fov/1000;

      target.x = targetOnDown.x + (mouse.x - mouseOnDown.x) * 0.1 * zoomDamp;
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
    renderer.setSize( $(container.parentNode).innerWidth(), $(container.parentNode).innerHeight());
  }

  function zoom(delta) {
    fovTarget -= delta*zoomSpeed;
    fovTarget = fovTarget > 50 ? 50 : fovTarget;
    fovTarget = fovTarget < 10 ? 10 : fovTarget;
  }

  function animate() {
    if (running) {
      requestAnimationFrame(animate);
      map.redraw();
      mapTexture.needsUpdate = true;
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
    
    /*
    mesh.rotation = new THREE.Vector3(0,0,0);
    mesh.rotateOnAxis(new THREE.Vector3(0,1,0), rotation.y * 100);
    mesh.updateMatrix();
    */
    fov += (fovTarget - fov) * 0.1;
    camera.fov = fov;
    camera.updateProjectionMatrix();

   // var vector = new THREE.Vector3( mouse.x, mouse.y, 1 );
	//	projector.unprojectVector( vector, camera );


    //if (raycaster instanceof THREE.Raycaster)
		//raycaster.set(camera.position, vector.sub(vector, camera.position).normalize());
    //raycaster = new THREE.Raycaster(camera.position, vector.sub(vector, camera.position).normalize());
    //console.log(scene.children);
		//var intersects = raycaster.intersectObjects(scene.children);
		
		/*
		if (intersects.length > 0) {
		  if (intersects[0].getHivent() instanceof HG.Hivent)
		    console.log(intersects[0].getHivent().name);		
		}
		*/

    renderer.clear();
    renderer.render(scene, camera);
    renderer.render(sceneAtmosphere, camera);
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

