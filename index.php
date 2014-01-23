<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-de" lang="de-de" dir="ltr">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>HistoGlobe</title>

    <!-- third party css -->
    <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/font-awesome.min.css">
<!--
    <link href='http://fonts.googleapis.com/css?family=Marcellus+SC' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="style/third-party/leaflet.css" />
    <link rel="stylesheet" href="style/third-party/leaflet.label.css" />
    <link rel="stylesheet" href="style/third-party/prettyPhoto/css/prettyPhoto.css" type="text/css" media="screen" title="prettyPhoto main stylesheet" charset="utf-8" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.css" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.css" />
-->
    <!--[if lte IE 8]>hivent
      <link rel="stylesheet" href="style/third-party/leaflet.ie.css" />
      <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.ie.css" />
    <![endif]-->

    <!-- histoglobe css -->
    <link rel="stylesheet" type="text/css" href="style/histoglobe.min.css">

    <!-- third party javascript -->
    <script type="text/javascript" src="script/third-party/jquery-1.9.0.min.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.browser.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.disable.text.select.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.mousewheel.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.rotate.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.prettyPhoto.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.fullscreenApi.js"></script>

   <!-- <script type="text/javascript" src="script/histoglobe.min.js"></script>

    <script type="text/javascript" src="build/Mixin.js"></script>
    <script type="text/javascript" src="build/CallbackContainer.js"></script>
    <script type="text/javascript" src="build/Vector.js"></script>
    <script type="text/javascript" src="build/Display.js"></script>
    <script type="text/javascript" src="build/Display3D.js"></script>
    <script type="text/javascript" src="build/Hivent.js"></script>
    <script type="text/javascript" src="build/Display2D.js"></script>
    <script type="text/javascript" src="build/HiventDatabaseInterface.js"></script>
    <script type="text/javascript" src="build/HiventBuilder.js"></script>
    <script type="text/javascript" src="build/HiventController.js"></script>
    <script type="text/javascript" src="build/HiventHandle.js"></script>
    <script type="text/javascript" src="build/HiventInfoPopover.js"></script>
    <script type="text/javascript" src="build/Path.js"></script>
    <script type="text/javascript" src="build/ArcPath2D.js"></script>
    <script type="text/javascript" src="build/PathController.js"></script>
    <script type="text/javascript" src="build/LinearPath2D.js"></script>
    <script type="text/javascript" src="build/Area.js"></script>
    <script type="text/javascript" src="build/AreaController.js"></script>
    <script type="text/javascript" src="build/Label.js"></script>
    <script type="text/javascript" src="build/LabelController.js"></script>
    <script type="text/javascript" src="build/HiventMarker.js"></script>
    <script type="text/javascript" src="build/HiventMarker2D.js"></script>
    <script type="text/javascript" src="build/HiventMarker3D.js"></script>
    <script type="text/javascript" src="build/HiventMarkerTimeline.js"></script>
    <script type="text/javascript" src="build/Timeline.js"></script>
    <script type="text/javascript" src="build/YearMarker.js"></script>
    <script type="text/javascript" src="script/util/BrowserDetect.js"></script>
    <script type="text/javascript" src="build/VideoPlayer.js"></script>
    <script type="text/javascript" src="build/NowMarker.js"></script>
    <script type="text/javascript" src="build/DoublyLinkedList.js"></script>
    <script type="text/javascript" src="build/Legend.js"></script>
