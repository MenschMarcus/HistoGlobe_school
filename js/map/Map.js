var HG = HG || {};

HG.Map = function(inHistrips) {

  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// STATIC CONSTANTS /////////////////////////////////

  HG.Map.HEIGTH = 1024;
  HG.Map.WIDTH = 2048;

  ////////////////////////////// FUNCTIONS /////////////////////////////////////

  // ===========================================================================
  this.create = function() {
    initCanvas();
    initBackground();
    initHistrips();
  }

  // ===========================================================================
  this.getCanvas = function() {
    return myCanvas;
  }

  // ===========================================================================
  this.getResolution = function() {
    return {x:HG.Map.WIDTH, y:HG.Map.HEIGTH};
  }

  // ===========================================================================
  this.setMouseLongLat = function(longLat) {
    var hitOptions = {
      segments: false,
      stroke: false,
      fill: true,
      tolerance: 5
    };

    var pixel = this.longLatToPixel(longLat);
    var hoverChanged = false;

    var hitResult = paper.project.hitTest(pixel, hitOptions);
    if (hitResult) {
      var item = hitResult.item;

      if (item instanceof HG.HistripMarker) {

        if (myLastHoveredItem != item) {
          if (myLastHoveredItem) {
            myLastHoveredItem.unHover();
            myLastHoveredItem = null;
          }

          item.hover();
          myLastHoveredItem = item;
          hoverChanged = true;
        }
      } else if (myLastHoveredItem) {
        myLastHoveredItem.unHover();
        myLastHoveredItem = null;

        hoverChanged = true;
      }
    }

    if (hoverChanged) {
      redraw();
    }
  }

  // ===========================================================================
  this.onRedraw = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      myOnRedrawCallbacks.push(callbackFunc);
    }
  }

    // ===========================================================================
  this.longLatToPixel = function(longlat) {
    return {
      x: ((longlat.x + 180) /  360) * HG.Map.WIDTH,
      y: ((longlat.y -  90) / -180) * HG.Map.HEIGTH
    };
  }

  // ===========================================================================
  this.pixelToLongLat = function(pixel) {
    return {
      x: 1.0 * pixel.x / HG.Map.WIDTH  *  360 - 180,
      y: 1.0 * pixel.y / HG.Map.HEIGTH * -180 + 90
    };
  }


  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// MEMBER VARIABLES /////////////////////////////////

  var mySelf = this;
  var myCanvas;
  var myOnRedrawCallbacks = [];

  var myLastHoveredItem;

  ////////////////////////// INIT FUNCTIONS ////////////////////////////////////

  // ===========================================================================
  function initCanvas() {
    myCanvas = document.createElement("canvas");
    myCanvas.height = HG.Map.HEIGTH;
    myCanvas.width = HG.Map.WIDTH;

    paper.setup(myCanvas);
  }

  // ===========================================================================
  function initBackground() {
    var background = new paper.Raster("img/map.jpg");

    background.onLoad = function() {
      background.position = new paper.Point(HG.Map.WIDTH/2, HG.Map.HEIGTH/2);
      redraw();
    };
  }

  // ===========================================================================
  function initHistrips() {

    inHistrips.onHistripsLoaded(function(handles) {

      for (var h=0; h<handles.length; h++) {
        var path = new HG.HistripMarker(handles[h], mySelf);
      }

      redraw();
    });
  }

  /////////////////////////// MAIN FUNCTIONS ///////////////////////////////////

  // ===========================================================================
  function redraw() {
     paper.view.draw();

    for (var i=0; i < myOnRedrawCallbacks.length; i++)
      myOnRedrawCallbacks[i]();
  }

  ///////////////////////// HELPER FUNCTIONS ///////////////////////////////////

  // create the object!
  this.create();

  // all done!
  return this;

};

