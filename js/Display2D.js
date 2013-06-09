//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display2D = function(container, inMap) {

  var canvas;
  var canvasParent;
  var canvasOffsetX, canvasOffsetY;

  var map = inMap;
  
  // describes degree / pixel
  var curZoom = 360/map.getResolution().x;
  
  // upper left pixel coordinates
  var curOffset = {x: 0, y: 0};
  
  // cursor position in pixels
  var mouse = { x: 0, y: 0 };

  
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
    canvasParent.style.width = 1024*2;
    canvasParent.style.height = 1024;
    
    $(canvasParent).offset({ top:0, left:0});
    canvasParent.style.position = "absolute";

    canvas = document.createElement("canvas");
    canvas.width = 1024*2;
    canvas.height = 1024;
    
    
    canvasOffsetX = $(container.parentNode).offset().left;
    canvasOffsetY = $(container.parentNode).offset().top;	

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
    destinationCtx.scale(curZoom, curZoom);
    destinationCtx.drawImage(map.getCanvas(),0,0);
    destinationCtx.restore();
  }

  function onMouseDown(event) {
    if (running) { 
        event.preventDefault();

        container.addEventListener('mousemove', onMouseMove, false);
        container.addEventListener('mouseup', onMouseUp, false);
        container.addEventListener('mouseout', onMouseOut, false);

        mouse.x = event.clientX;
        mouse.y = event.clientY;
        
        var longlat = mouseToLongLat(mouse);
        
        console.log("long: " + longlat.x + " lat: " + longlat.y);

        container.style.cursor = 'move';
    }
  }

  function onMouseMove(event) {
    if (running) {
        
        curOffset.x -= mouse.x - event.clientX;
        curOffset.y -= mouse.y - event.clientY;
        
        mouse.x = event.clientX;
        mouse.y = event.clientY;
    }
  }

  function onMouseUp(event) {
    if (running) { 
      HG.deactivateAllHivents();
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
        zoom(delta * 0.0001);
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
    canvasOffsetX = $(container.parentNode).offset().left;
    canvasOffsetY = $(container.parentNode).offset().top;	
  }

  function zoom(delta) {
    curZoom += delta;
    console.log('zoom: ' + curZoom);
    redraw();
  }
  
  function mouseToLongLat(mousePos) {
	  return {
	    x: (mousePos.x - canvasOffsetX - curOffset.x) / curZoom / map.getResolution().x * 360 - 180,
      y: (mousePos.y - canvasOffsetY - curOffset.y) / curZoom / map.getResolution().y * -180 + 90
	  };
  }
  
  function longLatToPixel(longlat) {
    return {
      x: (longlat.x + 180) / map.getResolution().x * 360  / curZoom + curOffset.x + canvasOffsetX,
      y: (longlat.y -  90) / map.getResolution().y * -180 / curZoom + curOffset.y + canvasOffsetY
    };
  }

  function initHivents() {
      
    var hivents;
    
    hiventHandler.onHiventsLoaded(function(h){

      hivents = h;
      
      for (var i=0; i<hivents.length; i++) {
        
        var pos = longLatToPixel({x: hivents[i].long, y: hivents[i].lat});   
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

