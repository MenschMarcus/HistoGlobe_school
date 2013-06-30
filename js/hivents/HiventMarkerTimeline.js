//include HiventMarker

var HG = HG || {};

HG.hiventMarkerTimelineCount = 0;

HG.visibleMarkers2D = [];

HG.HiventMarkerTimeline = function(inHivent, inParent, inPosX, inPosY) {
       
  HG.HiventMarker.call(this, inHivent, inParent)

  var hiventDefaultColor   = "#253563";
  var hiventHighlightColor = "#ff8800";
  
  var mySelf = this;
  var myDiv;
  
	var	position = { x: inPosX, 
									 y: Math.floor($(inParent.parentNode).innerHeight() * 0.85)};
  var radius = 4;

  myDiv = document.createElement("myDiv");
  myDiv.id = "hiventMarkerTimeline_" + HG.hiventMarker2DCount;
  myDiv.style.position = "absolute";
  myDiv.style.width  = 2 * radius + "px";
  myDiv.style.height = 2 * radius + "px";
  myDiv.style.borderRadius = radius + "px";
  myDiv.style.backgroundColor = hiventDefaultColor;

	myDiv.style.left = position.x +"px";
  myDiv.style.top = position.y +"px";
  
  inParent.appendChild(myDiv);
  
  myDiv.onmouseover = function (e) {
    var pos = {
			x : position.x + radius,
      y : position.y + 0.6 * radius
    };
    mySelf.getHiventHandle().mark(mySelf, pos);
    mySelf.getHiventHandle().linkAll(pos);
  };
  
  myDiv.onmouseout = function (e) {
    var pos = {
			x : position.x + radius,
      y : position.y + 0.6 * radius
    };
    mySelf.getHiventHandle().unMark(mySelf, pos);
    mySelf.getHiventHandle().unLinkAll(pos);
    mySelf.getHiventHandle().destroyAll();
  };
  
  myDiv.onclick = function (e) {
    var pos = {
			x : position.x + radius,
      y : position.y + 0.6 * radius
    };
    mySelf.getHiventHandle().focusAll(pos);
  };
    
  HG.hiventMarkerTimelineCount++;
  
  function setDivPos(pos) {
    myDiv.style.left = pos.x +"px";
    myDiv.style.top = pos.y +"px";
  }
  
  this.getHiventHandle().onMark(mySelf, function(mousePos){
    myDiv.style.backgroundColor = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnMark(mySelf, function(mousePos){
    myDiv.style.backgroundColor = hiventDefaultColor;
  });

  this.getHiventHandle().onLink(mySelf, function(mousePos){
    myDiv.style.backgroundColor = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnLink(mySelf, function(mousePos){
    myDiv.style.backgroundColor = hiventDefaultColor;
  });

  this.getHiventHandle().onDestruction(mySelf, destroy);

  this.enableShowName();

  this.getPosition = function() {
    return position;
  }
  
  this.setPosition = function(posX) {
    position.x = posX;
    myDiv.style.left = position.x +"px";
  }
    
  this.hide = function() {
    myDiv.style.display = "none";
  }
 
  this.show = function() {
    myDiv.style.display = "block";
  }
  
  function destroy() {
    $(myDiv).remove();
    mySelf = null;
    delete this;
  }
    
  return this;

};


