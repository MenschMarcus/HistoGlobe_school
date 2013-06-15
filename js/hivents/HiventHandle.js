//include Hivent.js

var HG = HG || {};

HG.activeHivents = [];

HG.HiventHandle = function(inHivent) {
  
  var activated = false;
  var hovered = false;
  var focussed = false;
  
  var onActiveCallbacks = [];
  var onInActiveCallbacks = [];
  var onHoverCallbacks = [];
  var onUnHoverCallbacks = [];
  var onFocusCallbacs = [];
  var onUnFocusCallbacs = [];
  
  this.getHivent = function() {
    return inHivent;
  }
  
  this.active = function(mousePixelPosition) {
    activated = true;
    HG.activeHivents.push(this);
    for (var i=0; i < onActiveCallbacks.length; i++)
      onActiveCallbacks[i](mousePixelPosition); 
  } 

  this.inActive = function(mousePixelPosition) {
    activated = false;
    var index = $.inArray(this, HG.activeHivents);
    if (index >= 0)
      delete HG.activeHivents[index];
      
    for (var i=0; i < onInActiveCallbacks.length; i++)
      onInActiveCallbacks[i](mousePixelPosition); 
  } 

  this.toggleActive = function(mousePixelPosition) {
    activated = !activated;
    if (activated) {
      this.active(mousePixelPosition);
    } else {
      this.inActive(mousePixelPosition);
    }
  } 
  
  this.hover = function(mousePixelPosition) {
    if (!hovered) {
      hovered = true;
      for (var i=0; i < onHoverCallbacks.length; i++)
        onHoverCallbacks[i](mousePixelPosition); 
    } 
  } 
  
  this.unHover = function(mousePixelPosition) {
    if (hovered) {
      hovered = false;
      for (var i=0; i < onUnHoverCallbacks.length; i++)
        onUnHoverCallbacks[i](mousePixelPosition); 
    } 
  } 
  
  this.focus = function(mousePixelPosition) {
    focussed = true;
    
    for (var i=0; i < onFocusCallbacks.length; i++)
      onActiveCallbacks[i](mousePixelPosition); 
    this.active(mousePixelPosition);
  } 

  this.unFocus = function(mousePixelPosition) {
    focussed = false;
     
    for (var i=0; i < onUnFocusCallbacks.length; i++)
      onUnFocusCallbacks[i](mousePixelPosition); 
    this.inActive();
  }  
 
  this.onActive = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onActiveCallbacks.push(callbackFunc);
    }
  }
    
  this.onInActive = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onInActiveCallbacks.push(callbackFunc);
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

  this.onFocus = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onFocusCallbacks.push(callbackFunc);
    }
  }
    
  this.onUnFocus = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onUnFocusCallbacks.push(callbackFunc);
    }
  }
  
  return this;
};

HG.deactivateAllHivents = function() {
  for (var i = 0; i < HG.activeHivents.length; i++) {
    if (HG.activeHivents[i])
      HG.activeHivents[i].inActive();
  }
  HG.activeHivents = [];
};

