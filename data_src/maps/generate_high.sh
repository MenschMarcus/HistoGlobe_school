#!/bin/bash

if [ ! -d tmp ]
then
    mkdir tmp
fi

if [ ! -f tmp/GRAY_HR_SR_OB.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR_OB.zip
    mv GRAY_HR_SR_OB.zip tmp/
fi

unzip -u tmp/GRAY_HR_SR_OB.zip -d tmp



if [ ! -f tmp/ne_10m_land.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_land.zip
    mv ne_10m_land.zip tmp/
fi

unzip -u tmp/ne_10m_land.zip -d tmp


if [ ! -f tmp/ne_10m_graticules_10.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_graticules_10.zip
    mv ne_10m_graticules_10.zip tmp/
fi

unzip -u tmp/ne_10m_graticules_10.zip -d tmp


MAPNIK_MAP_FILE=high.xml python mapnik.py
