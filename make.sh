#!/bin/bash

(cd data_src/hivents/; ./generate.sh)
(cd data_src/labels/; ./generate.sh)

cFiles="script/util/Mixin.coffee \
        script/util/CallbackContainer.coffee \
        script/util/VideoPlayer.coffee \
        script/util/Vector.coffee \
        script/display/Display3D.coffee \
        script/display/Display2D.coffee \
        script/display/Display.coffee \
        script/areas/Area.coffee \
        script/areas/AreaController.coffee \
        script/timeline/Timeline.coffee \
        script/timeline/YearMarker.coffee \
        script/labels/Label.coffee \
        script/labels/LabelController.coffee \
        script/hivents/HiventHandle.coffee \
        script/hivents/HiventController.coffee \
        script/hivents/Hivent.coffee \
        script/hivents/HiventMarker.coffee \
        script/hivents/HiventMarker2D.coffee \
        script/hivents/HiventMarker3D.coffee \
        script/hivents/HiventMarkerTimeline.coffee \
        script/hivents/HiventInfoPopover.coffee \
        script/timeline/NowMarker.coffee \
        script/timeline/DoublyLinkedList.coffee"

jFiles="build/Mixin.js \
        build/CallbackContainer.js \
        build/Display.js \
        build/Display2D.js \
        build/Display3D.js \
        build/Area.js \
        build/AreaController.js \
        build/Timeline.js \
        build/YearMarker.js \
        build/Label.js \
        build/LabelController.js \
        script/timeline/Timeline.js \
        build/Hivent.js \
        build/HiventHandle.js \
        build/HiventController.js \
        build/HiventMarker.js \
        build/HiventMarker2D.js \
        build/HiventMarker3D.js \
        build/HiventMarkerTimeline.js \
        build/HiventInfoPopover.js \
        build/Vector.js \
        build/VideoPlayer.js \
        script/util/BrowserDetect.js \
        build/NowMarker.js \
        build/DoublyLinkedList.js"

if [ ! -d "build" ]; then
    mkdir build
fi

coffee -c -o build $cFiles

uglifyjs $jFiles -o script/histoglobe.min.js #-mc

lessc --no-color -x style/main.less style/histoglobe.min.css


