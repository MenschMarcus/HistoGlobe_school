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

HG.Display2D = function(container, inMap) {

  var canvas;

  var map = inMap;

  var curZoomSpeed = 0;
  var zoomSpeed = 50;

  var mouse;
  var mouseOnDown;
  var panning;
  var target;
  var targetOnDown;

  var distance = 10000, distanceTarget = 800;
  var padding = 40;
  
  var running = false;
  
  this.start = function() { 
    if (!running) { 
        running = true;
        canvas.style.display = "inline";
        animate();
    }
  }  
  
  this.stop = function() {  
    running = false;
    canvas.style.display = "none";
  }   
  
  this.isRunning = function() {
    return running;
  } 
  
  this.getCanvas = function() {
    return canvas;
  }
  
  function init() {

    var width = $(container.parentNode).innerWidth();
    var height = $(container.parentNode).innerHeight();
    
    mouse = { x: 0, y: 0 }, mouseOnDown = { x: 0, y: 0 };
    panning = { x: 0, y: height };
    target = { x:0, y: height };
    targetOnDown = { x: 0, y: 0 };

    canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    canvas.style.position = "absolute";

    container.appendChild(canvas);
    
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

        var zoomDamp = distance/1000;

        target.x = targetOnDown.x + (mouse.x - mouseOnDown.x) * 0.5 * zoomDamp;
        target.y = targetOnDown.y + (mouse.y - mouseOnDown.y) * 0.5 * zoomDamp;
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
    console.log('resize');
  
  }

  function zoom(delta) {
    distanceTarget -= delta;
    distanceTarget = distanceTarget > 1000 ? 1000 : distanceTarget;
    distanceTarget = distanceTarget < 350 ? 350 : distanceTarget;
  }

  function animate() {
    if (running) {
      requestAnimationFrame(animate);
      map.redraw();
      render();
    }
  }

  function render() {
    zoom(curZoomSpeed);

    target.y = Math.max(map.getCanvas().height + (canvas.height - map.getCanvas().height), Math.min(canvas.height, target.y));
    panning.x += (target.x - panning.x) * 0.1;
    panning.y += (target.y - panning.y) * 0.1;
    //console.log(canvas.height);
    distance += (distanceTarget - distance) * 0.3;
    
    var sourceCtx = map.getCanvas().getContext("2d");
    var imageData=sourceCtx.getImageData(panning.x, canvas.height - panning.y, canvas.width, canvas.height);
    var destinationCtx = canvas.getContext("2d");
    destinationCtx.putImageData(imageData,0,0);

  }

  init();

  return this;

};

