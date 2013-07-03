//include HiventMarker

var HG = HG || {};

//HG.HistripMarker = function(inHistripHandle, inMap) {

//  this.create = function() {

//    var mySelf = this;
//    var histrip = inHistripHandle.getHistrip();

//    this.strokeColor = 'black';
//    this.fillColor = "#edc082"

//    for (i=0;i<histrip.coords.length;i++) {

//      var point = inMap.longLatToPixel({x: histrip.coords[i][0],
//                                        y: histrip.coords[i][1]});

//      HG.HistripMarker.prototype.add.call(this, new paper.Point(point.x, point.y));
//    }

//    closed = true;

//    inHistripHandle.onUnHover( function() {
//      mySelf.fillColor = "#edc082"
//    });

//    inHistripHandle.onHover(function(){
//       mySelf.fillColor = "#fdd092"
//    });

//  }

//  this.hover = function() {
//    inHistripHandle.hover();
//  }

//  this.unHover = function() {
//    inHistripHandle.unHover();
//  }

//  paper.Path.call(this);

//  // create the object!
//  this.create();

//  // all done!
//  return this;
//};

//HG.HistripMarker.prototype = Object.create(paper.Path.prototype);
