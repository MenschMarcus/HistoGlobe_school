//include HiventMarker

var HG = HG || {};

HG.hiventMarker2DCount = 0;

HG.visibleMarkers2D = [];

HG.HiventMarker2D = function(inHivent, inDisplay, inMap) {
       
  HG.HiventMarker.call(this, inHivent, inMap.getPanes()["popupPane"]);
  L.Marker.call(this, [inHivent.getHivent().lat, inHivent.getHivent().long]);
  this.addTo(inMap);
    
  var mySelf = this;
  var position = new L.Point(0,0);
  updatePosition();
 
  var radius = 40;


  this.onMouseOver = function (e) {
    var pos ={ 
								x : position.x,
								y : position.y - radius
							};	
    mySelf.getHiventHandle().mark(mySelf, pos);
    mySelf.getHiventHandle().linkAll(pos);
  };
  
  this.onMouseOut = function (e) {
    var pos ={ 
								x : position.x,
								y : position.y - radius
							};
    mySelf.getHiventHandle().unMark(mySelf, pos);
    mySelf.getHiventHandle().unLinkAll(pos);
  };
  
  this.onclick = function (e) {
    var pos ={ 
								x : position.x,
								y : position.y - radius
							};
    mySelf.getHiventHandle().toggleActive(mySelf, pos);
  };
  
  this.on("mouseover", mySelf.onMouseOver);
	this.on("mouseout", mySelf.onMouseOut);
	this.on("click", mySelf.onclick);
	inMap.on("zoomend", updatePosition);
	inMap.on("dragend", updatePosition);
	inMap.on("viewreset", updatePosition);
	inMap.on("zoomstart", this.hideHiventInfo);
    
  HG.visibleMarkers2D.push(this);

  function updatePosition() {	
		position = inMap.latLngToLayerPoint(mySelf.getLatLng());
  }
 
  this.getHiventHandle().onMark(mySelf, function(mousePos){
//    div.style.backgroundColor = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnMark(mySelf, function(mousePos){
//    div.style.backgroundColor = hiventDefaultColor;
  });
  
  this.getHiventHandle().onLink(mySelf, function(mousePos){
//    div.style.backgroundColor = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnLink(mySelf, function(mousePos){
//    div.style.backgroundColor = hiventDefaultColor;
  });
  
  this.getHiventHandle().onFocus(mySelf, function(mousePos) {
		if (inDisplay.isRunning()) {
			inDisplay.focus(mySelf.getHiventHandle().getHivent());
		}
  });
  
  this.getHiventHandle().onDestruction(mySelf, destroy);
  
  this.enableShowName();
  this.enableShowInfo();
  
//  this.hide = function() {
//    div.style.display = "none";
//  }
// 
//  this.show = function() {
//    div.style.display = "block";
//  }
  
  function destroy() {
    inMap.removeLayer(mySelf);
    inMap.off("zoomend", updatePosition);
    inMap.off("dragend", updatePosition);
    inMap.off("viewreset", updatePosition);
    inMap.off("zoomstart", this.hideHiventInfo);
    mySelf = null;
    delete this;
  }
  
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

