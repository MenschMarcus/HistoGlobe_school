#!/bin/bash

cFiles="script/display/Display3D.coffee \
        script/display/Display.coffee"

jFiles="build/Display.js \
        script/display/Display2D.js \
        build/Display3D.js \
        script/timeline/Timeline.js \
        script/histrips/Histrip.js \
        script/histrips/HistripHandle.js \
        script/histrips/HistripHandler.js \
        script/histrips/HistripMarker.js \
        script/hivents/Hivent.js \
        script/hivents/HiventHandle.js \
        script/hivents/HiventHandler.js \
        script/hivents/HiventMarker.js \
        script/hivents/HiventMarker2D.js \
        script/hivents/HiventMarker3D.js \
        script/hivents/HiventMarkerTimeline.js \
        script/util/VideoPlayer.js \
        script/util/BrowserDetect.js"

mkdir build

coffee -c -o build $cFiles

uglifyjs $jFiles -o script/histoglobe.min.js #-mc

xdg-open http://localhost/HistoGlobe
