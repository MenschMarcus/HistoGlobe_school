#!/bin/bash

if [ ! -d tmp ]
then
    mkdir tmp
fi

if [ ! -d ../../data/areas ]
then
    mkdir ../../data/areas
fi



if [ ! -f tmp/ne_50m_admin_0_countries.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries.zip
    mv ne_50m_admin_0_countries.zip tmp/
fi

if [ ! -f tmp/ne_50m_admin_0_boundary_lines_land.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_boundary_lines_land.zip
    mv ne_50m_admin_0_boundary_lines_land.zip tmp/
fi

unzip -u tmp/ne_50m_admin_0_countries.zip -d tmp
unzip -u tmp/ne_50m_admin_0_boundary_lines_land.zip -d tmp

#ogr2ogr -f GeoJSON world.json tmp/ne_50m_admin_0_countries.shp
ogr2ogr -f GeoJSON -where "continent IN ('Europe') AND NOT sov_a3 IN ('RUS')" out.json tmp/ne_50m_admin_0_countries.shp
mv out.json ../../data/areas/countries.json

ogr2ogr -f GeoJSON out.json tmp/ne_50m_admin_0_boundary_lines_land.shp
mv out.json ../../data/areas/boundaries.json

#topojson -o world.json geo.json