-->
    <!-- histoglobe javascript -->
    <!--   <script type="text/javascript" src="script/histoglobe.min.js"></script> -->
    <script type="text/javascript" src="build/Widget.js"></script>
    <script type="text/javascript" src="build/TextWidget.js"></script>
    <script type="text/javascript" src="build/HistoGlobe.js"></script>

    <!-- init histoglobe -->
    <script type="text/javascript">
      // var display2D, display3D, timeline, legend, hiventController, areaController, pathController, labelController;
      // var timelineInitialized = false;
      // var container;
      // var windowHeight = window.innerHeight;

      // jQuery(document).ready(function($) {
      //   BrowserDetect.init();

      //   if (!BrowserDetect.webglRenderingSupported) {
      //     var elem_title = 'Entschuldigung! <a class="close pull-right" style="margin-top: -3px;" onclick="$(&#39;#display-mode-switch&#39;).popover(&#39;hide&#39;);">&times;</a>';
      //     var elem_content = '';
      //     if (BrowserDetect.webglContextSupported) {
      //       if (BrowserDetect.browser != "unknown") {
      //         elem_content = 'Obwohl Ihr Browser (' + BrowserDetect.browser + ') <span class="hg">HistoGlobe</span> anzeigen kann, treten auf Ihrem Rechner leider Probleme auf. Eventuell ist der Treiber Ihrer Graphikkarte nicht aktuell. Weitere Hilfe zum Thema WebGL und ' + BrowserDetect.browser + ' erhalten Sie hier: <br><br> <a target="_blank" class="btn btn-block btn-success" href ="' +
      //                        BrowserDetect.urls.troubleshootingUrl+ '">' + BrowserDetect.browser + ' Support</a>';
      //       }

      //     } else {
      //       if (BrowserDetect.browser != "unknown" && BrowserDetect.urls.upgradeUrl) {
      //         elem_content = 'Ihre Version von ' + BrowserDetect.browser
      //                         + ' ist nicht aktuell! Wenn Sie <span class="hg">HistoGlobe</span> auf einem Globus genießen wollen, aktualisieren Sie bitte Ihren Browser. <br><br><a target="_blank" class="btn btn-block btn-success" href ="'
      //                         + BrowserDetect.urls.upgradeUrl + '">'
      //                         + BrowserDetect.browser + ' aktualisieren' + '</a>';
      //       } else {
      //         elem_content = BrowserDetect.browser + ' unterstützt leider noch keine 3D-Graphiken. Wenn Sie <span class="hg">HistoGlobe</span> auf einem Globus genießen wollen, installieren Sie bitte einen der folgenden Browser: <br><br> <a target="_blank" class="btn btn-block btn-success" href ="http://www.mozilla.org/de/firefox/new/"> Firefox herunterladen </a> <a target="_blank" class="btn btn-block btn-success" href ="https://www.google.com/intl/de/chrome/browser/"> Chrome herunterladen </a>'
      //       }
      //     }

      //     $('#display-mode-switch').popover({container: 'body', animation:true, title:elem_title, content:elem_content, html:true, placement:"top"});
      //   }

      //   $('.hg-tooltip').tooltip();


      //   loadGLHeader();

      // });

      // function loadGLHeader() {

      //   if (BrowserDetect.canvasSupported) {

      //     if (window.fullScreenApi.supportsFullScreen) {
      //       var heroUnit = $('#home');
      //       $('#toggle-fullscreen').click(
      //         function() {
      //           if (!window.fullScreenApi.isFullScreen()) {
      //             heroUnit.requestFullScreen();
      //             heroUnit.width('100%');
      //             heroUnit.height('100%');
      //           } else {
      //             window.fullScreenApi.cancelFullScreen();
      //           }
      //         }
      //       );

      //       function resetFullScreen() {
      //         if (!window.fullScreenApi.isFullScreen()) {
      //           heroUnit.height(windowHeight);
      //         }
      //         $('#toggle-fullscreen').button('toggle');
      //       }
      //       //webkit
      //       heroUnit.on('webkitfullscreenchange', resetFullScreen);

      //       //mozilla
      //       document.addEventListener('mozfullscreenchange', resetFullScreen);
      //     }

      //     $('#warning-close').button('loading')

      //     $('#home').height(windowHeight);
      //     window.setTimeout(function() {

      //       $('#warning').modal();

      //       window.setTimeout(function() {
      //         hiventController = new HG.HiventController();

      //         container = document.getElementById('map-container');

      //         // Load Timeline and NowMarker
      //         loadTimeline(hiventController);

      //         areaController = new HG.AreaController(timeline);
      //         labelController = new HG.LabelController(timeline);

      //         load2D();

      //         pathController = new HG.PathController(timeline, hiventController, display2D._map);

      //         loadLegend();

      //         // config = {
      //         //   hiventServerName: "histoglobe.com",
      //         //   hiventDatabaseName: "hivents",
      //         //   hiventTableName: "eu_hivents",
      //         //   multimediaServerName: "histoglobe.com",
      //         //   multimediaDatabaseName: "hivents",
      //         //   multimediaTableName: "eu_multimedia"
      //         // };

      //         // hiventController.loadHiventsFromDatabase(config);

      //         config = {
      //           hiventJSONPath: "data/hivent_collection.json",
      //           multimediaJSONPath: "data/multimedia_collection.json",
      //         };
      //         hiventController.loadHiventsFromJSON(config);

      //         $('#warning-close').button('reset')

      //       }, 500);

      //     }, 200);


      //     $('#toggle-backend').click(
      //       function() {
      //         $('#backend').modal();
      //       }
      //     );
      //   }
      // }

      // function load2D() {

      //   if (display3D && display3D.isRunning()) {
      //     $(display3D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
      //     display3D.stop();
      //     $('#toggle-3D').button("toggle");
      //     $('#toggle-2D').button("toggle");
      //   }

      //   if (!display2D) {
      //     display2D = new HG.Display2D(container, hiventController, areaController, labelController);
      //     $(display2D.getCanvas()).css({opacity: 0.0});
      //   }

      //   display2D.start();
      //   $(display2D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');
      // }

      // function load3D() {
      //   if (BrowserDetect.webglRenderingSupported) {
      //     if (display2D && display2D.isRunning()){
      //       $(display2D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
      //       display2D.stop();
      //       $('#toggle-3D').button("toggle");
      //       $('#toggle-2D').button("toggle");
      //     }

      //     if (!display3D) {
      //       display3D = new HG.Display3D(container, hiventController, areaController, labelController);
      //       $(display3D.getCanvas()).css({opacity: 0.0});
      //     }

      //     display3D.start();
      //     $(display3D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');

      //   }
      // }

      // function loadLegend() {
      //   gui_container = document.getElementById('gui-container');
      //   legend = new HG.Legend(gui_container, hiventController);

      //   legend.addCategoryWithColor("eu", "#9F8BFF", "EU / EG", false);
      //   legend.addCategoryWithColor("euro", "#5B309F", "Eurozone", false);

      //   legend.addSpacer();

      //   legend.addCategoryWithIcon("join", "data/hivent_icons/icon_join.png", "Beitritt", true);
      //   legend.addCategoryWithIcon("contract", "data/hivent_icons/icon_contract.png", "Vertrag", true);
      //   legend.addCategoryWithIcon("default", "data/hivent_icons/icon_default.png", "Sonstige", true);
      // }

      // function loadTimeline(hiventController) {
      //   if (!timelineInitialized) {
      //     timeline = new HG.Timeline(1975, 1940, 2014, document.getElementById("timeline"), document.getElementById("now_marker"), hiventController);
      //   }
      // }

      $(document).ready(function($) {
        var histoglobe = new HG.HistoGlobe(document.getElementById('histoglobe'));
      });
    </script>

    <!-- edit backend -->
     <?php //readfile("php/backend.php"); ?>


