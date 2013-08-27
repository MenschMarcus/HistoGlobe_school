#!/bin/bash

if [ ! -f GRAY_HR_SR_OB.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR_OB.zip
fi

unzip -u GRAY_HR_SR_OB.zip -d data

python mapnik.py
