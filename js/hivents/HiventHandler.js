//include Hivent.js
//include HiventHandle.js

var HG = HG || {};

HG.HiventHandler = function() {
  
  var hiventHandles = [];
  var hiventsLoaded = false;
  var onHiventsLoadedCallbacks = [];
  
  function init() {    
    $.getJSON("data/hivents.json", function(h){
      for (var i=0; i<h.length; i++) {
        var hivent = new HG.Hivent(
          h[i].name,
          h[i].category,
          h[i].date,
          h[i].long,
          h[i].lat,
          h[i].description,
          h[i].parties
        );
        hiventHandles.push(new HG.HiventHandle(hivent));
      }
      hiventsLoaded = true;
      for (var i=0; i < onHiventsLoadedCallbacks.length; i++)
        onHiventsLoadedCallbacks[i](hiventHandles);
    }); 

  }
  
  this.getAllHiventHandles = function() {
    return hiventHandles;
  }
  
  this.onHiventsLoaded = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      if (!hiventsLoaded)
        onHiventsLoadedCallbacks.push(callbackFunc);
      else
        callbackFunc(hiventHandles);
    }
  }
  
  init();
  
  return this;


};