<!--
    <div id="home">
-->

        <!-- spinner -->
        <!-- <div id="map-loader" class="loader"></div>

        <div id="map-container" style="overflow:hidden; position:absolute;"> </div> -->


        <!-- prototype-warning -->
        <?php //readfile("php/greeting.php"); ?>

        <!-- gl header -->
        <!-- <div id="gl-header"> -->

          <!-- <div id="editMenu"  class="menu">
            <div id="toggle-backend" class="btn btn-default"><i class="fa fa-pencil"></i> Editieren</div>
          </div> -->

          <!-- <div id="gui-container"> </div>

          <div id="fullscreenMenuRight"  class="menu">
            <div id="toggle-fullscreen" class="btn btn-default"><i class="fa fa-fullscreen"></i> Vollbild</div>
          </div> -->


          <!-- Now Marker in middle of page -->
          <!-- <div id="now_marker">
            <div id="now_marker_pointer">
              <img src="img/timeline/pointer.png"/>
            </div>
            <div id="now_marker_in">
              <div id="now_marker_play" title="Click to play">
                <img src="img/timeline/playIcon.png" />
              </div>
              <input type="text" name="now_date" id="now_date_input" maxlength="10" size="10" />
            </div>
          </div>
          <div id="timeline"></div>
          <img src="img/timeline/nowMarkerSmall.png" id="now_marker_sign">
          <div id="fullscreenMenuRight"  class="menu">
            <div id="toggle-fullscreen" class="btn btn-default"><i class="icon-fullscreen"></i> Vollbild</div>
          </div>

        </div>
      </div>
  </head> -->

  <body>
    <!-- display warning if no javascript is available -->
    <noscript>
      <div class="container">
        <div class="jumbotron" style="margin-top:5%">
          <h1><span class="hg">HistoGlobe</span> benötigt Javascript!</h1>
          <p>Bitte aktivieren Sie in Ihrem Browser Javascript, da <span class="hg">HistoGlobe</span> sonst nicht funktioniert.</p>
          <p><a href="http://www.enable-javascript.com/de/" class="btn btn-primary btn-lg" role="button">Wie aktiviere ich Javascript?</a></p>
        </div>
      </div>
    </noscript>

    <div id="histoglobe"></div>

  </body>

  <link href='http://fonts.googleapis.com/css?family=Marcellus+SC' rel='stylesheet' type='text/css'>

</html>
