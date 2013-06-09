//include HiventMarker

var HG = HG || {};

HG.hiventMarker2DCount = 0;

HG.visibleMarkers2D = [];

HG.HiventMarker2D = function(inHivent, parent, posX, posY) {
       
  HG.HiventMarker.call(this, inHivent)

  var div;
  var self = this;
  var position = { x: posX,
                   y: posY };
  

  div = document.createElement("div");
  div.id = "hiventMarker2D_" + HG.hiventMarker2DCount;
  div.style.position = "absolute";
  div.style.left = position.x +"px";
  div.style.top = position.y +"px";
  div.style.width = "5px";
  div.style.height = "5px";
  div.style.backgroundColor = "#00ff00";
  div.style.zIndex = 10;
  
  //document.getElementsByTagName("body")[0].appendChild(div);

  parent.appendChild(div);
  
  div.onmouseover = function (e) {
    
    self.hover(position);
  };
  
  div.onmouseout = function (e) {
    
    self.unHover(position);
  };
  
  div.onclick = function (e) {
    
    self.active(position);
  };
  
  HG.visibleMarkers2D.push(this);
  
  HG.hiventMarker2DCount++;

  
  this.onHover(function(mousePos){

  });
  
  this.onUnHover(function(mousePos){

  });
  
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

