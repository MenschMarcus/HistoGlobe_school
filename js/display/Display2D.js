//include HiventHandler.js
//include HiventMarker3D.js

var HG = HG || {};

HG.Display2D = function(inContainer, inHiventHandler) {
  

  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  ////////////////////////////// FUNCTIONS /////////////////////////////////////
  
  // ===========================================================================
  this.create = function() {
    
    initCanvas();
    initEventHandling();
    initHivents();
  }

  // ===========================================================================
  this.start = function() {
    if (!myIsRunning) {
        myIsRunning = true;
        mapParent.style.display = "block";
    }
  }

  // ===========================================================================
  this.stop = function() {
    myIsRunning = false;
//    HG.deactivateAllHivents();
//    HG.hideAllVisibleMarkers2D();
    mapParent.style.display = "none";
  }

  // ===========================================================================
  this.isRunning = function() {
    return myIsRunning;
  }

  // ===========================================================================
  this.getCanvas = function() {
    return mapParent;
  }

  // ===========================================================================
  this.center = function(longLat) {
    myMap.panTo([longLat.y, longLat.x]);
  }

  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// MEMBER VARIABLES /////////////////////////////////

  var mySelf = this;
  
  var myMap;
  
  var mapParent;

  var hiventMarkers = [];

  var myIsRunning = false;

  ////////////////////////// INIT FUNCTIONS ////////////////////////////////////

  // ===========================================================================
  function initCanvas() {
  
    mapParent = document.createElement("div");

    mapParent.style.width = $(inContainer.parentNode).width() + "px";
    mapParent.style.height = $(inContainer.parentNode).height() + "px";

    inContainer.appendChild(mapParent);
  
  
    myMap = L.map(mapParent, {maxZoom:6, minZoom:1, zoomControl:false}).setView([51.505, 10.09], 4);
    myMap.attributionControl.setPrefix('');

    L.tileLayer('data/tiles/{z}/{x}/{y}.png').addTo(myMap);

    myIsRunning = true;
  }

  // ===========================================================================
  function initEventHandling() {
    window.addEventListener('resize', onWindowResize, false);
  }

  // ===========================================================================
  function initHivents() {
          
    inHiventHandler.onHiventsLoaded(function(handles){
      
      for (var i=0; i<handles.length; i++) {

        var marker = new HG.HiventMarker2D(handles[i], mySelf, myMap);
        hiventMarkers.push(marker);
      }
    });
    
    myMap.on("click",  HG.deactivateAllHivents);
  }


  ////////////////////////// EVENT HANDLING ////////////////////////////////////

  // ===========================================================================
  function onWindowResize( event ) {
    mapParent.style.width = $(inContainer.parentNode).width() + "px";
    mapParent.style.height = $(inContainer.parentNode).height() + "px";
  }

	// call base class constructor
  HG.Display.call(this);

  // create the object!
  this.create();

  // all done!
  return this;

};

HG.Display2D.prototype = Object.create(HG.Display.prototype);
