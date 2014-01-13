@echo off
call "C:\Program Files\nodejs\nodevars.bat"

@echo off
call "data_src\hivents\generate.bat"

@echo off
call "data_src\labels\generate.bat"

@echo off
call "data_src\pahts\generate.bat"

@echo off
set cFiles=script/util/Mixin.coffee ^
        script/util/CallbackContainer.coffee ^
        script/util/VideoPlayer.coffee ^
        script/util/Vector.coffee ^
        script/display/Display3D.coffee ^
        script/display/Display2D.coffee ^
        script/display/Display.coffee ^
        script/areas/Area.coffee ^
        script/areas/AreaController.coffee ^
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
        script/legend/Legend.coffee ^
        script/hivents/HiventInfoPopover.coffee ^
        script/paths/Path.coffee ^
        script/paths/ArcPath2D.coffee ^
        script/paths/PathController.coffee ^
        script/paths/LinearPath2D.coffee ^
        script/paths/ArcPath2D.coffee

@echo off
set jFiles=build/Mixin.js ^
        build/CallbackContainer.js ^
        build/Display.js ^
        build/Display2D.js ^
        build/Display3D.js ^
        build/Area.js ^
        build/AreaController.js ^
        build/Label.js ^
        build/LabelController.js ^
        script/timeline/Timeline.js ^
        build/Hivent.js ^
        build/HiventHandle.js ^
        build/HiventBuilder.js ^
        build/HiventDatabaseInterface.js ^
        build/HiventController.js ^
        build/HiventMarker.js ^
        build/HiventMarker2D.js ^
        build/HiventMarker3D.js ^
        build/HiventMarkerTimeline.js ^
        build/HiventInfoPopover.js ^
        build/legend/Legend.js ^
        build/Path.js ^
        build/LinearPath2D.js ^
        build/ArcPath2D.js ^
        build/PathController.js ^
        build/Vector.js ^
        build/VideoPlayer.js ^
        script/util/BrowserDetect.js

IF not exist build ( mkdir build )

coffee -c -o build %cFiles% && uglifyjs %jFiles% -o script\histoglobe.min.js && lessc --no-color -x style\main.less style\histoglobe.min.css
