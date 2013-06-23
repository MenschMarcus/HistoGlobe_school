//include Histrip.js

var HG = HG || {};

HG.HistripHandle = function(inHistrip) {

  var hovered = false;

  var onHoverCallbacks = [];
  var onUnHoverCallbacks = [];

  this.getHistrip = function() {
    return inHistrip;
  }

  this.hover = function() {
    if (!hovered) {
      hovered = true;
      for (var i=0; i < onHoverCallbacks.length; i++)
        onHoverCallbacks[i]();
    }
  }

  this.unHover = function() {
    if (hovered) {
      hovered = false;
      for (var i=0; i < onUnHoverCallbacks.length; i++)
        onUnHoverCallbacks[i]();
    }
  }

  this.onHover = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onHoverCallbacks.push(callbackFunc);
    }
  }

  this.onUnHover = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onUnHoverCallbacks.push(callbackFunc);
    }
  }

  return this;
};

