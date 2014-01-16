<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-de" lang="de-de" dir="ltr">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>HistoGlobe</title>

    <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/font-awesome.min.css">
    <link href='http://fonts.googleapis.com/css?family=Marcellus+SC' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="style/third-party/leaflet.css" />
    <link rel="stylesheet" href="style/third-party/leaflet.label.css" />
    <link rel="stylesheet" href="style/third-party/prettyPhoto/css/prettyPhoto.css" type="text/css" media="screen" title="prettyPhoto main stylesheet" charset="utf-8" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.css" />
    <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.css" />
    <!--[if lte IE 8]>hivent
      <link rel="stylesheet" href="style/third-party/leaflet.ie.css" />
      <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.ie.css" />
    <![endif]-->

    <link rel="stylesheet" type="text/css" href="style/histoglobe.min.css">

    <script type="text/javascript" src="script/third-party/d3.v3.min.js"></script>
    <script type="text/javascript" src="script/third-party/jquery-1.9.0.min.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.browser.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.disable.text.select.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.mousewheel.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.rotate.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.prettyPhoto.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.fullscreenApi.js"></script>
    <script type="text/javascript" src="script/third-party/bootstrap.min.js"></script>
    <script type="text/javascript" src="script/third-party/RequestAnimationFrame.js"></script>
    <script type="text/javascript" src="script/third-party/three.min.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.js"></script>
    <script type="text/javascript" src="script/third-party/raphael.min.js"></script>
    <script type="text/javascript" src="script/third-party/topojson.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.label.js"></script>
    <script type="text/javascript" src="script/third-party/leaflet.markercluster.js"></script>

   <!-- <script type="text/javascript" src="script/histoglobe.min.js"></script>-->

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

    <script type="text/javascript">
      var display2D, display3D, timeline, hiventController, areaController, labelController;
      var timelineInitialized = false;
      var container;
      var windowHeight = window.innerHeight;

      jQuery(document).ready(function($) {
        BrowserDetect.init();

        // if (!BrowserDetect.webglRenderingSupported) {
          var elem_title = 'Entschuldigung! <a class="close pull-right" style="margin-top: -3px;" onclick="$(&#39;#display-mode-switch&#39;).popover(&#39;hide&#39;);">&times;</a>';
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

          $('#display-mode-switch').popover({container: 'body', animation:true, title:elem_title, content:elem_content, html:true, placement:"top"});
        // }

        loadGLHeader();

      });

      function loadGLHeader() {

        if (BrowserDetect.canvasSupported) {

          if (window.fullScreenApi.supportsFullScreen) {
            var heroUnit = $('#home');
            $('#toggle-fullscreen').click(
              function() {
                if (!window.fullScreenApi.isFullScreen()) {
                  heroUnit.requestFullScreen();
                  heroUnit.width('100%');
                  heroUnit.height('100%');
                } else {
                  window.fullScreenApi.cancelFullScreen();
                }
              }
            );

            function resetFullScreen() {
              if (!window.fullScreenApi.isFullScreen()) {
                heroUnit.height(windowHeight);
              }
              $('#toggle-fullscreen').button('toggle');
            }
            //webkit
            heroUnit.on('webkitfullscreenchange', resetFullScreen);

            //mozilla
            document.addEventListener('mozfullscreenchange', resetFullScreen);
          }

          $('#warning-close').button('loading')

          $('#home').height(windowHeight);
          window.setTimeout(function() {

            $('#warning').modal()

            window.setTimeout(function() {
              hiventController = new HG.HiventController("data/hivent_collection.json");

              container = document.getElementById('map-container');

              // Load Timeline and NowMarker
              loadTimeline(hiventController);

              areaController = new HG.AreaController(timeline);
              labelController = new HG.LabelController(timeline);

              load2D();

              $('#warning-close').button('reset')

            }, 500);

          }, 200);
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
          display2D = new HG.Display2D(container, hiventController, areaController, labelController);
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
            display3D = new HG.Display3D(container, hiventController, areaController, labelController);
            $(display3D.getCanvas()).css({opacity: 0.0});
          }

          display3D.start();
          $(display3D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');

        }
      }

      function loadTimeline(hiventController) {
        if (!timelineInitialized) {
          timeline = new HG.Timeline(1500, 1050, 2010, document.getElementById("timeline"), document.getElementById("now_marker"), hiventController);
        }
      }

    </script>
  </head>

  <body data-spy="scroll" data-target="#mainNavigation" data-offset="20">

    <div id="home">


        <!-- spinner -->
        <div id="map-loader" class="loader"></div>

        <div id="map-container" style="overflow:hidden; position:absolute;"> </div>

        <!-- prototype-warning -->
        <!-- Modal -->
        <div id="warning" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div class="modal-dialog">
          <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h4 id="myModalLabel">Willkommen!</h4>
          </div>
          <div class="modal-body">

            <p>
              Erleben Sie mit dem Prototypen von <span class="hg">HistoGlobe</span>
              die Entwicklung der Europäischen Union von 1945 bis heute!
            </p>
            <p>
               Diese Demo zeigt den aktuellen Fortschritt des Projekts. Vergessen Sie nicht:
               Es handelt sich um eine Entwicklungsversion, die noch nicht den
               vollen Funktionsumfang von <span class="hg">HistoGlobe</span> bietet!
            </p>

            <div class="panel-group" id="accordion2">
              <div class="panel panel-default">
                <div class="panel-heading">
                  <h4 class="panel-title">
                    <a data-toggle="collapse" data-parent="#accordion2" href="#version-hints">
                      <i class="icon-play"></i> Versionshinweise...
                    </a>
                  </h4>
                </div>
                <div id="version-hints" class="panel-collapse collapse">
                  <div class="panel-body">
                    <h4>Version 0.6 <span class="muted">(16.10.2013)</span></h4>
                    <ul>
                      <li>Wartet mit neu gestalteten Bedienelementen auf.</li>
                      <li>Behebt ein Problem, durch das Tooltips nach dem Öffnen zusammengefasster Hivents auf der Karte an der falschen Stelle angezeigt wurden.</li>
                    </ul>
                    <h4>Version 0.5 <span class="muted">(16.10.2013)</span></h4>
                    <ul>
                      <li>Löst den Prototypen von der bisherigen statischen Seite.</li>
                      <li>Behebt ein Problem, das dazu führte, dass Gallerieelemente nach zeitlicher Filterung mehrmals auftauchten.</li>
                    </ul>
                    <h4>Version 0.4.1 <span class="muted">(15.10.2013)</span></h4>
                    <ul>
                      <li>Ändert die Farben der EU-Länder.</li>
                      <li>Ermöglicht die Darstellung von Ländernamen in nativen Sprachen.</li>
                      <li>Ermöglicht das Einbinden von Bildern in Hivents.</li>
                    </ul>
                    <h4>Version 0.4 <span class="muted">(25.09.2013)</span></h4>
                    <ul>
                      <li>Ermöglicht die Darstellung von Ländernamen.</li>
                      <li>Ermöglicht die Darstellung verschiedener Hivent-Kategorien mit entsprechenden Icons.</li>
                      <li>Ermöglicht das Hervorheben von Hivents auf Zeitleiste und Karte beim Berühren mit der Maus.</li>
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
                <button class="btn btn-default" id="warning-close" data-dismiss="modal" aria-hidden="true" data-loading-text="Lädt Karte...">Los!</button>
              </div>
            </div>
          </div>
        </div>

        <!-- gl header -->
        <div id="gl-header">

          <!-- legend -->
          <div id="legend" class = "menu">
            <table>
              <tr><td style="width:10px; height:10px; background-color:#9F8BFF"></td>
                  <td style="padding:0px 5px"><small>EU / EG</small></td></tr>
              <tr><td style="width:10px; height:10px; background-color:#5B309F"></td>
                  <td style="padding:0px 5px"><small>Eurozone</small></td></tr>
              <tr><td style="padding:10px"/><td style="padding:10px"/></tr>
              <tr><td style="width:10px; height:10px; background-image:url('data/hivent_icons/icon_join.png'); background-repeat: no-repeat; background-size: contain"></td>
                  <td style="padding:0px 5px"><small>Beitritt</small></td></tr>
              <tr><td style="width:10px; height:10px; background-image:url('data/hivent_icons/icon_law.png'); background-repeat: no-repeat; background-size: contain"></td>
                  <td style="padding:0px 5px"><small>Vertrag</small></td></tr>
              <tr><td style="width:10px; height:10px; background-image:url('data/hivent_icons/icon_default.png'); background-repeat: no-repeat; background-size: contain"></td>
                  <td style="padding:0px 5px"><small>Sonstige</small></td></tr>

            </table>
          </div>

          <!-- Now Marker in middle of page -->
          <div id="now_marker">
            <div id="now_marker_pointer">
              <img src="img/timeline/pointer.png"/>
            </div>
            <div id="now_marker_in">
              <div id="now_marker_play">
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

  </body>
</html>
