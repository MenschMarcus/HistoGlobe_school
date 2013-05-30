var HG = HG || {};

HG.hiventCount = 0;

HG.activeHivents = [];

HG.HiventMarker = function(inHivent) {

  var hivent = inHivent;
  var hiventInfo;
  
  var hovered = false;
  var activated = false;
  
  var onActiveCallbacks = [];
  var onInActiveCallbacks = [];
  var onHoverCallbacks = [];
  var onUnHoverCallbacks = [];
    
  this.getHivent = function() {
    return hivent;  
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
  
  this.showHiventName = function(displayPosition) {
    hiventInfo.style.left = displayPosition.x + "px";
    hiventInfo.style.top = displayPosition.y + "px";
    $(hiventInfo).tooltip("show");
  }
  
  this.hideHiventName = function(displayPosition) {
    $(hiventInfo).tooltip("hide");
  }
  
  this.showHiventInfo = function(displayPosition) {
    hiventInfo.style.left = displayPosition.x + "px";
    hiventInfo.style.top = displayPosition.y + "px";
    $(hiventInfo).popover("show");
    $(hiventInfo).tooltip("hide");
  }
  
  this.hideHiventInfo = function(displayPosition) {
    $(hiventInfo).popover("hide");
  }
  
  this.onHover(this.showHiventName);
  this.onUnHover(this.hideHiventName);
  this.onActive(this.showHiventInfo);
  this.onInActive(this.hideHiventInfo);
  
  function init() {
    hiventInfo = document.createElement("div");
    hiventInfo.class = "btn";
    hiventInfo.id = "hiventInfo" + HG.hiventCount;
    hiventInfo.style.position = "absolute";
    hiventInfo.style.left = "0px";
    hiventInfo.style.top = "0px";
    hiventInfo.style.visibility = "hidden";
    hiventInfo.style.pointerEvents = "none";
    
    document.getElementsByTagName("body")[0].appendChild(hiventInfo);
    
    $(hiventInfo).tooltip({title: hivent.name, placement: "top"});
    $(hiventInfo).popover({title: hivent.name, placement: "top"});
    
    HG.hiventCount++;
  }
  
  init();
  
  return this;
  
};

HG.deactivateAllHivents = function() {
  for (var i = 0; i < HG.activeHivents.length; i++) {
    if (HG.activeHivents[i])
      HG.activeHivents[i].inActive();
  }
  HG.activeHivents = [];
};
