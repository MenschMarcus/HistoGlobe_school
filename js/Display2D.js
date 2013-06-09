var HG = HG || {};

HG.Display2D = function(container, inMap) {

  var canvas;

  var map = inMap;
  
  // describes degree / pixel
  var curZoom = 1;
  
  // upper left long lat coordinates
  var curOffset = {x: 0, y: 0};
  
  // cursor position in pixels
  var mouse = { x: 0, y: 0 };

  
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

        mouse.x = event.clientX;
        mouse.y = event.clientY;

        container.style.cursor = 'move';
    }
  }

  function onMouseMove(event) {
    if (running) {
    
        curOffset.x += mouse.x - event.clientX;
        curOffset.y += mouse.y - event.clientY;
        
        mouse.x = event.clientX;
        mouse.y = event.clientY;
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

  }

  function animate() {
    if (running) {
      requestAnimationFrame(animate);
      map.redraw();
      render();
    }
  }

  function render() {


    console.log(curOffset);

    
    var sourceCtx = map.getCanvas().getContext("2d");
    var imageData=sourceCtx.getImageData(curOffset.x, canvas.height - curOffset.y, canvas.width, canvas.height);
    var destinationCtx = canvas.getContext("2d");
    destinationCtx.putImageData(imageData,0,0);

  }

  init();

  return this;

};

