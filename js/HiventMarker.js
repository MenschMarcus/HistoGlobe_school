var HG = HG || {};

HG.hiventCount = 0;

HG.HiventMarker = function(inHivent) {

  var hivent = inHivent;
  var hiventInfo;
  
  var hovered = false;
  var onHoverCallbacks = [];
  var onUnHoverCallbacks = [];
  
  this.getHivent = function() {
    return hivent;  
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
  
  this.showHiventInfo = function(displayPosition) {
    hiventInfo.style.left = displayPosition.x - 10 + "px";
    hiventInfo.style.top = displayPosition.y - 5 + "px";
    $(hiventInfo).tooltip("show");
  }
  
  this.onHover(this.showHiventInfo);
  
  this.hideHiventInfo = function(displayPosition) {
    $(hiventInfo).tooltip("hide");
  }
  
  this.onUnHover(this.hideHiventInfo);
  
  function init() {
    hiventInfo = document.createElement("button");
    hiventInfo.id = "hiventInfo" + HG.hiventCount;
    hiventInfo.style.position = "absolute";
    hiventInfo.style.left = "0px";
    hiventInfo.style.top = "0px";
    hiventInfo.style.visibility = "hidden";
    $(hiventInfo).tooltip({title: hivent.name, placement: "top"});
    
    document.getElementsByTagName("body")[0].appendChild(hiventInfo);
    
    HG.hiventCount++;
  }
  
  init();
  
  return this;
  
};
