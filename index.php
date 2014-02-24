<?php $debug_mode = true; ?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-de" lang="de-de" dir="ltr">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>HistoGlobe</title>

    <?php // third party css ?>
    <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/idangerous.swiper.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/idangerous.swiper.scrollbar.css">
    <link rel="stylesheet" href="style/third-party/prettyPhoto/css/prettyPhoto.css" type="text/css" media="screen" title="prettyPhoto main stylesheet" charset="utf-8" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.css" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.css" />
    <link rel="stylesheet" href="style/third-party/leaflet.css" />
    <link rel="stylesheet" href="style/third-party/leaflet.label.css" />
    <!--[if lte IE 8]>hivent
      <link rel="stylesheet" href="style/third-party/leaflet.ie.css" />
      <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.ie.css" />
    <![endif]-->

    <?php // histoglobe css ?>
    <link rel="stylesheet" type="text/css" href="style/histoglobe.min.css">

    <?php // third party javascript ?>
    <script type="text/javascript" src="script/third-party/d3.v3.min.js"></script>

    <script type="text/javascript" src="script/third-party/jquery-1.9.0.min.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.browser.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.disable.text.select.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.mousewheel.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.rotate.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.prettyPhoto.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.fullscreenApi.js"></script>

    <script type="text/javascript" src="script/third-party/idangerous.swiper-2.4.2.min.js"></script>
    <script type="text/javascript" src="script/third-party/idangerous.swiper.scrollbar-2.4.js"></script>

    <script type="text/javascript" src="script/third-party/leaflet.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.label.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.markercluster.js"></script>

    <script type="text/javascript" src="script/third-party/bootstrap.min.js"></script>

    <script type="text/javascript" src="script/third-party/raphael.min.js"></script>

    <script type="text/javascript" src="script/third-party/three.min.js"></script>
    <script type="text/javascript" src="script/third-party/TessellateModifier.js"></script>
<!--
    <script type="text/javascript" src="build/Display3D.js"></script>
    <script type="text/javascript" src="build/Path.js"></script>
    <script type="text/javascript" src="build/ArcPath2D.js"></script>
    <script type="text/javascript" src="build/PathController.js"></script>
    <script type="text/javascript" src="build/LinearPath2D.js"></script>
    <script type="text/javascript" src="build/Label.js"></script>
    <script type="text/javascript" src="build/LabelController.js"></script>
    <script type="text/javascript" src="build/HiventMarker3D.js"></script>
    <script type="text/javascript" src="script/util/BrowserDetect.js"></script>
    <script type="text/javascript" src="build/VideoPlayer.js"></script>
-->

    <?php // histoglobe javascript ?>
    <?php if ($debug_mode) {?>

    <script type="text/javascript" src="build/config.js"></script>
    <script type="text/javascript" src="build/CallbackContainer.js"></script>
    <script type="text/javascript" src="build/Vector.js"></script>
    <script type="text/javascript" src="build/Mixin.js"></script>
    <script type="text/javascript" src="build/Hivent.js"></script>
    <script type="text/javascript" src="build/HiventDatabaseInterface.js"></script>
    <script type="text/javascript" src="build/HiventBuilder.js"></script>
    <script type="text/javascript" src="build/HiventHandle.js"></script>
    <script type="text/javascript" src="build/HiventMarker.js"></script>
    <script type="text/javascript" src="build/HiventMarker2D.js"></script>
    <script type="text/javascript" src="build/HiventMarkerTimeline.js"></script>
    <script type="text/javascript" src="build/HiventController.js"></script>
    <script type="text/javascript" src="build/Area.js"></script>
    <script type="text/javascript" src="build/AreaController.js"></script>
    <script type="text/javascript" src="build/AreaIndicator.js"></script>
    <script type="text/javascript" src="build/AreasOnMap.js"></script>
    <script type="text/javascript" src="build/AreasOnGlobe.js"></script>
    <script type="text/javascript" src="build/Display.js"></script>
    <script type="text/javascript" src="build/Display2D.js"></script>
    <script type="text/javascript" src="build/DoublyLinkedList.js"></script>
    <script type="text/javascript" src="build/YearMarker.js"></script>
    <script type="text/javascript" src="build/NowMarker.js"></script>
    <script type="text/javascript" src="build/Timeline.js"></script>
    <script type="text/javascript" src="build/Sidebar.js"></script>
    <script type="text/javascript" src="build/Widget.js"></script>
    <script type="text/javascript" src="build/TextWidget.js"></script>
    <script type="text/javascript" src="build/GalleryWidget.js"></script>
    <script type="text/javascript" src="build/TimeGalleryWidget.js"></script>
    <script type="text/javascript" src="build/VIPWidget.js"></script>
    <script type="text/javascript" src="build/LogoWidget.js"></script>
    <script type="text/javascript" src="build/PictureWidget.js"></script>
    <script type="text/javascript" src="build/LegendWidget.js"></script>
    <script type="text/javascript" src="build/StatisticsWidget.js"></script>
    <script type="text/javascript" src="build/ControlButtonArea.js"></script>
    <script type="text/javascript" src="build/ZoomButtons.js"></script>
    <script type="text/javascript" src="build/FullscreenButton.js"></script>
    <script type="text/javascript" src="build/HiventsOnMap.js"></script>
    <script type="text/javascript" src="build/HiventsOnTimeline.js"></script>
    <script type="text/javascript" src="build/HiventTooltips.js"></script>
    <script type="text/javascript" src="build/HiventInfoPopover.js"></script>
    <script type="text/javascript" src="build/HiventInfoPopovers.js"></script>
    <script type="text/javascript" src="build/HiventInfoAtTag.js"></script>
    <script type="text/javascript" src="build/HistoGlobe.js"></script>

    <script type="text/javascript" src="build/Globe.js"></script>

    <!-- init histoglobe -->
    <?php } else { ?>

    <script type="text/javascript" src="script/histoglobe.min.js"></script>

    <?php } ?>

    <?php // init histoglobe ?>
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

      $(document).ready(function($) {
        // var histoglobe = new HG.HistoGlobe("config/sdw/modules.json");
        var histoglobe = new HG.HistoGlobe("config/eu/modules.json");
        // var histoglobe = new HG.HistoGlobe("config/fertility/modules.json");
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

          <!--
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

  <!-- <link href='http://fonts.googleapis.com/css?family=Marcellus+SC' rel='stylesheet' type='text/css'> -->

</html>
