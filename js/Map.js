var HG = HG || {};

HG.Map = function() {
  
  var time;
  
  var height = 1024;
  var width = height*2;
  var canvas;
  var text;
  var coastlines;
  
  function init() {    
    canvas = document.createElement("canvas");
    canvas.height = height;
    canvas.width = width;
    
    paper.setup(canvas);
    
    var backRect = paper.Path.Rectangle(new paper.Rectangle(
                                        new paper.Point(0, 0), 
                                        new paper.Point(canvas.width, canvas.height)));
    backRect.fillColor = "white";
    
    /*
    $.getJSON("img/coastline.json", function(c){
      coastlines = c;  

      var cl,line;
      for (cl=0; cl<coastlines.length; cl++) {
        line = coastlines[cl];
        var path = new paper.Path();
        path.strokeColor = 'black';
        path.fillColor = "#edc082"
        for (i=0;i<line.length-1;i++) {
          var x1 = (line[i][0] + 180)/360 * canvas.width;
          var y1 = canvas.height - (line[i][1] + 90)/180 * canvas.height;
          var x2 = (line[i+1][0] + 180)/360 * canvas.width;
          var y2 = canvas.height - (line[i+1][1] + 90)/180 * canvas.height;
          path.add(new paper.Point(x1, y1), new paper.Point(x2, y2));
        }
        path.closed = true;
      }
    });  
    */
    
    
    imgResource = document.createElement("img");
    imgResource.setAttribute("id", "map-image");
    imgResource.setAttribute("src", "img/map.jpg");
    imgResource.setAttribute("style", "display:none");
    document.body.appendChild(imgResource);
    
    var background = new paper.Raster('map-image');
    background.position = new paper.Point(width/2, height/2);
    /*
    text = new paper.PointText(new paper.Point(width/2, height/2));
    text.content = 'HistoGlobe';
    text.characterStyle = {
      fontSize: 50,
      font: 'roman_caps',
      fillColor: 'black',
    };
    */  
    
    $.getJSON("data/hivents.json", function(hivents){
      for (var hivent=0; hivent<hivents.length; hivent++) {
        var x = (hivents[hivent].long + 180)/360 * canvas.width;
        var y = canvas.height - (hivents[hivent].lat + 90)/180 * canvas.height;
        var point = new paper.Path.Circle(new paper.Point(x, y), 2);
        point.fillColor = "#e79523";
      }
    }); 
    
    hiventHandler = new HG.HiventHandler();
    hivents = hiventHandler.getAllHivents();
    
    for (var hivent=0; hivent<hivents.length; hivent++) {
      var x = (hivents[hivent].long + 180)/360 * canvas.width;
      var y = canvas.height - (hivents[hivent].lat + 90)/180 * canvas.height;
      var point = new paper.Path.Circle(new paper.Point(x, y), 2);
      point.fillColor = "#e79523";
    }
        
    
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

    //text.rotate(frameTime*0.02);
    //paper.view.draw();
    
  }

  init();
  
  return this;

};

