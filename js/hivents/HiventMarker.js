var HG = HG || {};

HG.hiventInfoCount = 0;

HG.HiventMarker = function(inHiventHandle, inParent) {

  var self = this;
  var hiventInfo;
  
  this.getHiventHandle = function() {
    return inHiventHandle;  
  }
  
  this.active = function(mousePixelPosition) {
    inHiventHandle.active(mousePixelPosition);
  } 

  this.inActive = function(mousePixelPosition) {
    inHiventHandle.inActive(mousePixelPosition);
  } 

  this.toggleActive = function(mousePixelPosition) {
    inHiventHandle.toggleActive(mousePixelPosition);
  } 
  
  this.markAll = function(mousePixelPosition) {
    inHiventHandle.markAll(mousePixelPosition);
  } 

  this.mark = function(obj, mousePixelPosition) {
    inHiventHandle.mark(obj, mousePixelPosition);
  }  
  
  this.unMark = function(mousePixelPosition) {
    inHiventHandle.unMark(mousePixelPosition);
  } 
 
  this.link = function(obj, mousePixelPosition) {
    inHiventHandle.link(obj, mousePixelPosition);
  }  
  
  this.unLink = function(mousePixelPosition) {
    inHiventHandle.unLink(mousePixelPosition);
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
  
  this.enableShowName = function() {
		inHiventHandle.onMark(self, this.showHiventName);
		inHiventHandle.onUnMark(this.hideHiventName);
	}
  
  this.enableShowInfo = function() {
		inHiventHandle.onActive(this.showHiventInfo);
		inHiventHandle.onInActive(this.hideHiventInfo);
	}
  
  function init() {
    hiventInfo = document.createElement("div");
    hiventInfo.class = "btn";
    hiventInfo.id = "hiventInfo_" + HG.hiventInfoCount;
    hiventInfo.style.position = "absolute";
    hiventInfo.style.left = "0px";
    hiventInfo.style.top = "0px";
    hiventInfo.style.visibility = "hidden";
    hiventInfo.style.pointerEvents = "none";
    
    inParent.appendChild(hiventInfo);
    
    var hivent = inHiventHandle.getHivent();
    
    $(hiventInfo).tooltip({title: hivent.name, placement: "top"});
    
    var hiventContent = "<p align=\"right\">" + hivent.date + "</p>" + hivent.description;
    
    $(hiventInfo).popover({title: hivent.name, placement: "top", html: "true", content: hiventContent});
    
    HG.hiventInfoCount++;
  }
  
  init();
  
  return this;
  
};

