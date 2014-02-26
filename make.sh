#!/bin/bash

(cd data_src/hivents/; ./generate.sh)

(cd data_src/labels/; ./generate.sh)

(cd data_src/paths/; ./generate.sh)

if [ ! -d "build" ]; then
    mkdir build
else
    rm build/*
fi

rosetta --jsOut "build/config.js" \
        --jsFormat "flat" \
        --jsTemplate $'var HGConfig;\n(function() {\n<%= preamble %>\nHGConfig = <%= blob %>;\n})();' \
        --cssOut "build/config.less" \
        --cssFormat "less" config/sdw/style.rose

jFiles=$(find build -name '*.js')
cFiles=$(find script -name '*.coffee')

coffee -c -o build $cFiles

uglifyjs $jFiles -o script/histoglobe.min.js #-mc

lessc --no-color -x style/histoglobe.less style/histoglobe.min.css
