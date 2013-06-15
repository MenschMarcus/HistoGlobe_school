//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display2D = function(inContainer, inMap) {
  
  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////
  
  /////////////////////////// STATIC CONSTANTS /////////////////////////////////
  
  HG.Display2D.MAX_ZOOM = 1.5;
  HG.Display2D.MIN_ZOOM = 0.1;
  
  ////////////////////////////// FUNCTIONS /////////////////////////////////////
  
  // ===========================================================================
  this.create = function() {

    initCanvas();
    initEventHandling();
    initHivents();
    
    redraw();
  }
  
  // ===========================================================================
  this.start = function() { 
    if (!myIsRunning) { 
        myIsRunning = true;
        canvasParent.style.display = "inline";
        canvas.style.display = "inline";
        HG.showAllVisibleMarkers2D();
        animate();
    }
  }  
  
  // ===========================================================================
  this.stop = function() {  
    myIsRunning = false;
    HG.deactivateAllHivents();
    HG.hideAllVisibleMarkers2D();
    canvasParent.style.display = "none";
    canvas.style.display = "none";
  }   
  
  // ===========================================================================
  this.isRunning = function() {
    return myIsRunning;
  } 
  
  // ===========================================================================
  this.getCanvas = function() {
    return canvas;
  }
  
  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////
  
  /////////////////////////// MEMBER VARIABLES /////////////////////////////////
  
  var mySelf = this;

  var canvas;
  var canvasParent;
  var canvasOffsetX, canvasOffsetY;
  var canvasVisibleSize = {x: 0, y: 0};
  
  var hiventMarkers = [];
  
  // describes degree / pixel
  var myCurrentZoom = 360/inMap.getResolution().x + 0.1;
  var myTargetZoom = 360/inMap.getResolution().x;
  
  // upper left pixel coordinates
  var myCurrentOffset = {x: 0, y: 0};
  var myTargetOffset = {x: 0, y: 0};
  
  // cursor position in pixels
  var myMouse = { x: 0, y: 0 };
  var myIsDragging = false;
  
  var myIsRunning = false;
  
  ////////////////////////// INIT FUNCTIONS ////////////////////////////////////
  
  // ===========================================================================
  function initCanvas() {
    canvasParent = document.createElement("div");
    
    $(canvasParent).offset({ top:0, left:0});
    canvasParent.style.position = "absolute";

    canvas = document.createElement("canvas");
    
    canvasOffsetX = $(inContainer.parentNode).offset().left;
    canvasOffsetY = $(inContainer.parentNode).offset().top;	
    
    canvasVisibleSize.x = $(inContainer.parentNode).width();
    canvasVisibleSize.y = $(inContainer.parentNode).height();
    
    HG.Display2D.MIN_ZOOM = Math.max(canvasVisibleSize.x / inMap.getResolution().x, canvasVisibleSize.y / inMap.getResolution().y);
    
    clampCanvas();
    updateCanvasSize();

    canvasParent.appendChild(canvas);
    inContainer.appendChild(canvasParent);
  }
  
  // ===========================================================================
  function initEventHandling() {
    inContainer.addEventListener('mousedown', onMouseDown, false);
    
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
    inContainer.addEventListener('mousemove', onMouseMove, false);
  }
  
  // ===========================================================================
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
  
  /////////////////////////// MAIN FUNCTIONS ///////////////////////////////////
  
  // ===========================================================================
  function animate() {
    if (myIsRunning) {
      requestAnimationFrame(animate);
      render();
    }
  }
  
  // ===========================================================================
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
  
  // ===========================================================================
  function redraw() {
    var destinationCtx = canvas.getContext("2d");
    destinationCtx.save();
    destinationCtx.clearRect ( 0 , 0 , canvas.width , canvas.height );
    destinationCtx.scale(myCurrentZoom, myCurrentZoom);
    destinationCtx.drawImage(inMap.getCanvas(),0,0);
    destinationCtx.restore();
  }
  
  // ===========================================================================
  function updateCanvasSize() {
    canvas.width = myCurrentZoom * inMap.getResolution().x;
    canvas.height = myCurrentZoom * inMap.getResolution().y;
  }

  // ===========================================================================
  function clampCanvas() {
    
    var maxOffsetY = 0
    var maxOffsetX = 0

    var minOffsetY = canvasVisibleSize.y - canvas.height;
    var minOffsetX = canvasVisibleSize.x - canvas.width;
    
    if (myTargetZoom < HG.Display2D.MIN_ZOOM) myTargetZoom = HG.Display2D.MIN_ZOOM;
    if (myTargetZoom > HG.Display2D.MAX_ZOOM) myTargetZoom = HG.Display2D.MAX_ZOOM;
    
    myCurrentZoom = Math.min(HG.Display2D.MAX_ZOOM, Math.max(HG.Display2D.MIN_ZOOM, myCurrentZoom));
    
    myCurrentOffset.x = Math.min(maxOffsetX, Math.max(minOffsetX, myCurrentOffset.x));
    myCurrentOffset.y = Math.min(maxOffsetY, Math.max(minOffsetY, myCurrentOffset.y));
  }

  // ===========================================================================
  function zoom(delta) {
    myTargetZoom += delta;
    clampCanvas();
  }
  
  // ===========================================================================
  function updateZoom() {
    
    if (myCurrentZoom != myTargetZoom) {
      if (Math.abs(myCurrentZoom - myTargetZoom) < 0.01) {
        myCurrentZoom = myTargetZoom
      }
      
      var smoothness = 0.3;
      myCurrentZoom = myTargetZoom * smoothness + myCurrentZoom * (1.0 - smoothness);
    
  //      myTargetOffset.x -= delta * 0.5 * inMap.getResolution().x * ( (myMouse.x - myTargetOffset.x)/canvas.width );
  //      myTargetOffset.y -= delta * 0.5 * inMap.getResolution().y * ( (myMouse.y - myTargetOffset.y)/canvas.height );
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
  
  ////////////////////////// EVENT HANDLING ////////////////////////////////////
  
  // ===========================================================================
  function onMouseDown(event) {
    if (myIsRunning) { 
        event.preventDefault();
        
        myIsDragging = true;

        inContainer.addEventListener('mouseup', onMouseUp, false);
        inContainer.addEventListener('mouseout', onMouseOut, false);

        myMouse.x = event.clientX;
        myMouse.y = event.clientY;

        inContainer.style.cursor = 'move';
    }
  }
  
  // ===========================================================================
  function onMouseMove(event) {
    if (myIsRunning) {
      if (myIsDragging) {
        
        myTargetOffset.x -= myMouse.x - event.clientX;
        myTargetOffset.y -= myMouse.y - event.clientY;
        
        clampCanvas();
      }
    }
    myMouse.x = event.clientX;
    myMouse.y = event.clientY;
  }
  
  // ===========================================================================
  function onMouseUp(event) {
    if (myIsRunning) { 

      HG.deactivateAllHivents();
      myIsDragging = false;

      inContainer.removeEventListener('mouseup', onMouseUp, false);
      inContainer.removeEventListener('mouseout', onMouseOut, false);
      inContainer.style.cursor = 'auto';
    }
  }
  
  // ===========================================================================
  function onMouseOut(event) {
    if (myIsRunning) { 
      myIsDragging = false;
      inContainer.removeEventListener('mouseup', onMouseUp, false);
      inContainer.removeEventListener('mouseout', onMouseOut, false);
    }
  }
  
  // ===========================================================================
  function onMouseWheel(delta) {
    if (myIsRunning) { 
      zoom(delta * 0.0005);
    }
    return false;
  }
  
  // ===========================================================================
  function onDocumentKeyDown(event) {
    if (myIsRunning) { 
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
  
  // ===========================================================================
  function onWindowResize( event ) {
    canvasOffsetX = $(inContainer.parentNode).offset().left;
    canvasOffsetY = $(inContainer.parentNode).offset().top;	
    
    canvasVisibleSize.x = $(inContainer.parentNode).width();
    canvasVisibleSize.y = $(inContainer.parentNode).height();
    
    HG.Display2D.MIN_ZOOM = Math.max(canvasVisibleSize.x / inMap.getResolution().x, canvasVisibleSize.y / inMap.getResolution().y);
    
    clampCanvas();
    updateCanvasSize();
    redraw();
  }
  
  ///////////////////////// HELPER FUNCTIONS ///////////////////////////////////
  
  // ===========================================================================
  function mouseToLongLat(mousePos) {
	  return {
	    x: (mousePos.x - canvasOffsetX - myCurrentOffset.x) / (myCurrentZoom * inMap.getResolution().x) *  360 - 180,
      y: (mousePos.y - canvasOffsetY - myCurrentOffset.y) / (myCurrentZoom * inMap.getResolution().y) * -180 + 90
	  };
  }
  
  // ===========================================================================
  function longLatToPixel(longlat) {
    return {
      x: ((longlat.x + 180) /  360) * myCurrentZoom * inMap.getResolution().x  + myCurrentOffset.x + canvasOffsetX,
      y: ((longlat.y -  90) / -180) * myCurrentZoom * inMap.getResolution().y  + myCurrentOffset.y + canvasOffsetY
    };
  }
  
  // ===========================================================================
  function longLatToCanvasCoord(longlat) {
    return {
      x: ((-longlat.x + 180) / 360) * myCurrentZoom * inMap.getResolution().x,
      y: ((longlat.y -  90) / -180) * myCurrentZoom * inMap.getResolution().y
    };
  }

  HG.Display.call(this);

  // create the object!
  this.create();
  
  // all done!
  return this;

};

HG.Display2D.prototype = Object.create(HG.Display.prototype);

