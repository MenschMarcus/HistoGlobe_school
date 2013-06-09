//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display2D = function(container, inMap) {

  var canvas;
  var canvasParent;
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
        canvasParent.style.display = "inline";
        canvas.style.display = "inline";
        HG.showAllVisibleMarkers2D();
        animate();
    }
  }  
  
  this.stop = function() {  
    running = false;
    HG.deactivateAllHivents();
    HG.hideAllVisibleMarkers2D();
    canvasParent.style.display = "none";
    canvas.style.display = "none";
  }   
  
  this.isRunning = function() {
    return running;
  } 
  
  this.getCanvas = function() {
    return canvas;
  }
  
  function init() {

    canvasParent = document.createElement("div");
//    canvasParent.style.width = 1024*2;
//    canvasParent.style.height = 1024;
    
    $(canvasParent).offset({ top:0, left:0});
    canvasParent.style.position = "absolute";

    canvas = document.createElement("canvas");
    
    canvasOffsetX = $(container.parentNode).offset().left;
    canvasOffsetY = $(container.parentNode).offset().top;	
    
    canvasVisibleSize.x = $(container.parentNode).width();
    canvasVisibleSize.y = $(container.parentNode).height();
    
    minZoom = Math.max(canvasVisibleSize.x / map.getResolution().x, canvasVisibleSize.y / map.getResolution().y);
    
    clampCanvas();
    updateCanvasSize();

    canvasParent.appendChild(canvas);
    container.appendChild(canvasParent);
    
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
    
    //initHivents();
    
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
    
//    canvasParent.style.width = curZoom * map.getResolution().x;
//    canvasParent.style.height = curZoom * map.getResolution().y;
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

      HG.deactivateAllHivents();
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
	    x: (mousePos.x - canvasOffsetX - curOffset.x) / (curZoom * map.getResolution().x) *  360 - 180,
      y: (mousePos.y - canvasOffsetY - curOffset.y) / (curZoom * map.getResolution().y) * -180 + 90
	  };
  }
  
  function longLatToPixel(longlat) {
    return {
      x: ((longlat.x + 180) /  360) * curZoom * map.getResolution().x  + curOffset.x + canvasOffsetX,
      y: ((longlat.y -  90) / -180) * curZoom * map.getResolution().y  + curOffset.y + canvasOffsetY
    };
  }

  function longLatToCanvasCoord(longlat) {
    return {
      x: ((-longlat.x + 180) /  360) * curZoom * map.getResolution().x,
      y: ((longlat.y -  90) / -180) * curZoom * map.getResolution().y
    };
  }

  function initHivents() {
      
    var hivents;
    
    hiventHandler.onHiventsLoaded(function(h){

      hivents = h;
      
      for (var i=0; i<hivents.length; i++) {
        
        var pos = longLatToCanvasCoord({x: hivents[i].long, y: hivents[i].lat});  
        console.log(pos) 
        var hivent = new HG.HiventMarker2D(hivents[i], canvasParent, pos.x, pos.y);
      }
    });
  }

  function animate() {
    if (running) {
      requestAnimationFrame(animate);
      //map.redraw();
      render();
    }
  }

  function render() { 

    //console.log(curOffset);
    canvasParent.style.top= curOffset.y + "px";
    canvasParent.style.left = curOffset.x + "px";

  }

  init();

  return this;

};

