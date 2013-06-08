<?php
  session_start();
  
  // define language whitelist
  $allowedLangs = array('en', 'de');
  
  if(isset($_GET['lang']) && in_array($_GET['lang'], $allowedLangs)) {
    $_SESSION['lang'] = $_GET['lang'];
  }
  if(!isset($_SESSION['lang'])) {
    $_SESSION['lang'] = 'de'; // default value
  }
  include('locale/' . $_SESSION['lang'] . '.php'); // include lang file
  
  function locale($phrase) {
    global $lang;
    
    if(array_key_exists($phrase, $lang)) {
      echo $lang[$phrase];
    } else {
      echo $phrase;
    }
  } 
?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-de" lang="de-de" dir="ltr">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <title>HistoGlobe</title>
    
    <link rel="icon" type="image/png" href="img/favicon.png">
    <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="css/bootstrap-responsive.min.css">
    <link rel="stylesheet" type="text/css" href="css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/timeline.css">
    
    <script type="text/javascript" src="js/third-party/jquery-1.9.0.min.js"></script>
    <script type="text/javascript" src="js/third-party/jquery.browser.js"></script>
    <script type="text/javascript" src="js/third-party/jquery.disable.text.select.js"></script>
    <script type="text/javascript" src="js/third-party/jquery.mousewheel.js"></script>
    <script type="text/javascript" src="js/third-party/bootstrap.min.js"></script>
    <script type="text/javascript" src="js/third-party/hammer.min.js"></script>

    <script type="text/javascript" src="js/third-party/RequestAnimationFrame.js"></script>
    <script type="text/javascript" src="js/third-party/Detector.js"></script>
    <script type="text/javascript" src="js/third-party/three.min.js"></script>
    <script type="text/javascript" src="js/third-party/Tween.js"></script>
    <script type="text/javascript" src="js/third-party/paper.js"></script>
    <script type="text/javascript" src="js/Display2D.js"></script>
    <script type="text/javascript" src="js/Display3D.js"></script>
    <script type="text/javascript" src="js/Map.js"></script>
    <script type="text/javascript" src="js/Timeline.js"></script>
    <script type="text/javascript" src="js/Hivent.js"></script>
    <script type="text/javascript" src="js/HiventHandler.js"></script>
    <script type="text/javascript" src="js/HiventMarker.js"></script>
    <script type="text/javascript" src="js/HiventMarker3D.js"></script>
    <script type="text/javascript" src="js/VideoPlayer.js"></script>
         
    <script type="text/javascript">
      var display2D, display3D, map, timeline, hiventHandler;
      var timelineInitialized = false;
      var container;
      var webGLSupported = Detector.webgl;
      var canvasSupported;
      var player;
    
      function isCanvasSupported() {
        var testCanvas = document.createElement("test-canvas");
        return ! (testCanvas.getContext && testCanvas.getContext("2d"));
      }      
    
      jQuery(document).ready(function($) {
        $(".smooth").click(function(event){    
          event.preventDefault();
          $('html,body').animate({scrollTop:$($(this).attr('href')).offset().top}, 500);
        });
                
        canvasSupported = isCanvasSupported();
        if (!canvasSupported) {
          $('#demo-link').addClass("btn disabled");
        }
        
        $('#demo-link').tooltip();
        
        map = new HG.Map();
        $('#toggle-3D').popover('toggle');
      });
      
      function loadGLHeader() {
        if (canvasSupported) {
          $('#default-header').animate({opacity: 0.0}, 1000, 'linear', 
            function() {   
              $('#default-header').css({visibility:"hidden"});
            });
          $('#gl-header').css({visibility:"visible"});
          $('#demo-link').css({visibility:"hidden"});
          $('#video-link').css({visibility:"hidden"});
          $('#back-link').css({visibility:"visible"});
          $('#logo-normal').css({visibility: "visible"}); 
          $('.banner').css({visibility: "visible"});         
                        
          $('.hero-unit').css({"background-image": "none"});
          $('.hero-unit').height(window.innerHeight * 0.8);
                        
          hiventHandler = new HG.HiventHandler();
          container = document.getElementById('container');   
          loadTimeline();           
          load2D();
          $('#toggle-3D').addClass("active");           
        }     
      }
      
      function onYouTubeIframeAPIReady() {
        player = new HG.VideoPlayer("ytplayer");
      }
        
      
      function loadVideoHeader() {
        //Load YouTube API
        var tag = document.createElement('script');
        tag.src = "https://www.youtube.com/iframe_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    
        $('#default-header').animate({opacity: 0.0}, 1000, 'linear', 
          function() {   
            $('#default-header').css({visibility:"hidden"});
          });
        $('#video-header').css({visibility:"visible"});
        $('#demo-link').css({visibility:"hidden"});
        $('#video-link').css({visibility:"hidden"});
        $('#back-link').css({visibility:"visible"});
        $('#back-link').click(function() {
          player.stopVideo();
        });
        
        $('.hero-unit').css({"background-image": "none"});
      }
      
      
      function loadDefaultHeader() {
        $('#default-header').css({visibility:"visible"});
        $('#default-header').animate({opacity: 1.0}, 1000, 'linear');
        $('#gl-header').css({visibility:"hidden"});
        $('#video-header').css({visibility:"hidden"});
        $('#demo-link').css({visibility:"visible"});
        $('#video-link').css({visibility:"visible"});
        $('#back-link').css({visibility:"hidden"}); 
        //$('#tlContainer').css({display: "none"}); 
        $('.banner').css({visibility: "hidden"}); 
        $('.hero-unit').css({"background-image": "url('img/logo_bg.jpg')",
                     "background-position": "bottom right"});
                     
        $('.hero-unit').css({height: "100%"});
        $('#logo-normal').css({visibility: "hidden"});    
        
        if (display3D && display3D.isRunning()) {
          $(display3D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
          display3D.stop();        
        }
          
        if (display2D && display2D.isRunning()) {
          $(display2D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
          display2D.stop();          
        }   
      }
      
      function load2D() {
        if (display3D && display3D.isRunning()) {
          $(display3D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
          display3D.stop();
          $('#toggle-3D').removeClass("active");
        }
          
        if (!display2D) {
          display2D = new HG.Display2D(container, map);
          $(display2D.getCanvas()).css({opacity: 0.0});
        }
        
        display2D.start();   
        $(display2D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');
        $('#toggle-2D').addClass("active");         
      }
      
      function load3D() {
        if (webGLSupported) {
          if (display2D && display2D.isRunning()){
            $(display2D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear'); 
            display2D.stop();
            $('#toggle-2D').removeClass("active");
          }
            
          if (!display3D) {
            display3D = new HG.Display3D(container, map, hiventHandler);
            $(display3D.getCanvas()).css({opacity: 0.0});
          }
          
          display3D.start();  
          $(display3D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');
          $('#toggle-3D').addClass("active"); 
        } else {
          $('#toggle-3D').popover("toggle");
        }        
      }
      
      function loadTimeline() {
      
        //$('#tlContainer').css({display: "block"});  

        if (!timelineInitialized) {
          timeline = timeline();
          timeline.initTimeline();
            
          $(window).mousemove(timeline.moveMouse);     
          $(window).mouseup(timeline.releaseMouse);    

          $("#tlScroller").bind("mousedown",timeline.clickMouse);
          $("#tlScroller").bind("mousewheel",timeline.zoom);
  
          // dragging the now marker
          $("#tlScroller").bind("mousemove",timeline.moveMouseOutThres);
  
          // moving the timeline scroller with left and right buttons
          $("#tlMoveLeftRight").bind("mousedown", function(evt)
            {
              if (evt.button == 0)
                timeline.clickMoveButtonLeft(0.01)
            }
          );
          $("#tlMoveLeftLeft").bind("mousedown", function(evt)
            {
              if (evt.button == 0)
                timeline.clickMoveButtonLeft(-0.01)
            }
          );
          $("#tlMoveRightRight").bind("mousedown", function(evt)
            {
              if (evt.button == 0)
                timeline.clickMoveButtonRight(-0.01)
            }
          );
          $("#tlMoveRightLeft").bind("mousedown",  function(evt)
            {
              if (evt.button == 0)
                timeline.clickMoveButtonRight(0.01)
            }
          );
          
          // play history
          $('#histPlayer1').click(timeline.togglePlayer);
          $('#histPlayer2').click(timeline.togglePlayer);
          $('#histPlayer3').click(timeline.togglePlayer);
          
          // disable selection of years in timeline
          
          $("#tlMain").disableTextSelect();  
          $("#tlScroller").disableTextSelect();
          $("#tlPlayer").disableTextSelect();
          //$("#bigDateBox").disableTextSelect();
          
          timelineInitialized = true;
        }
        
                    
      }
      
    </script>

  </head>
  <body data-spy="scroll" data-target="#mainNavigation" data-offset="20">
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand active smooth" href="#home">
            <img src="img/logo_small.svg" alt="HistoGlobe">
          </a> 
          <div class="nav-collapse collapse" id="mainNavigation">
            <ul class="nav">
              <li class=""><a class="smooth" href="#home"><i class="<?php locale("iconHome")?>"></i> <?php locale("buttonHome")?></a></li>
              <li class=""><a class="smooth" href="#details"><i class="<?php locale("iconDetails")?>"></i> <?php locale("buttonDetails")?></a></li>
              <li class=""><a class="smooth" href="#about"><i class="<?php locale("iconAbout")?>"></i> <?php locale("buttonAbout")?></a></li>
              <li class=""><a class="smooth" href="#contact"><i class="<?php locale("iconContact")?>"></i> <?php locale("buttonContact")?></a></li>
            </ul>
          </div>
          <!--<div class="nav-collapse collapse">
            <ul class="nav pull-right">
              <li class="dropdown" id="fat-menu">
                <a data-toggle="dropdown" class="dropdown-toggle" role="button" id="language-drop" href="#"><i class="icon-comment-alt"></i> Language <b class="caret"></b></a>
                <ul aria-labelledby="language-drop" role="menu" class="dropdown-menu">
                  <li class=""><a href="?lang=de">Deutsch</a></li>
                  <li class=""><a href="?lang=en">English</a></li>
                </ul>
              </li>
            </ul>
          </div>-->
        </div>
      </div>
    </div>

    <div class="container" id="home">
    
      <div class="hero-unit">       
        <div id="container"></div>
        
        <!---------------------- little logo -------------------------->
        <div class="bottom-left-logo" id="logo-normal" style="visibility:hidden"></div>
        
        <!----------------------- gl header --------------------------->
        <div id="gl-header" style="visibility:hidden">
          
          
          <!----------------------- timeline ------------------------>
          <div id="tlContainer">
            
            <div id="tlMenuLeft"  class="gradient-timeline-menu">
              <div class="btn-toolbar header-button-bottom tlMenu">
                <div class="btn-group">
                  <a id="histPlayer1" class="btn playBtn"><i class="icon-play"></i></a>
                  <a id="histPlayer2" class="btn playBtn"><i class="icon-play"></i><i class="icon-play"></i></a>
                  <a id="histPlayer3" class="btn playBtn"><i class="icon-play"></i><i class="icon-play"></i><i class="icon-play"></i></a>
                </div>
              </div>
             </div>
  
             <div id="tlMenuRight"  class="gradient-timeline-menu">
              <div class="btn-toolbar header-button-bottom tlMenu">
                <div class="btn-group">
                  <a id="toggle-2D" class="btn" onClick="load2D()">2D</a>
                  <a id="toggle-3D" class="btn" onClick="load3D()"
                     data-html="true"
                     data-placement="left"
                     data-title="Entschuldigung!" 
                     data-content="Der 3D-Globus kann nicht angezeigt werden! Bitte aktualisieren Sie Ihren Browser oder laden Sie sich eine aktuelle Version von <a href='http://www.mozilla.org/'>Firefox</a> oder <a href='http://www.google.com/chrome/'>Chrome</a> herunter.">3D</a>
                </div>
              </div>
            </div>

            <div id="timeline"  class="gradient-timeline-main">
              <div id="tlMain">
                <div id="tlScroller">
                  <!-- all markers are in here -->
                  <div id="nowMarkerWrap">
                    <div id="nowMarkerHead">
                      <div id="nowDate" onsubmit="return false">
                        <i class="icon-angle-left"></i> <span id="polDate"></span> <i class="icon-angle-right"></i>
                      </div>
                    </div>
                    <div id="nowMarkerMain"></div>
                  </div>
                </div>
              </div>
              
              
              <div id="tlControlsLeft" class="gradient-timeline-top">
                <span class="input-prepend input-append" style="margin-bottom:0px">
                  <button id="tlMoveLeftLeft" class="btn" type="button"><i class="icon-caret-left"></i></button>
                  <input  id="periodStart" type="text" name="periodStart">
                  <button id="tlMoveLeftRight" class="btn" type="button"><i class="icon-caret-right"></i></button>
                </span>
               </div>
               <div id="tlBorderLeft"></div>
              
              
              <div id="tlControlsRight" class="gradient-timeline-top">
                <span class="input-prepend input-append" style="float:right; margin-bottom:0px">
                  <button id="tlMoveRightLeft" class="btn" type="button"><i class="icon-caret-left"></i></button>
                  <input id="periodEnd" type="text" name="periodEnd">
                  <button id="tlMoveRightRight" class="btn" type="button"><i class="icon-caret-right"></i></button>
                </span>
              </div>
              <div id="tlBorderRight"></div>
              
            </div>
          </div>
        </div>
        
        <!------------------------ video ------------------------------>
        <div id="video-header" 
           style="visibility:hidden; position:absolute; width: 100%; height: 100%;">
           
          <iframe id="ytplayer" type="text/html" width="100%" height="100%"
            src="http://www.youtube.com/embed/pbEm_v7p0kw?modestbranding=1&showinfo=0&autohide=1&color=white&theme=light&wmode=transparent&rel=0"
            frameborder="0" yt:quality=high allowfullscreen>
          </iframe>
          
          <!-- <div id = "ytplayer"></div> -->
        </div>
        
        <div class="banner" style="visibility:hidden"></div>
        
        <!------------------- Video / Prototype buttons -----------------------> 
        <p class="header-button-top">
          <a id="demo-link"  
             data-placement="bottom" 
             data-original-title="Warnung! Die Demo benötigt einen sehr aktuellen Browser." 
             onClick="loadGLHeader()"
             style="margin:10px">
            <small><i class="icon-play"></i> Prototyp</small>
          </a>
          
          <a id="video-link"  
            onClick="loadVideoHeader()"
            style="margin:10px">
            <small><i class="icon-play"></i> Video</small>
          </a>
        </p>
        
        <a id="back-link" class="header-button-top" 
           style="visibility:hidden"
           onClick="loadDefaultHeader()"
           style="margin:10px">
          <small><i class="icon-step-backward"></i> Zurück</small>
        </a>
        
        <!-- default header -->
        <div id="default-header">
          <center>
            <img src="img/logo_big.png" alt="logo">
          </center>
        </div>
      </div>
          
      <div class="info-box">
        <div class="row">
          <p><i class="icon-warning-sign pull-left" style="font-size:200%; padding-top:5px"></i>  <?php locale("not_ready")?></p>
        </div>
      </div>
     <!--
     <div class="alert alert-histoglobe">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <i class="icon-warning-sign pull-left" style="font-size:200%"></i><?php locale("not_ready")?>
    </div>
     -->
     
      <div class="row">
        <div class="span12">
          <div class="gradient-down summary">
            <img src="img/browser.png" id="browser-img" class="img-right pull-right" alt="HistoGlobe im Browser">
            <h3><?php locale("summary_head")?></h3>
            <p><?php locale("summary")?> <p>
            <a class="smooth" href="#details"><?php locale("readMore")?></a>
          </div>
        </div>
      </div> 
      
<!--
      <div class="row">
        <div class="span4">
          <div class="gradient-down summary">
            <h3 style="text-align:center"><i class="<?php locale("icon_1")?> icon-summary"></i> <br> <?php locale("feature_1")?></h3>
            <p><?php locale("summary")?> <p>
            <a class="smooth" href="#details"><?php locale("readMore")?></a>
          </div>
        </div>
        
        <div class="span4">
          <div class="gradient-down summary">
            <h3 style="text-align:center"><i class="<?php locale("icon_2")?> icon-summary"></i> <br> <?php locale("feature_2")?></h3>
            <p><?php locale("summary")?> <p>
            <a class="smooth" href="#details2"><?php locale("readMore")?></a>
          </div>
        </div>
        
        <div class="span4">
          <div class="gradient-down summary">
            <h3 style="text-align:center"><i class="<?php locale("icon_3")?> icon-summary"></i> <br> <?php locale("feature_3")?></h3>
            <p><?php locale("summary")?> <p>
            <a class="smooth" href="#details3"><?php locale("readMore")?></a>
          </div>
        </div>
      </div>
    </div>
-->
    <div class="container" id="details">
      <div class="details gradient-up">
          <i class="<?php locale("icon_1")?> pull-left icon-feature"></i> 
          <h2><?php locale("feature_1")?><br><span class="muted"> <?php locale("heading_1")?></span></h2> 
          <p><?php locale("explanation_1")?> <br>

        <hr id="details2">

          <i class="<?php locale("icon_2")?> pull-right icon-feature"></i> 
          <h2><?php locale("feature_2")?><br><span class="muted"> <?php locale("heading_2")?></span></h2> 
           <p><?php locale("explanation_2")?> <br>

        <hr id="details3">

          <i class="<?php locale("icon_3")?> pull-left icon-feature"></i> 
          <h2><?php locale("feature_3")?><br><span class="muted"> <?php locale("heading_3")?></span></h2> 
           <p><?php locale("explanation_3")?> <br>
        
      </div>
    </div>

     <div class="container" id="about"> 
      <div class="row" >
        <div class="span12">
          <div class="details gradient-down">
            <h4><i class="<?php locale("iconAbout")?>"></i> <?php locale("buttonAbout")?></h4>
            <?php locale("about")?>
          </div>
        </div> 
      </div> 

    </div>
    
    <div class="container" id="group"> 
      <div class="row" >
        <div class="span12">
          <div class="details group-image">
          </div>
        </div> 
      </div> 

    </div>
      
    <div class="container" id="contact"> 
      <div class="row" >
        <div class="span6">
          <div class="details muted">
            <h4><i class="<?php locale("iconContact")?>"></i> <?php locale("buttonContact")?></h4>
            <small><?php locale("contact")?></small>
          </div> 
        </div> 
        <div class="span6">
          <div class="details muted">
            <h4><i class="<?php locale("iconImpressum")?>"></i> <?php locale("buttonImpressum")?></h4>
            <small><?php locale("impressum")?></small>
          </div> 
        </div> 
      </div> 

    </div>
  </body>
</html>
