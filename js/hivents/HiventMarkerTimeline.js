//include HiventMarker

var HG = HG || {};

HG.hiventMarkerTimelineCount = 0;

HG.visibleMarkers2D = [];

HG.HiventMarkerTimeline = function(inHivent, parent, posX, posY, offX, offY) {
       
  HG.HiventMarker.call(this, inHivent)

  var hiventDefaultColor   = "#253563";
  var hiventHighlightColor = "#ff8800";
  
  var div;
  var self = this;
  var position = { x: posX,
                   y: posY };

  var offset = { x: offX,
                 y: offY }; 
  
  var radius = 3;

  div = document.createElement("div");
  div.id = "hiventMarker2D_" + HG.hiventMarker2DCount;
  div.style.position = "absolute";
  div.style.width  = 2 * radius + "px";
  div.style.height = 2 * radius + "px";
  div.style.borderRadius = radius + "px";
  div.style.backgroundColor = hiventDefaultColor;
  setDivPos(position);
  
  parent.appendChild(div);
  
  div.onmouseover = function (e) {
    var pos = getAbsPos();
    pos.x += radius;
    pos.y += 0.6 * radius;
    self.hover(pos);
  };
  
  div.onmouseout = function (e) {
    var pos = getAbsPos();
    pos.x += radius;
    pos.y += 0.6 * radius;
    self.unHover(pos);
  };
  
  div.onclick = function (e) {
    var pos = getAbsPos();
    pos.x += radius;
    pos.y += 0.6 * radius;
    self.active(pos);
  };
  
  HG.visibleMarkers2D.push(this);
  
  HG.hiventMarkerTimelineCount++;
  
  function setDivPos(pos) {
    div.style.left = pos.x +"px";
    div.style.top = pos.y +"px";
  }
  
  function getAbsPos() {
    return {
      x: position.x + offset.x,
      y: position.y + offset.y
    }
  }
  
  this.onHover(function(mousePos){
    div.style.backgroundColor = hiventHighlightColor;
  });
  
  this.onUnHover(function(mousePos){
    div.style.backgroundColor = hiventDefaultColor;
  });

  this.getPosition = function() {
    return position;
  }
  
  this.setPosition = function(pos) {
    position = pos;
    setDivPos(position);
  }
  
  this.setOffset = function(off) {
    offset = off;
  }
  
  this.hide = function() {
    div.style.display = "none";
  }
 
  this.show = function() {
    div.style.display = "block";
  }
    
  
  return this;

};

HG.hideAllVisibleMarkers2D = function() {
  for (var i = 0; i < HG.visibleMarkers2D.length; i++) {
    if (HG.visibleMarkers2D[i])
      HG.visibleMarkers2D[i].hide();
  }
};

HG.showAllVisibleMarkers2D = function() {
  for (var i = 0; i < HG.visibleMarkers2D.length; i++) {
    if (HG.visibleMarkers2D[i])
      HG.visibleMarkers2D[i].show();
  }
};

