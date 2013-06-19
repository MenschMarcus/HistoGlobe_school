var HG = HG || {};

HG.hiventInfoCount = 0;

HG.HiventMarker = function(inHiventHandle, inParent) {

  var self = this;
  var hiventInfo;
  
  this.getHiventHandle = function() {
    return inHiventHandle;  
  }
 
  this.activeAll = function(mousePixelPosition) {
    inHiventHandle.activeAll(mousePixelPosition);
  }  
  
  this.active = function(obj, mousePixelPosition) {
    inHiventHandle.active(obj, mousePixelPosition);
  } 

  this.inActiveAll = function(mousePixelPosition) {
    inHiventHandle.inActive(mousePixelPosition);
  } 

  this.inActive = function(obj, mousePixelPosition) {
    inHiventHandle.inActive(obj, mousePixelPosition);
  } 

  this.toggleActiveAll = function(mousePixelPosition) {
    inHiventHandle.toggleActiveAll(mousePixelPosition);
  } 

  this.toggleActive = function(obj, mousePixelPosition) {
    inHiventHandle.toggleActive(obj, mousePixelPosition);
  }

  this.markAll = function(mousePixelPosition) {
    inHiventHandle.markAll(mousePixelPosition);
  } 

  this.mark = function(obj, mousePixelPosition) {
    inHiventHandle.mark(obj, mousePixelPosition);
  }  

  this.unMarkAll = function(mousePixelPosition) {
    inHiventHandle.unMarkAll(mousePixelPosition);
  }
  
  this.unMark = function(obj, mousePixelPosition) {
    inHiventHandle.unMark(obj, mousePixelPosition);
  } 

  this.linkAll = function(mousePixelPosition) {
    inHiventHandle.linkAll(mousePixelPosition);
  }  

  this.link = function(obj, mousePixelPosition) {
    inHiventHandle.link(obj, mousePixelPosition);
  }  

  this.unLinkAll = function(mousePixelPosition) {
    inHiventHandle.unLinkAll(mousePixelPosition);
  } 
  
  this.unLink = function(obj, mousePixelPosition) {
    inHiventHandle.unLink(obj, mousePixelPosition);
  } 

  this.focusAll = function(mousePixelPosition) {
    inHiventHandle.focusAll(mousePixelPosition);
  } 
 
  this.focus = function(obj, mousePixelPosition) {
    inHiventHandle.focus(obj, mousePixelPosition);
  } 

  this.unFocusAll = function(mousePixelPosition) {
    inHiventHandle.unFocusAll(mousePixelPosition);
  } 
 
  this.unFocus = function(obj, mousePixelPosition) {
    inHiventHandle.unFocus(obj, mousePixelPosition);
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
		inHiventHandle.onUnMark(self, this.hideHiventName);
	}
  
  this.enableShowInfo = function() {
		inHiventHandle.onActive(self, this.showHiventInfo);
		inHiventHandle.onInActive(self, this.hideHiventInfo);
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
    hiventInfo.style.textAlign = "justify";
    
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

