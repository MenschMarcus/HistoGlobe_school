var HG = HG || {};

HG.Map = function() {

  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// STATIC CONSTANTS /////////////////////////////////

  HG.Map.HEIGTH = 1024;
  HG.Map.WIDTH = 2048;

  ////////////////////////////// FUNCTIONS /////////////////////////////////////

  // ===========================================================================
  this.create = function() {
    canvas = document.createElement("canvas");
    canvas.height = HG.Map.HEIGTH;
    canvas.width = HG.Map.WIDTH;

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
    background.position = new paper.Point(HG.Map.WIDTH/2, HG.Map.HEIGTH/2);
    /*
    text = new paper.PointText(new paper.Point(HG.Map.WIDTH/2, HG.Map.HEIGTH/2));
    text.content = 'HistoGlobe';
    text.characterStyle = {
      fontSize: 50,
      font: 'roman_caps',
      fillColor: 'black',
    };
    */

    var date = new Date();

    time = date.getTime()

    paper.view.draw();

  }

  // ===========================================================================
  this.getCanvas = function() {
    return canvas;
  }

  // ===========================================================================
  this.getResolution = function() {
    return {x:HG.Map.WIDTH, y:HG.Map.HEIGTH};
  }

  // ===========================================================================
  this.redraw = function() {

    var currTime = new Date().getTime();
    var frameTime = currTime - time;
    time = currTime;


    //Math.sin(date.getTime()*0.01) * 10]

    //text.rotate(frameTime*0.02);
    //paper.view.draw();
  }

  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// MEMBER VARIABLES /////////////////////////////////

  var time;

  var canvas;
  var text;
  var coastlines;

  // create the object!
  this.create();

  // all done!
  return this;

};

