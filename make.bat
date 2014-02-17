@echo off
call "C:\Program Files\nodejs\nodevars.bat"

@echo off
call "data_src\hivents\generate.bat"

@echo off
call "data_src\labels\generate.bat"

@echo off
call "data_src\paths\generate.bat"

@echo off
set cFiles=script/HistoGlobe.coffee ^
        script/sidebar/Sidebar.coffee ^
        script/sidebar/Widget.coffee ^
        script/sidebar/TextWidget.coffee ^
        script/sidebar/GalleryWidget.coffee ^
        script/sidebar/TimeGalleryWidget.coffee ^
        script/sidebar/VIPWidget.coffee ^
        script/sidebar/LogoWidget.coffee ^
        script/sidebar/PictureWidget.coffee ^
        script/sidebar/LegendWidget.coffee ^
        script/util/Mixin.coffee ^
        script/util/CallbackContainer.coffee ^
        script/util/VideoPlayer.coffee ^
        script/util/Vector.coffee ^
        script/display/Globe.coffee ^
        script/display/Display2D.coffee ^
        script/display/Display.coffee ^
        script/areas/Area.coffee ^
        script/areas/AreaController.coffee ^
        script/areas/AreaIndicator.coffee ^
        script/areas/AreasOnMap.coffee ^
        script/areas/AreasOnGlobe.coffee ^
        script/timeline/Timeline.coffee ^
        script/timeline/YearMarker.coffee ^
        script/labels/Label.coffee ^
        script/labels/LabelController.coffee ^
        script/hivents/HiventHandle.coffee ^
        script/hivents/HiventBuilder.coffee ^
        script/hivents/HiventDatabaseInterface.coffee ^
        script/hivents/HiventController.coffee ^
        script/hivents/Hivent.coffee ^
        script/hivents/HiventMarker.coffee ^
        script/hivents/HiventMarker2D.coffee ^
        script/hivents/HiventMarker3D.coffee ^
        script/hivents/HiventMarkerTimeline.coffee ^
        script/hivents/HiventsOnMap.coffee ^
        script/hivents/HiventsOnTimeline.coffee ^
        script/hivents/HiventTooltips.coffee ^
        script/hivents/HiventInfoPopover.coffee ^
        script/hivents/HiventInfoPopovers.coffee ^
        script/hivents/HiventInfoAtTag.coffee ^
        script/timeline/NowMarker.coffee ^
        script/timeline/DoublyLinkedList.coffee ^
        script/paths/Path.coffee ^
        script/paths/ArcPath2D.coffee ^
        script/paths/PathController.coffee ^
        script/paths/LinearPath2D.coffee

@echo off
set jFiles=build/HistoGlobe.js ^
        build/Sidebar.js ^
        build/Widget.js ^
        build/TextWidget.js ^
        build/GalleryWidget.js ^
        build/TimeGalleryWidget.js ^
        build/VIPWidget.js ^
        build/LogoWidget.js ^
        build/PictureWidget.js ^
        build/LegendWidget.js ^
        build/Mixin.js ^
        build/CallbackContainer.js ^
        build/Display.js ^
        build/Display2D.js ^
        build/Globe.js ^
        build/Area.js ^
        build/AreaController.js ^
        build/AreaIndicator.js ^
        build/AreasOnMap.js ^
        build/Timeline.js ^
        build/YearMarker.js ^
        build/Label.js ^
        build/LabelController.js ^
        build/Hivent.js ^
        build/HiventHandle.js ^
        build/HiventBuilder.js ^
        build/HiventDatabaseInterface.js ^
        build/HiventController.js ^
        build/HiventMarker.js ^
        build/HiventMarker2D.js ^
        build/HiventMarker3D.js ^
        build/HiventMarkerTimeline.js ^
        build/HiventsOnMap.js ^
        build/HiventsOnTimeline.js ^
        build/HiventTooltips.js ^
        build/HiventInfoPopover.js ^
        build/HiventInfoPopovers.js ^
        build/HiventInfoAtTag.js ^
        build/Path.js ^
        build/ArcPath2D.js ^
        build/PathController.js ^
        build/LinearPath2D.js ^
        build/Vector.js ^
        build/VideoPlayer.js ^
        script/util/BrowserDetect.js ^
        build/NowMarker.js ^
        build/DoublyLinkedList.js

IF not exist build ( mkdir build )

rosetta --jsOut "build/config.js" ^
        --jsFormat "flat" ^
        --jsTemplate "var HGConfig;(function() {<%%= preamble %%>HGConfig = <%%= blob %%>;})();" ^
        --cssOut "build/config.less" ^
        --cssFormat "less" config/fertility/style.rose && ^
coffee -c -o build %cFiles% && uglifyjs %jFiles% -o script\histoglobe.min.js && ^
lessc --no-color -x style\histoglobe.less style\histoglobe.min.css
