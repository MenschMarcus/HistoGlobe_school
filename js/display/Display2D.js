//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display2D = function(container, inMap) {

  var self = this;

  var canvas;
  var canvasParent;
  var canvasOffsetX, canvasOffsetY;
  var canvasVisibleSize = {x: 0, y: 0};

  var map = inMap;
  
  var hiventMarkers = [];
  
  // describes degree / pixel
  var myCurrentZoom = 360/map.getResolution().x + 0.1;
  var myTargetZoom = 360/map.getResolution().x;
  
  // upper left pixel coordinates
  var myCurrentOffset = {x: 0, y: 0};
  var myTargetOffset = {x: 0, y: 0};
  
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
    
    initHivents();
    
    redraw();
  }
  

  
  function redraw() {
    var destinationCtx = canvas.getContext("2d");
    destinationCtx.save();
    destinationCtx.clearRect ( 0 , 0 , canvas.width , canvas.height );
    destinationCtx.scale(myCurrentZoom, myCurrentZoom);
    destinationCtx.drawImage(map.getCanvas(),0,0);
    destinationCtx.restore();
  }
  
  function updateCanvasSize() {
    canvas.width = myCurrentZoom * map.getResolution().x;
    canvas.height = myCurrentZoom * map.getResolution().y;
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
        
        myTargetOffset.x -= mouse.x - event.clientX;
        myTargetOffset.y -= mouse.y - event.clientY;
        
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
    
    if (myTargetZoom < minZoom) myTargetZoom = minZoom;
    if (myTargetZoom > maxZoom) myTargetZoom = maxZoom;
    
    myCurrentZoom = Math.min(maxZoom, Math.max(minZoom, myCurrentZoom));
    
    myCurrentOffset.x = Math.min(maxOffsetX, Math.max(minOffsetX, myCurrentOffset.x));
    myCurrentOffset.y = Math.min(maxOffsetY, Math.max(minOffsetY, myCurrentOffset.y));
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
    myTargetZoom += delta;
    clampCanvas();
  }
  
  function updateZoom() {
    
    if (myCurrentZoom != myTargetZoom) {
      if (Math.abs(myCurrentZoom - myTargetZoom) < 0.01) {
        myCurrentZoom = myTargetZoom
      }
      
      var smoothness = 0.3;
      myCurrentZoom = myTargetZoom * smoothness + myCurrentZoom * (1.0 - smoothness);
    
  //      myTargetOffset.x -= delta * 0.5 * map.getResolution().x * ( (mouse.x - myTargetOffset.x)/canvas.width );
  //      myTargetOffset.y -= delta * 0.5 * map.getResolution().y * ( (mouse.y - myTargetOffset.y)/canvas.height );
  //      canvas.style.top= myTargetOffset.y + "px";
  //      canvas.style.left = myTargetOffset.x + "px";
      
      
      for (var i = 0; i < hiventMarkers.length; i++) {
        var longlat = {
          x: hiventMarkers[i].getHiventHandle().getHivent().long,
          y: hiventMarkers[i].getHiventHandle().getHivent().lat
        };
    
        hiventMarkers[i].setPosition(longLatToCanvasCoord(longlat));
      }
      
      clampCanvas();
      updateCanvasSize();
      redraw();
    }
  }
  
  function mouseToLongLat(mousePos) {
	  return {
	    x: (mousePos.x - canvasOffsetX - myCurrentOffset.x) / (myCurrentZoom * map.getResolution().x) *  360 - 180,
      y: (mousePos.y - canvasOffsetY - myCurrentOffset.y) / (myCurrentZoom * map.getResolution().y) * -180 + 90
	  };
  }
  
  function longLatToPixel(longlat) {
    return {
      x: ((longlat.x + 180) /  360) * myCurrentZoom * map.getResolution().x  + myCurrentOffset.x + canvasOffsetX,
      y: ((longlat.y -  90) / -180) * myCurrentZoom * map.getResolution().y  + myCurrentOffset.y + canvasOffsetY
    };
  }

  function longLatToCanvasCoord(longlat) {
    return {
      x: ((-longlat.x + 180) /  360) * myCurrentZoom * map.getResolution().x,
      y: ((longlat.y -  90) / -180) * myCurrentZoom * map.getResolution().y
    };
  }

  function initHivents() {
          
    hiventHandler.onHiventsLoaded(function(handles){
      
      for (var i=0; i<handles.length; i++) {
        
        var hivent = handles[i].getHivent();
                
        var pos = longLatToCanvasCoord({x: hivent.long, y: hivent.lat});  
        var hivent = new HG.HiventMarker2D(handles[i], canvasParent, 
                                           pos.x, pos.y,
                                           canvasOffsetX + myCurrentOffset.x,
                                           canvasOffsetY + myCurrentOffset.y);
        hiventMarkers.push(hivent);
      }
    });
  }

  function animate() {
    if (running) {
      requestAnimationFrame(animate);
      render();
    }
  }

  function render() { 
    
    var smoothness = 0.7;
    
    myCurrentOffset.x = myCurrentOffset.x * smoothness + myTargetOffset.x * (1.0 - smoothness);
    myCurrentOffset.y = myCurrentOffset.y * smoothness + myTargetOffset.y * (1.0 - smoothness);
    
    updateZoom();
    
    clampCanvas();

    canvasParent.style.top= myCurrentOffset.y + "px";
    canvasParent.style.left = myCurrentOffset.x + "px";
    
    for (var i = 0; i < hiventMarkers.length; i++) {
      hiventMarkers[i].setOffset({x: myCurrentOffset.x + canvasOffsetX,
                                  y: myCurrentOffset.y + canvasOffsetY });
    }

  }

  HG.Display.call(this);
  init();

  return this;

};

HG.Display2D.prototype = Object.create(HG.Display.prototype);

