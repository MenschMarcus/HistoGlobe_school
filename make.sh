#!/bin/bash

PROJECT=exemplum

(cd data_src/hivents/; ./generate.sh)

(cd data_src/labels/; ./generate.sh)

(cd data_src/paths/; ./generate.sh)

if [ ! -d "build" ]; then
    mkdir build
else
    rm build/*
fi

rosetta --jsOut "build/default_config.js" \
        --jsFormat "flat" \
        --jsTemplate $'var HGConfig;\n(function() {\n<%= preamble %>\nHGConfig = <%= blob %>;\n})();' \
        --cssOut "build/default_config.less" \
        --cssFormat "less" config/common/default.rose

rosetta --jsOut "build/config.js" \
        --jsFormat "flat" \
        --jsTemplate $'(function() {\n<%= preamble %>\n $.extend(HGConfig, <%= blob %>);\n})();' \
        --cssOut "build/config.less" \
        --cssFormat "less" config/$PROJECT/style.rose

cFiles=$(find script -name '*.coffee')

coffee -c -o build $cFiles

jFiles=$(find build -name '*.js')

uglifyjs $jFiles -o script/histoglobe.min.js #-mc

LESS_MAIN=style/histoglobe.less

if [ -e "config/$PROJECT/custom.less" ]; then
    LESS_MAIN=config/$PROJECT/custom.less
fi

lessc --no-color -x $LESS_MAIN style/histoglobe.min.css

sed -i "2s/.*/<?php \$config_path = '$PROJECT'; ?>/" index.php
