#!/bin/bash

if [ ! -d tmp ]
then
    mkdir tmp
fi

if [ ! -f tmp/HYP_LR_SR_OB_DR.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/HYP_LR_SR_OB_DR.zip
    mv HYP_LR_SR_OB_DR.zip tmp/
fi

unzip -u tmp/HYP_LR_SR_OB_DR.zip -d tmp


if [ ! -f tmp/ne_50m_land.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/physical/ne_50m_land.zip
    mv ne_50m_land.zip tmp/
fi

unzip -u tmp/ne_50m_land.zip -d tmp


if [ ! -f tmp/ne_10m_graticules_10.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_graticules_10.zip
    mv ne_10m_graticules_10.zip tmp/
fi

unzip -u tmp/ne_10m_graticules_10.zip -d tmp


MAPNIK_MAP_FILE=rules.xml python render.py

