<?php //config_path is set by make.sh. ATTENTION ?> 
<?php $config_path = 'teaser3_sidebar'; ?> 
<?php $debug_mode = true; ?> 
<DOCTYPE html> 
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-de" lang="de-de" dir="ltr"> 
  <head> 
    <meta http-equiv="content-type" content="text/html; charset=utf-8" /> 
    <meta name="viewport" content="width=device-width, initial-scale=1.0" /> 
    <title>HistoGlobe</title> 
    <?php // third party css ?> 
    <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.min.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/font-awesome.min.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/idangerous.swiper.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/idangerous.swiper.scrollbar.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/colorbox.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/MarkerCluster.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/MarkerCluster.Default.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/leaflet.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/leaflet.label.css" /> 
    <link rel="stylesheet" type="text/css" href="style/third-party/jplayer/blue.monday/jplayer.blue.monday.css" /> 
    <--[if lte IE 8]>hivent 
      <link rel="stylesheet" href="style/third-party/leaflet.ie.css" /> 
      <link rel="stylesheet" href="style/third-party/MarkerCluster.Default.ie.css" /> 
    <[endif]--> 
    <link href="style/third-party/select2.css" rel="stylesheet"/> 
    <?php // histoglobe css ?> 
    <link rel="stylesheet" type="text/css" href="style/histoglobe.min.css"> 
    <?php // third party javascript ?> 
    <script type="text/javascript" src="script/third-party/d3.v3.min.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery-1.9.0.min.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.browser.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.disable.text.select.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.mousewheel.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.rotate.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.colorbox-min.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.fullscreenApi.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.parse.min.js"></script> 
    <script type="text/javascript" src="script/third-party/jquery.jplayer.min.js"></script> 
    <script type="text/javascript" src="script/third-party/idangerous.swiper.min.js"></script> 
    <script type="text/javascript" src="script/third-party/idangerous.swiper.scrollbar.min.js"></script> 
    <script type="text/javascript" src="script/third-party/leaflet.js"></script> 
    <script type="text/javascript" src="script/third-party/leaflet.label.js"></script> 
    <script type="text/javascript" src="script/third-party/leaflet.markercluster.js"></script> 
    <script type="text/javascript" src="script/third-party/bootstrap.min.js"></script> 
    <script type="text/javascript" src="script/third-party/three.min.js"></script> 
    <script type="text/javascript" src="script/third-party/TessellateModifier.js"></script> 
    <script type="text/javascript" src="script/third-party/BrowserDetect.js"></script> 
    <script src="script/third-party/select2.min.js"></script> 
    <?php // histoglobe javascript ?> 
    <?php if ($debug_mode) {?> 
    <script type="text/javascript" src="build/default_config.js"></script> 
    <script type="text/javascript" src="build/config.js"></script> 
    <script type="text/javascript" src="build/CallbackContainer.js"></script> 
    <script type="text/javascript" src="build/CSSCreator.js"></script> 
    <script type="text/javascript" src="build/Mixin.js"></script> 
    <script type="text/javascript" src="build/Vector.js"></script> 
    <script type="text/javascript" src="build/Popover.js"></script> 
    <script type="text/javascript" src="build/MultimediaController.js"></script> 
    <script type="text/javascript" src="build/Hivent.js"></script> 
    <script type="text/javascript" src="build/HiventDatabaseInterface.js"></script> 
    <script type="text/javascript" src="build/HiventBuilder.js"></script> 
    <script type="text/javascript" src="build/HiventHandle.js"></script> 
    <script type="text/javascript" src="build/HiventMarker.js"></script> 
    <script type="text/javascript" src="build/HiventMarker2D.js"></script> 
    <script type="text/javascript" src="build/HiventMarker3D.js"></script> 
    <script type="text/javascript" src="build/HiventMarkerTimeline.js"></script> 
    <script type="text/javascript" src="build/HiventController.js"></script> 
    <script type="text/javascript" src="build/Styler.js"></script> 
    <script type="text/javascript" src="build/TimeMapper.js"></script> 
    <script type="text/javascript" src="build/ShapeController.js"></script> 
    <script type="text/javascript" src="build/Area.js"></script> 
    <script type="text/javascript" src="build/AreaController.js"></script> 
    <script type="text/javascript" src="build/AreaStyler.js"></script> 
    <script type="text/javascript" src="build/AreasOnMap.js"></script> 
    <script type="text/javascript" src="build/AreasOnGlobe.js"></script> 
    <script type="text/javascript" src="build/Display.js"></script> 
    <script type="text/javascript" src="build/Display2D.js"></script> 
    <script type="text/javascript" src="build/DoublyLinkedList.js"></script> 
    <script type="text/javascript" src="build/DateMarker.js"></script> 
    <script type="text/javascript" src="build/NowMarker.js"></script> 
    <script type="text/javascript" src="build/Timeline.js"></script> 
    <script type="text/javascript" src="build/TimeBars.js"></script> 
    <script type="text/javascript" src="build/Sidebar.js"></script> 
    <script type="text/javascript" src="build/Widget.js"></script> 
    <script type="text/javascript" src="build/EventTicker.js"></script> 
    <script type="text/javascript" src="build/Gallery.js"></script> 
    <script type="text/javascript" src="build/SDWTitle.js"></script> 
    <script type="text/javascript" src="build/Title.js"></script> 
    <script type="text/javascript" src="build/TitleImage.js"></script> 
    <script type="text/javascript" src="build/TextWidget.js"></script> 
    <script type="text/javascript" src="build/GalleryWidget.js"></script> 
    <script type="text/javascript" src="build/TimeGalleryWidget.js"></script> 
    <script type="text/javascript" src="build/PictureGalleryWidget.js"></script> 
    <script type="text/javascript" src="build/VIPWidget.js"></script> 
    <script type="text/javascript" src="build/LogoWidget.js"></script> 
    <script type="text/javascript" src="build/PictureWidget.js"></script> 
    <script type="text/javascript" src="build/LegendWidget.js"></script> 
    <script type="text/javascript" src="build/StatisticsWidget.js"></script> 
    <script type="text/javascript" src="build/ControlButtonArea.js"></script> 
    <script type="text/javascript" src="build/Help.js"></script> 
    <script type="text/javascript" src="build/ZoomButtons.js"></script> 
    <script type="text/javascript" src="build/FullscreenButton.js"></script> 
    <script type="text/javascript" src="build/HiventPresenter.js"></script> 
    <script type="text/javascript" src="build/HiventsOnMap.js"></script> 
    <script type="text/javascript" src="build/HiventsOnGlobe.js"></script> 
    <script type="text/javascript" src="build/HiventsOnTimeline.js"></script> 
    <script type="text/javascript" src="build/HiventTooltips.js"></script> 
    <script type="text/javascript" src="build/HiventInfoPopover.js"></script> 
    <script type="text/javascript" src="build/HiventInfoPopovers.js"></script> 
    <script type="text/javascript" src="build/HiventInfoAtTag.js"></script> 
    <script type="text/javascript" src="build/HiventGalleryWidget.js"></script> 
    <script type="text/javascript" src="build/HiventStory.js"></script> 
    <script type="text/javascript" src="build/HistoGlobe.js"></script> 
    <script type="text/javascript" src="build/CategoryIconMapping.js"></script> 
    <script type="text/javascript" src="build/Path.js"></script> 
    <script type="text/javascript" src="build/PathController.js"></script> 
    <script type="text/javascript" src="build/LinearPath2D.js"></script> 
    <script type="text/javascript" src="build/ArcPath2D.js"></script> 
    <script type="text/javascript" src="build/Watermark.js"></script> 
    <script type="text/javascript" src="build/BrowserDetector.js"></script> 
    <script type="text/javascript" src="build/Globe.js"></script> 
    <script type="text/javascript" src="build/CategoryFilter.js"></script> 
    <script type="text/javascript" src="build/WidgetController.js"></script> 
    <script type="text/javascript" src="build/ZoomButtonsTimeline.js"></script> 
    <-- init histoglobe --> 
    <?php } else { ?> 
    <script type="text/javascript" src="script/histoglobe.min.js"></script> 
    <?php } ?> 
    <?php // init histoglobe ?> 
    <script type="text/javascript"> 
      $(document).ready(function($) { 
        // $CURRENT_PROJECT_PATH$ is set by make.sh 
        var histoglobe = new HG.HistoGlobe("config/<?php echo $config_path?>/modules.json"); 
      }); 
    </script> 
  </head> 
  <body> 
    <-- display warning if no javascript is available --> 
    <noscript> 
      <div class="container"> 
        <div class="jumbotron" style="margin-top:5%"> 
          <h1><span class="hg">HistoGlobe</span> benötigt Javascript</h1> 
          <p>Bitte aktivieren Sie in Ihrem Browser Javascript, da <span class="hg">HistoGlobe</span> sonst nicht funktioniert.</p> 
          <p><a href="http://www.enable-javascript.com/de/" class="btn btn-primary btn-lg" role="button">Wie aktiviere ich Javascript?</a></p> 
        </div> 
      </div> 
    </noscript> 
    <div id="histoglobe"></div> 
  </body> 
  <//fonts.googleapis.com/css?family=Marcellus+SC' rel='stylesheet' type='text/css'> --> 
</html> 
