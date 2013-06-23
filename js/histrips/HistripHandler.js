//include Histrip.js
//include HistripHandle.js

var HG = HG || {};

HG.HistripHandler = function() {

  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  // ===========================================================================
  this.create = function() {

    $.getJSON("data/histrips.json", function(h){
      for (var i=0; i<h.length; i++) {
        var histrip = new HG.Histrip(
          h[i].coords,
          h[i].category
        );
        histripHandles.push(new HG.HistripHandle(histrip));
      }

      histripsLoaded = true;
      for (var i=0; i < onHistripsLoadedCallbacks.length; i++)
        onHistripsLoadedCallbacks[i](histripHandles);
    });

  }

  // ===========================================================================
  this.getAllHistripHandles = function() {
    return histripHandles;
  }

  // ===========================================================================
  this.onHistripsLoaded = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      if (!histripsLoaded)
        onHistripsLoadedCallbacks.push(callbackFunc);
      else
        callbackFunc(histripHandles);
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// MEMBER VARIABLES /////////////////////////////////

  var histripHandles = [];
  var histripsLoaded = false;
  var onHistripsLoadedCallbacks = [];

  // create the object!
  this.create();

  // all done!
  return this;
};

