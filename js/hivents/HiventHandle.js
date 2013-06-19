//include Hivent.js

var HG = HG || {};

HG.activeHivents = [];

HG.HiventHandle = function(inHivent) {
  
  var activated = false;
  var marked = false;
  var linked = false;
  var focussed = false;
  
  var onActiveCallbacks = [];
  var onInActiveCallbacks = [];
  var onMarkCallbacks = [];
  var onUnMarkCallbacks = [];
  var onLinkCallbacks = [];
  var onUnLinkCallbacks = [];
  var onUnFocusCallbacks = [];
  var onFocusCallbacks = [];
  var onUnFocusCallbacks = [];
  
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
  
  this.markAll = function(mousePixelPosition) {
    if (!marked) {
      marked = true;
      for (var i=0; i < onMarkCallbacks.length; i++) {
				for (var j=0; j < onMarkCallbacks[i][1].length; j++) {
					onMarkCallbacks[i][1][j](mousePixelPosition); 
				}
			}
    } 
  } 
  
  this.mark = function(obj, mousePixelPosition) {
    if (!marked) {
      marked = true;
      for (var i = 0; i < onMarkCallbacks.length; i++) {
				if (onMarkCallbacks[i][0] == obj) {
					for (var j = 0; j < onMarkCallbacks[i][1].length; j++) {
						onMarkCallbacks[i][1][j](mousePixelPosition);
					}
					break;
				} 
			}
    } 
  } 
  
  this.unMark = function(mousePixelPosition) {
    if (marked) {
      marked = false;
      for (var i=0; i < onUnMarkCallbacks.length; i++)
        onUnMarkCallbacks[i](mousePixelPosition); 
    } 
  } 

  this.linkAll = function(mousePixelPosition) {
    if (!linked) {
      linked = true;
      for (var i=0; i < onLinkCallbacks.length; i++) {
				for (var j=0; j < onLinkCallbacks[i][1].length; j++) {
					onLinkCallbacks[i][1][j](mousePixelPosition); 
				}
			}
    } 
  } 

  this.link = function(obj, mousePixelPosition) {
    if (!linked) {
      linked = true;
      for (var i = 0; i < onLinkCallbacks.length; i++) {
				if (onLinkCallbacks[i][0] == obj) {
					for (var j = 0; j < onLinkCallbacks[i][1].length; j++) {
						onLinkCallbacks[i][1][j](mousePixelPosition);
					}
					break;
				} 
			}
    } 
  } 
  
  this.unLink = function(mousePixelPosition) {
    if (linked) {
      linked = false;
      for (var i=0; i < onUnLinkCallbacks.length; i++)
        onUnLinkCallbacks[i](mousePixelPosition); 
    } 
  } 
 
  this.focus = function(mousePixelPosition) {
    focussed = true;
    
    for (var i=0; i < onFocusCallbacks.length; i++)
      onFocusCallbacks[i](mousePixelPosition); 
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
      
  this.onMark = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
			for (var i=0; i < onMarkCallbacks.length; i++) {
				if (onMarkCallbacks[i][0] == obj) {
					onMarkCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onMarkCallbacks.push([obj, [callbackFunc]]);
    }
  }
    
  this.onUnMark = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onUnMarkCallbacks.push(callbackFunc);
    }
  }

  this.onLink = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
			for (var i=0; i < onLinkCallbacks.length; i++) {
				if (onLinkCallbacks[i][0] == obj) {
					onLinkCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onLinkCallbacks.push([obj, [callbackFunc]]);
    }
  }
    
  this.onUnLink = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      onUnLinkCallbacks.push(callbackFunc);
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

