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
    <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap-responsive.min.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/font-awesome.min.css">
    <link rel="stylesheet" href="style/third-party/leaflet.css" />
    <link rel="stylesheet" href="style/third-party/leaflet.label.css" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.css" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.css" />
    <!--[if lte IE 8]>
      <link rel="stylesheet" href="style/third-party/leaflet.ie.css" />
      <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.ie.css" />
    <![endif]-->

    <link rel="stylesheet" type="text/css" href="style/histoglobe.min.css">

    <script type="text/javascript" src="http://d3js.org/d3.v3.min.js"></script>
    <script type="text/javascript" src="script/third-party/jquery-1.9.0.min.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.browser.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.disable.text.select.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.mousewheel.js"></script>
    <script type="text/javascript" src="script/third-party/bootstrap.min.js"></script>
    <script type="text/javascript" src="script/third-party/RequestAnimationFrame.js"></script>
    <script type="text/javascript" src="script/third-party/three.min.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.js"></script>
    <script type="text/javascript" src="script/third-party/raphael.min.js"></script>
    <script type="text/javascript" src="script/third-party/topojson.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.label.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.markercluster.js"></script>

    <!-- <script type="text/javascript" src="script/histoglobe.min.js"></script> -->

    <script type="text/javascript" src="build/Mixin.js"></script>
    <script type="text/javascript" src="build/CallbackContainer.js"></script>
    <script type="text/javascript" src="build/Vector.js"></script>
    <script type="text/javascript" src="build/Display.js"></script>
    <script type="text/javascript" src="build/Display3D.js"></script>
    <script type="text/javascript" src="build/Hivent.js"></script>
    <script type="text/javascript" src="build/Display2D.js"></script>
    <script type="text/javascript" src="build/HiventController.js"></script>
    <script type="text/javascript" src="build/HiventHandle.js"></script>
    <script type="text/javascript" src="build/HiventInfoPopover.js"></script>
    <script type="text/javascript" src="build/Area.js"></script>
    <script type="text/javascript" src="build/AreaController.js"></script>
    <script type="text/javascript" src="build/HiventMarker.js"></script>
    <script type="text/javascript" src="build/HiventMarker2D.js"></script>
    <script type="text/javascript" src="build/HiventMarker3D.js"></script>
    <script type="text/javascript" src="build/HiventMarkerTimeline.js"></script>
    <script type="text/javascript" src="build/Timeline.js"></script>
    <script type="text/javascript" src="build/YearMarker.js"></script>
    <script type="text/javascript" src="script/util/BrowserDetect.js"></script>
    <script type="text/javascript" src="build/VideoPlayer.js"></script>
    <script type="text/javascript" src="build/NowMarker.js"></script>


    <script>
	    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	    ga('create', 'UA-42176173-1', 'histoglobe.com');
	    ga('send', 'pageview');
	  </script>

    <script type="text/javascript">
      var display2D, display3D, timeline, hiventController, areaController, nowMarker;
      var timelineInitialized = false;
      var container;
      var player;

      jQuery(document).ready(function($) {
        BrowserDetect.init();
        $(".smooth").click(function(event){
          event.preventDefault();
          $('html,body').animate({scrollTop:$($(this).attr('href')).offset().top}, 500);
        });
        if (!BrowserDetect.canvasSupported) {
          $('#demo-link').addClass("btn disabled");
        }

        $('#demo-link').tooltip();

        if (!BrowserDetect.webglRenderingSupported) {
          var elem_title = 'Entschuldigung! <a class="close pull-right" style="margin-top: -3px;" onclick="$(&#39;#toggle-3D&#39;).popover(&#39;hide&#39;);">&times;</a>';
          var elem_content = '';
          if (BrowserDetect.webglContextSupported) {
            if (BrowserDetect.browser != "unknown") {
              elem_content = 'Obwohl Ihr Browser (' + BrowserDetect.browser + ') <span class="hg">HistoGlobe</span> anzeigen kann, treten auf Ihrem Rechner leider Probleme auf. Eventuell ist der Treiber Ihrer Graphikkarte nicht aktuell. Weitere Hilfe zum Thema WebGL und ' + BrowserDetect.browser + ' erhalten Sie hier: <br><br> <a target="_blank" class="btn btn-block btn-success" href ="' +
                             BrowserDetect.urls.troubleshootingUrl+ '">' + BrowserDetect.browser + ' Support</a>';
            }

          } else {
            if (BrowserDetect.browser != "unknown" && BrowserDetect.urls.upgradeUrl) {
              elem_content = 'Ihre Version von ' + BrowserDetect.browser
                              + ' ist nicht aktuell! Wenn Sie <span class="hg">HistoGlobe</span> auf einem Globus genießen wollen, aktualisieren Sie bitte Ihren Browser. <br><br><a target="_blank" class="btn btn-block btn-success" href ="'
                              + BrowserDetect.urls.upgradeUrl + '">'
                              + BrowserDetect.browser + ' aktualisieren' + '</a>';
            } else {
              elem_content = BrowserDetect.browser + ' unterstützt leider noch keine 3D-Graphiken. Wenn Sie <span class="hg">HistoGlobe</span> auf einem Globus genießen wollen, installieren Sie bitte einen der folgenden Browser: <br><br> <a target="_blank" class="btn btn-block btn-success" href ="http://www.mozilla.org/de/firefox/new/"> Firefox herunterladen </a> <a target="_blank" class="btn btn-block btn-success" href ="https://www.google.com/intl/de/chrome/browser/"> Chrome herunterladen </a>'
            }
          }

          $('#toggle-3D').popover({animation:true, title:elem_title, content:elem_content, html:true, placement:"top"});
        }

      });

      function loadGLHeader() {

        if (BrowserDetect.canvasSupported) {

          $('#default-header').animate({opacity: 0.0}, 400, 'linear',
            function() {
              $('#default-header').css({visibility:"hidden"});
            }
          );

          // scroll to top
          $('html,body').animate({scrollTop:0}, 500);

          $('#warning-close').button('loading')

          $('body').addClass("slide-out");
          $('#home').addClass("slide-out");
          $('#content').addClass("slide-out");
          $('#navbar').addClass("slide-out");
          $('.hero-unit').addClass("slide-out");

          $('.header-button-center').css({display:"none"});
          $('#gl-header').css({visibility:"visible"});
          $('#back-link').css({visibility:"visible"});
          $('#map-loader').css({visibility:"visible"});
          $('#logo-normal').css({visibility: "visible"});

          $('.hero-unit').height(window.innerHeight);


          window.setTimeout(function() {

            $('#warning').modal()

            window.setTimeout(function() {
              hiventController = new HG.HiventController("data/hivent_collection.json");

              container = document.getElementById('map-container');

              // Load Timeline and NowMarker
              loadTimeline();

              areaController = new HG.AreaController(timeline);

              load2D();

              $('#warning-close').button('reset')

            }, 500);

          }, 200);
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

        $('#default-header').animate({opacity: 0.0}, 400, 'linear',
          function() {
            $('#default-header').css({visibility:"hidden"});
          }
        );

        $('#video-header').css({display:"block"});
        $('.header-button-center').css({display:"none"});
        $('#back-link').css({visibility:"visible"});
        $('#back-link').click(function() {
          player.stopVideo();
        });
      }


      function loadDefaultHeader() {

        $('#default-header').animate({opacity: 1.0}, 400, 'linear');

        $('body').removeClass("slide-out");
        $('#home').removeClass("slide-out");
        $('#content').removeClass("slide-out");
        $('#navbar').removeClass("slide-out");
        $('.hero-unit').removeClass("slide-out");


        $('#default-header').css({visibility:"visible"});
        $('#default-header').animate({opacity: 1.0}, 1000, 'linear');
        $('#gl-header').css({visibility:"hidden"});
        $('#video-header').css({display:"none"});
        $('.header-button-center').css({display:"block"});
        $('#map-loader').css({visibility:"hidden"});
        $('#back-link').css({visibility:"hidden"});

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
          $('#toggle-3D').button("toggle");
          $('#toggle-2D').button("toggle");
        }

        if (!display2D) {
          display2D = new HG.Display2D(container, hiventController, areaController);
          $(display2D.getCanvas()).css({opacity: 0.0});
        }

        display2D.start();
        $(display2D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');
      }

      function load3D() {
        if (BrowserDetect.webglRenderingSupported) {
          if (display2D && display2D.isRunning()){
            $(display2D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
            display2D.stop();
            $('#toggle-3D').button("toggle");
            $('#toggle-2D').button("toggle");
          }

          if (!display3D) {
            display3D = new HG.Display3D(container, hiventController, areaController);
            $(display3D.getCanvas()).css({opacity: 0.0});
          }

          display3D.start();
          $(display3D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');

        }
      }

      function loadTimeline()
      {
        // new timeline
        if (!timelineInitialized)
        {
          timeline = new HG.Timeline(1850, 1700, 2010, 0.001, 1000, document.getElementById("timeline"));

        }

        if(typeof nowMarker !== "undefined" || nowMarker !== null)
        {
          nowMarker = new HG.NowMarker(document.getElementById("timeline"), document.getElementById("now_marker"));
        }


        // old timeline
        // if (!timelineInitialized) {
        //   timeline = timeline(hiventController);
        //   timeline.initTimeline();

        //   $(window).mousemove(timeline.moveMouse);
        //   $(window).mouseup(timeline.releaseMouse);

        //   $("#tlScroller").bind("mousedown",timeline.clickMouse);
        //   $("#tlScroller").bind("mousewheel",timeline.zoom);

        //   // dragging the now marker
        //   $("#tlScroller").bind("mousemove",timeline.moveMouseOutThres);

        //   // moving the timeline scroller with left and right buttons
        //   $("#tlMoveLeftRight").bind("mousedown", function(evt)
        //     {
        //       if (evt.button == 0)
        //         timeline.clickMoveButtonLeft(-0.01)
        //     }
        //   );
        //   $("#tlMoveLeftLeft").bind("mousedown", function(evt)
        //     {
        //       if (evt.button == 0)
        //         timeline.clickMoveButtonLeft(0.01)
        //     }
        //   );
        //   $("#tlMoveRightRight").bind("mousedown", function(evt)
        //     {
        //       if (evt.button == 0)
        //         timeline.clickMoveButtonRight(0.01)
        //     }
        //   );
        //   $("#tlMoveRightLeft").bind("mousedown",  function(evt)
        //     {
        //       if (evt.button == 0)
        //         timeline.clickMoveButtonRight(-0.01)
        //     }
        //   );

        //   // play history
        //   $('#histPlayer1').click(timeline.togglePlayer);
        //   $('#histPlayer2').click(timeline.togglePlayer);
        //   $('#histPlayer3').click(timeline.togglePlayer);

        //   // disable selection of years in timeline

        //   $("#tlMain").disableTextSelect();
        //   $("#tlScroller").disableTextSelect();
        //   $("#tlPlayer").disableTextSelect();
        //   //$("#bigDateBox").disableTextSelect();

        //   timelineInitialized = true;
        // }


      }

    </script>

  </head>
  <body data-spy="scroll" data-target="#mainNavigation" data-offset="20">
    <div class="navbar navbar-fixed-top" id="navbar">
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
          <!-- <div class="nav-collapse collapse">
            <ul class="nav pull-right">
              <li class="dropdown" id="fat-menu">
                <a data-toggle="dropdown" class="dropdown-toggle" role="button" id="language-drop" href="#"><i class="icon-comment-alt"></i> Language <b class="caret"></b></a>
                <ul aria-labelledby="language-drop" role="menu" class="dropdown-menu">
                  <li class=""><a href="?lang=de">Deutsch</a></li>
                  <li class=""><a href="?lang=en">English</a></li>
                </ul>
              </li>
            </ul>
          </div> -->
        </div>
      </div>
    </div>

    <div class="container" id="home">

      <div class="hero-unit">

        <!-- spinner -->
        <div id="map-loader" class="loader"></div>

        <div id="map-container" style="overflow:hidden; position:absolute"> </div>

        <!-- little logo -->
        <div class="bottom-left-logo" id="logo-normal" style="visibility:hidden"></div>


        <!-- prototype-warning -->
        <!-- Modal -->
        <div id="warning" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="myModalLabel">Willkommen!</h3>
          </div>
          <div class="modal-body">

            <p>Erleben Sie mit dem Prototypen von <span class="hg">HistoGlobe</span>
               den aktuellen Fortschritt des Projekts! Aber vergessen Sie nicht:
               Es handelt sich um eine Entwicklungsversion, die noch nicht den
               vollen Funktionsumfang von <span class="hg">HistoGlobe</span> bietet!
            </p>

            <div class="accordion" id="accordion2">
              <div class="accordion-group">
                <div class="accordion-heading">
                  <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion2" href="#collapseOne">
                    <i class="icon-play"></i> Versionshinweise...
                  </a>
                </div>
                <div id="collapseOne" class="accordion-body collapse">
                  <div class="accordion-inner">
                    <h4>Version 0.4 <span class="muted">(25.09.2013)</span></h4>
                    <ul>
                      <li>Ermöglicht die Darstellung von Ländernamen.</li>
                      <li>Ermöglicht die Darstellung verschiedener Hivent-Kategorien mit entsprechenden Icons.</li>
                      <li>Ermöglicht das Hervorheben von Hivents auf Zeitleiste und KArte beim Berühren mit der Maus.</li>
                    </ul>
                    <h4>Version 0.3 <span class="muted">(09.09.2013)</span></h4>
                    <ul>
                      <li>Behebt ein Problem, das dazu führte, dass Hiventinformationen erst nach zweimaligem Anklicken angezeigt wurden.</li>
                      <li>Behebt die falsche Positionierung der Hivent-Tooltips.</li>
                      <li>Ermöglicht das Einklappen der Versionshinweise.</li>
                      <li>Verbessert die Kompatibilität mit kleinen Bildschirmen.</li>
                      <li>Verbessert die Interaktion mit der Zeitleiste.</li>
                      <li>Verbessert die Darstellung der Zeitleiste.</li>
                    </ul>
                    <h4>Version 0.2 <span class="muted">(08.09.2013)</span></h4>
                    <ul>
                      <li>Ermöglicht 2D-Grenzverschiebungen zu visualisieren.</li>
                      <li>Ermöglicht die zeitlich Filterung mit Hilfe der Zeitleiste.</li>
                      <li>Ermöglicht die Verschiebung von Info-Popups.</li>
                      <li>Verändert das Erscheinungsbild der Karte.</li>
                      <li>Stellt Daten zur Entwicklung der europäischen Union dar. Sie können bisher nur in 2D betrachtet werden.</li>
                    </ul>
                    <h4>Version 0.1 <span class="muted">(02.06.2013)</span></h4>
                    <ul>
                      <li><span class="hg">HistoGlobe</span> 2D/3D: Die Darstellung der geografischen Welt (Land/Wasser) ist implenentiert.</li>
                      <li><span class="hg">HistoGlobe</span> 2D/3D: Die Verortung von historischen Ereignissen ist möglich.</li>
                      <li><span class="hg">HistoGlobe</span> 2D/3D: Die Verortung von historischen Ereignissen ist möglich.</li>
                      <li>Zeitleiste: Es ist möglich, Ereignisse darzustellen.</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn" id="warning-close" data-dismiss="modal" aria-hidden="true" data-loading-text="Lädt Karte...">Los!</button>
          </div>
        </div>

        <!-- gl header -->
        <div id="gl-header" style="visibility:hidden">

          <!-- legend -->
          <div id="legend">
            <h3>Legende</h3>
            <table>
              <tr><td style="width:32px; height:32px; background-color:#9F8BFF"></td>
                  <td style="padding:5px"><small>Europäische Union / EG</small></td></tr>
              <tr><td style="width:32px; height:32px; background-color:#FFA46D"></td>
                  <td style="padding:5px"><small>Eurozone</small></td></tr>
              <tr><td style="padding:10px"/><td style="padding:10px"/></tr>
              <tr><td style="width:32px; height:32px; background-image:url('data/hivent_icons/icon_join.png'); background-size: cover"></td>
                  <td style="padding:5px"><small>Beitritt</small></td></tr>
              <tr><td style="width:32px; height:32px; background-image:url('data/hivent_icons/icon_law.png'); background-size: cover"></td>
                  <td style="padding:5px"><small>Vertrag</small></td></tr>
              <tr><td style="width:32px; height:32px; background-image:url('data/hivent_icons/icon_default.png'); background-size: cover"></td>
                  <td style="padding:5px"><small>Sonstige</small></td></tr>

            </table>
          </div>

          <!-- Now Marker in middle of page -->
          <div id="now_marker">
            <div id="now_marker_in">
            </div>
          </div>

          <!-- timeline NEW -->
          <div id="timeline">

          </div>

          <!-- timeline OLD-->
<!--      <div id="tlContainer">

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
                  <a id="toggle-2D" class="btn active" onClick="load2D()">2D</a>
                  <a id="toggle-3D" class="btn" onClick="load3D()">3D</a>
                </div>
              </div>
            </div>

            <div id="timeline"  class="gradient-timeline-main">
              <div id="tlMain">
                <div id="tlScroller">
                  <div id="tlDateMarkers">
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
 -->
        </div>

        <!-- video -->
        <div id="video-header"
           style="display:none; position:absolute; width: 100%; height: 100%;">

          <iframe id="ytplayer" type="text/html" width="100%" height="100%"
            src="http://www.youtube.com/embed/pbEm_v7p0kw?modestbranding=1&amp;showinfo=0&amp;autohide=1&amp;color=white&amp;theme=light&amp;wmode=transparent&amp;rel=0"
            frameborder="0" yt:quality=high allowfullscreen>
          </iframe>
        </div>
        <!-- banner -->
        <!-- <div class="banner" style="visibility:hidden"></div> -->

        <!-- Video / Prototype buttons -->
        <center>
        <p class="header-button-center">
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
        </center>

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




      <!-- content -->
      <div id="content">
        <div class="info-box">
          <div class="row">
            <p><i class="icon-warning-sign pull-left" style="font-size:200%; padding-top:5px"></i>  <?php locale("not_ready")?></p>
          </div>
        </div>

        <div class="row">
          <div class="span12">
            <div class="gradient-down summary">
              <img src="img/browser.png" id="browser-img" class="img-left pull-right" alt="HistoGlobe im Browser">
              <h2><?php locale("summary_head")?><br><span class="muted"> <?php locale("summary_head_2")?></span></h2>
              <p><?php locale("summary")?> <p>
              <!-- <h2>Was bietet Ihnen HistoGlobe?</h2>
              <img src="img/info.png" id="info-img" alt="HistoGlobe Info"> -->
            </div>
          </div>
        </div>

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
      </div>
    </div>
  </body>
</html>
