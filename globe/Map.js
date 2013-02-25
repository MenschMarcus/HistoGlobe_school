var HG = HG || {};

HG.Map = function() {

  var height = 512;
  var width = height*2;
  var canvas;
  var islands = new Array();
  
  function init() {    
    canvas = document.createElement("canvas");
    canvas.height = height;
    canvas.width = width;
    
    paper.setup(canvas);
    
    var rect = new paper.Path.Rectangle([0, 0], [width, height]);
    rect.fillColor = 'white';
    
    var lineCount = 9.0;
    for (var i = 0; i < lineCount; ++i) {
        var path = new paper.Path();
        path.strokeColor = "#BBB";
        var start = new paper.Point(0, i * height/lineCount);
        path.moveTo(start);
        path.lineTo(start.add([ width, 0 ]));
    }
    
    lineCount *= 2.0;
    for (var i = 0; i < lineCount; ++i) {
        var path = new paper.Path();
        path.strokeColor = "#BBB";
        var start = new paper.Point(i * width/lineCount, 0);
        path.moveTo(start);
        path.lineTo(start.add([ 0, height ]));
    }
      
    var islandCount = 10.0;
   
    for (var i = 0; i < islandCount; ++i) {
        var path = new paper.Path.Circle(paper.Point.random().multiply([width, height]), 500.0/islandCount);
        path.fillColor = "#555";
        islands[i] = path;
    }

  }
  
  this.getCanvas = function() {
    return canvas;
  }
  
  this.redraw = function() {
    
    var date = new Date();
    for (var i = 0; i < islands.length; ++i) {
        islands[i].translate([0, Math.sin(date.getTime()*0.01) * 10]); 
    }
    paper.view.draw();
  }

  init();
  
  return this;

};

