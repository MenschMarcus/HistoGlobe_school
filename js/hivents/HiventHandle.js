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
 
  this.activeAll = function(mousePixelPosition) {
    activated = true;
    HG.activeHivents.push(this);
    for (var i = 0; i < onActiveCallbacks.length; i++) {
			for (var j = 0; j < onActiveCallbacks[i][1].length; j++) {
				onActiveCallbacks[i][1][j](mousePixelPosition);
			}
		}
  } 
  
  this.active = function(obj, mousePixelPosition) {
    activated = true;
    HG.activeHivents.push(this);
    for (var i = 0; i < onActiveCallbacks.length; i++) {
			if (onActiveCallbacks[i][0] == obj) {
				for (var j = 0; j < onActiveCallbacks[i][1].length; j++) {
					onActiveCallbacks[i][1][j](mousePixelPosition);
				}
				break;
			} 
		}
  } 

  this.inActiveAll = function(mousePixelPosition) {
    activated = false;
    var index = $.inArray(this, HG.activeHivents);
    if (index >= 0)
      delete HG.activeHivents[index];
    for (var i = 0; i < onInActiveCallbacks.length; i++) {
			for (var j = 0; j < onInActiveCallbacks[i][1].length; j++) {
				onInActiveCallbacks[i][1][j](mousePixelPosition);
			}
		}
  } 

  this.inActive = function(obj, mousePixelPosition) {
    activated = false;
    var index = $.inArray(this, HG.activeHivents);
    if (index >= 0)
      delete HG.activeHivents[index];
      
    for (var i = 0; i < onInActiveCallbacks.length; i++) {
			if (onInActiveCallbacks[i][0] == obj) {
				for (var j = 0; j < onInActiveCallbacks[i][1].length; j++) {
					onInActiveCallbacks[i][1][j](mousePixelPosition);
				}
				break;
			} 
		}
  } 
  
  this.toggleActiveAll = function(mousePixelPosition) {
    activated = !activated;
    if (activated) {
      this.activeAll(mousePixelPosition);
    } else {
      this.inActiveAll(mousePixelPosition);
    }
  } 
  
  this.toggleActive = function(obj, mousePixelPosition) {
    activated = !activated;
    if (activated) {
      this.active(obj, mousePixelPosition);
    } else {
      this.inActive(obj, mousePixelPosition);
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

  this.unMarkAll = function(mousePixelPosition) {
    if (marked) {
      marked = false;
      for (var i = 0; i < onUnMarkCallbacks.length; i++) {
				for (var j = 0; j < onUnMarkCallbacks[i][1].length; j++) {
					onUnMarkCallbacks[i][1][j](mousePixelPosition);
				}
			}
    } 
  } 
  
  this.unMark = function(obj, mousePixelPosition) {
    if (marked) {
      marked = false;
      for (var i = 0; i < onUnMarkCallbacks.length; i++) {
				if (onUnMarkCallbacks[i][0] == obj) {
					for (var j = 0; j < onUnMarkCallbacks[i][1].length; j++) {
						onUnMarkCallbacks[i][1][j](mousePixelPosition);
					}
					break;
				} 
			}
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
 
  this.unLinkAll = function(obj, mousePixelPosition) {
    if (linked) {
      linked = false;
      for (var i = 0; i < onUnLinkCallbacks.length; i++) {
				for (var j = 0; j < onUnLinkCallbacks[i][1].length; j++) {
					onUnLinkCallbacks[i][1][j](mousePixelPosition);
				}
			}
    } 
  } 
  
  this.unLink = function(mousePixelPosition) {
    if (linked) {
      linked = false;
      for (var i = 0; i < onUnLinkCallbacks.length; i++) {
				if (onUnLinkCallbacks[i][0] == obj) {
					for (var j = 0; j < onUnLinkCallbacks[i][1].length; j++) {
						onUnLinkCallbacks[i][1][j](mousePixelPosition);
					}
					break;
				} 
			}
    } 
  }
   
  this.focusAll = function(mousePixelPosition) {
    focussed = true;
    
    for (var i = 0; i < onFocusCallbacks.length; i++) {
			for (var j = 0; j < onFocusCallbacks[i][1].length; j++) {
				onFocusCallbacks[i][1][j](mousePixelPosition);
			}
		}
  } 
 
  this.focus = function(obj, mousePixelPosition) {
    focussed = true;
    
    for (var i = 0; i < onFocusCallbacks.length; i++) {
			if (onFocusCallbacks[i][0] == obj) {
				for (var j = 0; j < onFocusCallbacks[i][1].length; j++) {
					onFocusCallbacks[i][1][j](mousePixelPosition);
				}
				break;
			} 
		}
  } 

  this.unFocusAll = function(mousePixelPosition) {
    focussed = false;
     
    for (var i = 0; i < onUnFocusCallbacks.length; i++) {
			for (var j = 0; j < onUnFocusCallbacks[i][1].length; j++) {
				onUnFocusCallbacks[i][1][j](mousePixelPosition);
			}
		}
  } 

  this.unFocus = function(obj, mousePixelPosition) {
    focussed = false;
     
    for (var i = 0; i < onUnFocusCallbacks.length; i++) {
			if (onUnFocusCallbacks[i][0] == obj) {
				for (var j = 0; j < onUnFocusCallbacks[i][1].length; j++) {
					onUnFocusCallbacks[i][1][j](mousePixelPosition);
				}
				break;
			} 
		}
  } 
  
   
 
  this.onActive = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      for (var i=0; i < onActiveCallbacks.length; i++) {
				if (onActiveCallbacks[i][0] == obj) {
					onActiveCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onActiveCallbacks.push([obj, [callbackFunc]]);
    }
  }
    
  this.onInActive = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      for (var i=0; i < onInActiveCallbacks.length; i++) {
				if (onInActiveCallbacks[i][0] == obj) {
					onInActiveCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onInActiveCallbacks.push([obj, [callbackFunc]]);
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
    
  this.onUnMark = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
			for (var i=0; i < onUnMarkCallbacks.length; i++) {
				if (onUnMarkCallbacks[i][0] == obj) {
					onUnMarkCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onUnMarkCallbacks.push([obj, [callbackFunc]]);
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
    
  this.onUnLink = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
			for (var i=0; i < onUnLinkCallbacks.length; i++) {
				if (onUnLinkCallbacks[i][0] == obj) {
					onUnLinkCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onUnLinkCallbacks.push([obj, [callbackFunc]]);
    }
  }

  this.onFocus = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
			for (var i=0; i < onFocusCallbacks.length; i++) {
				if (onFocusCallbacks[i][0] == obj) {
					onFocusCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onFocusCallbacks.push([obj, [callbackFunc]]);
    }
  }
    
  this.onUnFocus = function(obj, callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
			for (var i=0; i < onUnFocusCallbacks.length; i++) {
				if (onUnFocusCallbacks[i][0] == obj) {
					onUnFocusCallbacks[i][1].push(callbackFunc);
					return;
				}
			}
			onUnFocusCallbacks.push([obj, [callbackFunc]]);
    }
  }
  
  return this;
};

HG.deactivateAllHivents = function() {
	
  for (var i = 0; i < HG.activeHivents.length; i++) {
    if (HG.activeHivents[i]) {
			HG.activeHivents[i].inActiveAll({x:0, y:0});
		}
  }
  HG.activeHivents = [];
};

