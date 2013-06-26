//include HiventMarker

var HG = HG || {};

HG.hiventMarker2DCount = 0;

HG.visibleMarkers2D = [];

HG.HiventMarker2D = function(inHivent, inDisplay, inMap) {
       
  HG.HiventMarker.call(this, inHivent);
  L.Marker.call(this, [inHivent.getHivent().lat, inHivent.getHivent().long]);
  this.addTo(inMap);
  
//  var hiventDefaultColor   = "#253563";
//  var hiventHighlightColor = "#ff8800";
//  
//  var div;
  var self = this;
//  var position = { x: posX,
//                   y: posY };

//  var offset = { x: offX,
//                 y: offY }; 
//  
//  var radius = 3;

//  div = document.createElement("div");
//  div.id = "hiventMarker2D_" + HG.hiventMarker2DCount;
//  div.style.position = "absolute";
//  div.style.width  = 2 * radius + "px";
//  div.style.height = 2 * radius + "px";
//  div.style.borderRadius = radius + "px";
//  div.style.backgroundColor = hiventDefaultColor;
//  setDivPos(position);

//  inParent.appendChild(div);
//  
//  div.onmouseover = function (e) {
//    var pos = getAbsPos();
//    pos.x += radius;
//    pos.y += 0.6 * radius;
//    self.getHiventHandle().mark(self, pos);
//    self.getHiventHandle().linkAll(pos);
//  };
//  
//  div.onmouseout = function (e) {
//    var pos = getAbsPos();
//    pos.x += radius;
//    pos.y += 0.6 * radius;
//    self.getHiventHandle().unMark(self, pos);
//    self.getHiventHandle().unLinkAll(pos);
//  };
//  
//  div.onclick = function (e) {
//    var pos = getAbsPos();
//    pos.x += radius;
//    pos.y += 0.6 * radius;
//    self.getHiventHandle().active(self, pos);
//  };
//  
//  HG.visibleMarkers2D.push(this);
//  
//  HG.hiventMarker2DCount++;
//  
//  function setDivPos(pos) {
//    div.style.left = pos.x +"px";
//    div.style.top = pos.y +"px";
//  }
//  
//  function getAbsPos() {
//    return {
//      x: position.x,
//      y: position.y 
//    }
//  }
 
  this.getHiventHandle().onMark(self, function(mousePos){
//    div.style.backgroundColor = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnMark(self, function(mousePos){
//    div.style.backgroundColor = hiventDefaultColor;
  });
  
  this.getHiventHandle().onLink(self, function(mousePos){
//    div.style.backgroundColor = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnLink(self, function(mousePos){
//    div.style.backgroundColor = hiventDefaultColor;
  });
  
  this.getHiventHandle().onFocus(self, function(mousePos) {
		if (inDisplay.isRunning()) {
			inDisplay.focus(self.getHiventHandle().getHivent());
		}
  });
  
//  this.enableShowName();
//  this.enableShowInfo();
//  
//  this.getPosition = function() {
//    return position;
//  }
//  
//  this.setPosition = function(pos) {
//    position = pos;
//    setDivPos(position);
//  }
//  
//  this.setOffset = function(off) {
//    offset = off;
//  }
//  
//  this.hide = function() {
//    div.style.display = "none";
//  }
// 
//  this.show = function() {
//    div.style.display = "block";
//  }
    
  
  return this;

};

HG.HiventMarker2D.prototype = Object.create(L.Marker.prototype);

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

