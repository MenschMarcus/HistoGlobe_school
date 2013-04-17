var HG = HG || {};

HG.Map = function() {
  
  
  var time;
  
  var height = 512;
  var width = height*2;
  var canvas;
  var text;
  
  function init() {    
    canvas = document.createElement("canvas");
    canvas.height = height;
    canvas.width = width;
    
    paper.setup(canvas);
    
    imgResource = document.createElement("img");
    imgResource.setAttribute("id", "map-image");
    imgResource.setAttribute("src", "img/map.jpg");
    imgResource.setAttribute("style", "display:none");
    document.body.appendChild(imgResource);
    
    var background = new paper.Raster('map-image');
    background.position = new paper.Point(width/2, height/2);
      
    text = new paper.PointText(background.position);
    text.content = 'HistoGlobe';
    text.characterStyle = {
        fontSize: 50,
        font: 'roman_caps',
        fillColor: 'black',
    };
    
    var date = new Date();
    time = date.getTime()
    
    paper.view.draw();
  }
  
  this.getCanvas = function() {
    return canvas;
  }
  
  this.redraw = function() {
    
    var currTime = new Date().getTime();
    var frameTime = currTime - time;
    time = currTime;
    
    //Math.sin(date.getTime()*0.01) * 10]
    text.rotate(frameTime*0.02);
   
  }

  init();
  
  return this;

};

