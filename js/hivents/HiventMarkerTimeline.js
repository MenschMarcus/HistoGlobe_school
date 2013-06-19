//include HiventMarker

var HG = HG || {};

HG.hiventMarkerTimelineCount = 0;

HG.visibleMarkers2D = [];

HG.HiventMarkerTimeline = function(inHivent, inParent, inPosX, inPosY) {
       
  HG.HiventMarker.call(this, inHivent, inParent)

  var hiventDefaultColor   = "#253563";
  var hiventHighlightColor = "#ff8800";
  
  var self = this;
  var div;
  
	var	position = { x: inPosX, 
									 y: Math.floor($(inParent.parentNode).innerHeight() * 0.85)};
  var radius = 4;

  div = document.createElement("div");
  div.id = "hiventMarkerTimeline_" + HG.hiventMarker2DCount;
  div.style.position = "absolute";
  div.style.width  = 2 * radius + "px";
  div.style.height = 2 * radius + "px";
  div.style.borderRadius = radius + "px";
  div.style.backgroundColor = hiventDefaultColor;

	div.style.left = position.x +"px";
  div.style.top = position.y +"px";
  
  inParent.appendChild(div);
  
  div.onmouseover = function (e) {
    var pos = {
			x : position.x + radius,
      y : position.y + 0.6 * radius
    };
    self.getHiventHandle().mark(self, pos);
    self.getHiventHandle().linkAll(pos);
  };
  
  div.onmouseout = function (e) {
    var pos = {
			x : position.x + radius,
      y : position.y + 0.6 * radius
    };
    self.getHiventHandle().unMark(pos);
    self.getHiventHandle().unLink(pos);
  };
  
  div.onclick = function (e) {
    var pos = {
			x : position.x + radius,
      y : position.y + 0.6 * radius
    };
    self.getHiventHandle().focus(pos);
  };
    
  HG.hiventMarkerTimelineCount++;
  
  function setDivPos(pos) {
    div.style.left = pos.x +"px";
    div.style.top = pos.y +"px";
  }
  
  this.getHiventHandle().onMark(self, function(mousePos){
    div.style.backgroundColor = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnMark(function(mousePos){
    div.style.backgroundColor = hiventDefaultColor;
  });
  
  this.enableShowName();

  this.getPosition = function() {
    return position;
  }
  
  this.setPosition = function(posX) {
    position.x = posX;
    div.style.left = position.x +"px";
  }
    
  this.hide = function() {
    div.style.display = "none";
  }
 
  this.show = function() {
    div.style.display = "block";
  }
    
  return this;

};


