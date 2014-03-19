#!/bin/bash

OUTPUT_DIR=$1

if [ ! $OUTPUT_DIR ]; then
    echo "Specify output directory name!"
    exit
fi

if [ ! -d $OUTPUT_DIR ]; then
    mkdir $OUTPUT_DIR
fi

####################################################
#copy scripts
####################################################
if [ ! -d $OUTPUT_DIR/script ]; then
    mkdir $OUTPUT_DIR/script
fi

#use histoglobe.min.js if existing
if [ -f script/histoglobe.min.js ]; then
    cp script/histoglobe.min.js $OUTPUT_DIR/script
else
    echo "histoglobe.min.js does not exist! Aborting."
    exit
fi

cp script/index.html $OUTPUT_DIR/script/
cp -r script/third-party $OUTPUT_DIR/script/

####################################################
#copy styles
####################################################
if [ ! -d $OUTPUT_DIR/style ]; then
    mkdir $OUTPUT_DIR/style
fi

#use histoglobe.min.css if existing
if [ -f style/histoglobe.min.css ]; then
    cp style/histoglobe.min.css $OUTPUT_DIR/style
else
    echo "histoglobe.min.css does not exist! Aborting."
    exit
fi

cp style/index.html $OUTPUT_DIR/style/
cp -r style/third-party $OUTPUT_DIR/style/

####################################################
#copy data
####################################################
cp -r data $OUTPUT_DIR/

####################################################
#copy config
####################################################
cp -r config $OUTPUT_DIR/

####################################################
#copy fonts
####################################################
cp -r font $OUTPUT_DIR/

####################################################
#copy intdex.php
####################################################
cp index.php $OUTPUT_DIR/
