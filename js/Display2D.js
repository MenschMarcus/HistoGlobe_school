var HG = HG || {};

HG.Display2D = function(container, inMap) {

  var canvas;
  var canvasOffsetX, canvasOffsetY;
  var canvasVisibleSize = {x: 0, y: 0};

  var map = inMap;
  
  // describes degree / pixel
  var curZoom = 360/map.getResolution().x;
  
  // upper left pixel coordinates
  var curOffset = {x: 0, y: 0};
  
  // cursor position in pixels
  var mouse = { x: 0, y: 0 };
  var drag = false;
  var maxZoom = 1.5;
  var minZoom = 0.1;
  
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

    canvas = document.createElement("canvas");

    canvas.style.position = "absolute";
    
    canvasOffsetX = $(container.parentNode).offset().left;
    canvasOffsetY = $(container.parentNode).offset().top;	
    
    canvasVisibleSize.x = $(container.parentNode).width();
    canvasVisibleSize.y = $(container.parentNode).height();
    
    minZoom = Math.max(canvasVisibleSize.x / map.getResolution().x, canvasVisibleSize.y / map.getResolution().y);
    
    clampCanvas();
    updateCanvasSize();

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
    container.addEventListener('mousemove', onMouseMove, false);

    container.addEventListener('mouseover', function() {
      overRenderer = true;
    }, false);

    container.addEventListener('mouseout', function() {
      overRenderer = false;
    }, false);
    
    redraw();
  }
  

  
  function redraw() {
    var destinationCtx = canvas.getContext("2d");
    destinationCtx.save();
    destinationCtx.clearRect ( 0 , 0 , canvas.width , canvas.height );
    destinationCtx.scale(curZoom, curZoom);
    destinationCtx.drawImage(map.getCanvas(),0,0);
    destinationCtx.restore();
  }
  
  function updateCanvasSize() {
    canvas.width = curZoom * map.getResolution().x;
    canvas.height = curZoom * map.getResolution().y;
  }

  function onMouseDown(event) {
    if (running) { 
        event.preventDefault();
        
        drag = true;

        container.addEventListener('mouseup', onMouseUp, false);
        container.addEventListener('mouseout', onMouseOut, false);

        mouse.x = event.clientX;
        mouse.y = event.clientY;

        container.style.cursor = 'move';
    }
  }

  function onMouseMove(event) {
    if (running) {
      if (drag) {
        
        curOffset.x -= mouse.x - event.clientX;
        curOffset.y -= mouse.y - event.clientY;
        
        clampCanvas();
      }
    }
    mouse.x = event.clientX;
    mouse.y = event.clientY;
  }
  
  function clampCanvas() {
    
    var maxOffsetY = 0
    var maxOffsetX = 0

    var minOffsetY = canvasVisibleSize.y - canvas.height;
    var minOffsetX = canvasVisibleSize.x - canvas.width;
    
    if (curZoom < minZoom) curZoom = minZoom;
    if (curZoom > maxZoom) curZoom = maxZoom;
    
    curZoom = Math.min(maxZoom, Math.max(minZoom, curZoom));
    
    curOffset.x = Math.min(maxOffsetX, Math.max(minOffsetX, curOffset.x));
    curOffset.y = Math.min(maxOffsetY, Math.max(minOffsetY, curOffset.y));
  }

  function onMouseUp(event) {
    if (running) { 
      drag = false;
      container.removeEventListener('mouseup', onMouseUp, false);
      container.removeEventListener('mouseout', onMouseOut, false);
      container.style.cursor = 'auto';
    }
  }

  function onMouseOut(event) {
    if (running) { 
      drag = false;
      container.removeEventListener('mouseup', onMouseUp, false);
      container.removeEventListener('mouseout', onMouseOut, false);
    }
  }

  function onMouseWheel(delta) {
    if (running) { 
      if (overRenderer) {
        zoom(delta * 0.0005);
      }
    }
    return false;
  }

  function onDocumentKeyDown(event) {
    if (running) { 
      switch (event.keyCode) {
        case 38:
          zoom(0.05);
          event.preventDefault();
          break;
        case 40:
          zoom(-0.05);
          event.preventDefault();
          break;
      }
   }
  }

  function onWindowResize( event ) {
    canvasOffsetX = $(container.parentNode).offset().left;
    canvasOffsetY = $(container.parentNode).offset().top;	
    
    canvasVisibleSize.x = $(container.parentNode).width();
    canvasVisibleSize.y = $(container.parentNode).height();
    
    minZoom = Math.max(canvasVisibleSize.x / map.getResolution().x, canvasVisibleSize.y / map.getResolution().y);
    
    clampCanvas();
    updateCanvasSize();
    redraw();
  }

  function zoom(delta) {
    curZoom += delta;
    
    if (curZoom < maxZoom && curZoom > minZoom) {
      curOffset.x -= delta * 0.5 * map.getResolution().x * ( (mouse.x - curOffset.x)/canvas.width );
      curOffset.y -= delta * 0.5 * map.getResolution().y * ( (mouse.y - curOffset.y)/canvas.height );
      canvas.style.top= curOffset.y + "px";
      canvas.style.left = curOffset.x + "px";
    }
    
    clampCanvas();
    updateCanvasSize();
    redraw();
  }
  
  function mouseToLongLat(mousePos) {
	  return {
	    x: (mousePos.x - canvasOffsetX - curOffset.x) / curZoom / map.getResolution().x * 360 - 180,
      y: (mousePos.y - canvasOffsetY - curOffset.y) / curZoom / map.getResolution().y * -180 + 90
	  };
  }

  function animate() {
    if (running) {
      requestAnimationFrame(animate);
      //map.redraw();
      render();
    }
  }

  function render() {
    canvas.style.top= curOffset.y + "px";
    canvas.style.left = curOffset.x + "px";
  }

  init();

  return this;

};

