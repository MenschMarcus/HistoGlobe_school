//include Hivent.js

var HG = HG || {};

HG.HiventHandler = function() {
  
  var hivents = [];
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
          h[i].parties
        );
        hivents.push(hivent);
      }
      hiventsLoaded = true;
      for (var i=0; i < onHiventsLoadedCallbacks.length; i++)
        onHiventsLoadedCallbacks[i](hivents);
    }); 

  }
  
  this.getAllHivents = function() {
    return hivents;
  }
  
  this.onHiventsLoaded = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      if (!hiventsLoaded)
        onHiventsLoadedCallbacks.push(callbackFunc);
      else
        callbackFunc(hivents);
    }
  }
  
  init();
  
  return this;


};

