@echo off
call "D:\Drafts\Code\NodeJS\nodevars.bat"

@echo off
call "data_src\hivents\generate.bat"

@echo off
call "data_src\labels\generate.bat"

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
<<<<<<< HEAD
        script/timeline/Timeline.coffee ^
        script/timeline/YearMarker.coffee ^
=======
        script/labels/Label.coffee ^
        script/labels/LabelController.coffee ^
>>>>>>> origin/develop
        script/hivents/HiventHandle.coffee ^
        script/hivents/HiventController.coffee ^
        script/hivents/Hivent.coffee ^
        script/hivents/HiventMarker.coffee ^
        script/hivents/HiventMarker2D.coffee ^
        script/hivents/HiventMarker3D.coffee ^
        script/hivents/HiventMarkerTimeline.coffee ^
        script/hivents/HiventInfoPopover.coffee ^
        script/timeline/NowMarker.coffee ^
        script/timeline/DoublyLinkedList.coffee

@echo off
set jFiles=build/Mixin.js ^
        build/CallbackContainer.js ^
        build/Display.js ^
        build/Display2D.js ^
        build/Display3D.js ^
        build/Area.js ^
        build/AreaController.js ^
<<<<<<< HEAD
        build/Timeline.js ^
        build/YearMarker.js ^
=======
        build/Label.js ^
        build/LabelController.js ^
>>>>>>> origin/develop
        script/timeline/Timeline.js ^
        build/Hivent.js ^
        build/HiventHandle.js ^
        build/HiventController.js ^
        build/HiventMarker.js ^
        build/HiventMarker2D.js ^
        build/HiventMarker3D.js ^
        build/HiventMarkerTimeline.js ^
        build/HiventInfoPopover.js ^
        build/Vector.js ^
        build/VideoPlayer.js ^
        script/util/BrowserDetect.js ^
        build/NowMarker.js ^
        build/DoublyLinkedList.js

IF not exist build ( mkdir build )

coffee -c -o build %cFiles% && uglifyjs %jFiles% -o script\histoglobe.min.js && lessc --no-color -x style\main.less style\histoglobe.min.css
