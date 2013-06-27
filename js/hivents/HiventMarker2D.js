//include HiventMarker

var HG = HG || {};

HG.hiventMarker2DCount = 0;

HG.visibleMarkers2D = [];

HG.HiventMarker2D = function(inHivent, inDisplay, inMap) {
       
  HG.HiventMarker.call(this, inHivent, inMap.getPanes()["popupPane"]);
  L.Marker.call(this, [inHivent.getHivent().lat, inHivent.getHivent().long]);
  this.addTo(inMap);
  
//  var hiventDefaultColor   = "#253563";
//  var hiventHighlightColor = "#ff8800";
  
  var self = this;
  var position = new L.Point(0,0);
  updatePosition();
 
  var radius = 20;


  this.onMouseOver = function (e) {
    var pos ={ 
								x : position.x,
								y : position.y - radius
							};	
    self.getHiventHandle().mark(self, pos);
    self.getHiventHandle().linkAll(pos);
  };
  
  this.onMouseOut = function (e) {
    var pos ={ 
								x : position.x,
								y : position.y - radius
							};
    self.getHiventHandle().unMark(self, pos);
    self.getHiventHandle().unLinkAll(pos);
  };
  
  this.onclick = function (e) {
    var pos ={ 
								x : position.x,
								y : position.y - radius
							};
    self.getHiventHandle().active(self, pos);
  };
  
  this.on("mouseover", self.onMouseOver);
	this.on("mouseout", self.onMouseOut);
	this.on("click", self.onclick);
	inMap.on("zoomend", updatePosition);
	inMap.on("dragend", updatePosition);
	inMap.on("viewreset", updatePosition);
	inMap.on("zoomstart", this.hideHiventInfo);
    
  HG.visibleMarkers2D.push(this);

  function updatePosition() {	
		//position = inMap.latLngToLayerPoint([inHivent.getHivent().lat, inHivent.getHivent().long]);
		position = inMap.latLngToLayerPoint(self.getLatLng());
  }
 
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
  
  this.enableShowName();
  this.enableShowInfo();
  
//  
//  this.getPosition = function() {
//    return position;
//  }
//  
//  this.setPosition = function(pos) {
//    position = pos;
//    setDivPos(position);
//  }

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

//HG.hideAllVisibleMarkers2D = function() {
  //for (var i = 0; i < HG.visibleMarkers2D.length; i++) {
    //if (HG.visibleMarkers2D[i])
      //HG.visibleMarkers2D[i].hide();
  //}
//};

//HG.showAllVisibleMarkers2D = function() {
  //for (var i = 0; i < HG.visibleMarkers2D.length; i++) {
    //if (HG.visibleMarkers2D[i])
      //HG.visibleMarkers2D[i].show();
  //}
//};

