@echo off
call "D:\Drafts\Code\NodeJS\nodevars.bat"

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
        script/sidebar/PictureWidget.coffee ^
        script/util/Mixin.coffee ^
        script/util/CallbackContainer.coffee ^
        script/util/VideoPlayer.coffee ^
        script/util/Vector.coffee ^
        script/display/Display3D.coffee ^
        script/display/Display2D.coffee ^
        script/display/Display.coffee ^
        script/areas/Area.coffee ^
        script/areas/AreaController.coffee ^
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
        script/timeline/NowMarker.coffee ^
        script/timeline/DoublyLinkedList.coffee ^
        script/legend/Legend.coffee ^
        script/hivents/HiventInfoPopover.coffee ^
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
        build/PictureWidget.js ^
        build/Mixin.js ^
        build/CallbackContainer.js ^
        build/Display.js ^
        build/Display2D.js ^
        build/Display3D.js ^
        build/Area.js ^
        build/AreaController.js ^
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
        build/Legend.js ^
        build/HiventInfoPopover.js ^
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

coffee -c -o build %cFiles% && uglifyjs %jFiles% -o script\histoglobe.min.js && lessc --no-color -x style\histoglobe.less style\histoglobe.min.css
