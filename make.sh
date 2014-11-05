#!/bin/bash

# PROJECT=eu
# PROJECT=exemplum
# PROJECT=fertility
# PROJECT=scandinavia
# PROJECT=sdw
# PROJECT=teaser1_countries
# PROJECT=teaser2_hivents
PROJECT=teaser3_sidebar

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

lessc --no-color -x config/$PROJECT/main.less style/histoglobe.min.css

sed -i "1s/.*/<?php \$config_path = '$PROJECT'; ?>/" config.php
