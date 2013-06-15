var HG = HG || {};

HG.hiventInfoCount = 0;

HG.HiventMarker = function(inHiventHandle) {

  var hiventInfo;
  
  this.getHiventHandle = function() {
    return inHiventHandle;  
  }
  
  this.active = function(mousePixelPosition) {
    inHiventHandle.active(mousePixelPosition);
    this.focus(mousePixelPosition);
  } 

  this.inActive = function(mousePixelPosition) {
    inHiventHandle.inActive(mousePixelPosition);
  } 

  this.toggleActive = function(mousePixelPosition) {
    inHiventHandle.toggleActive(mousePixelPosition);
  } 
  
  this.hover = function(mousePixelPosition) {
    inHiventHandle.hover(mousePixelPosition);
  } 
  
  this.unHover = function(mousePixelPosition) {
    inHiventHandle.unHover(mousePixelPosition);
  } 
  
  this.focus = function(mousePixelPosition) {
    inHiventHandle.focus(mousePixelPosition);
  } 
  
  this.unFocus = function(mousePixelPosition) {
    inHiventHandle.unFocus(mousePixelPosition);
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
  
  inHiventHandle.onHover(this.showHiventName);
  inHiventHandle.onUnHover(this.hideHiventName);
  inHiventHandle.onActive(this.showHiventInfo);
  inHiventHandle.onInActive(this.hideHiventInfo);
  
  function init() {
    hiventInfo = document.createElement("div");
    hiventInfo.class = "btn";
    hiventInfo.id = "hiventInfo_" + HG.hiventInfoCount;
    hiventInfo.style.position = "absolute";
    hiventInfo.style.left = "0px";
    hiventInfo.style.top = "0px";
    hiventInfo.style.visibility = "hidden";
    hiventInfo.style.pointerEvents = "none";
    
    document.getElementsByTagName("body")[0].appendChild(hiventInfo);
    
    var hivent = inHiventHandle.getHivent();
    
    $(hiventInfo).tooltip({title: hivent.name, placement: "top"});
    
    var hiventContent = "<p align=\"right\">" + hivent.date + "</p>" + hivent.description;
    
    $(hiventInfo).popover({title: hivent.name, placement: "top", html: "true", content: hiventContent});
    
    HG.hiventInfoCount++;
  }
  
  init();
  
  return this;
  
};

