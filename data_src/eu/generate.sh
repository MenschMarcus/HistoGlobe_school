#!/bin/bash

if [ ! -d tmp ]
then
    mkdir tmp
fi

#if [ ! -d ../../data/areas ]
#then
#    mkdir ../../data/areas
#fi



if [ ! -f tmp/ne_50m_admin_0_countries.zip ]
then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries.zip
    mv ne_50m_admin_0_countries.zip tmp/
fi

#if [ ! -f tmp/ne_50m_admin_0_boundary_lines_land.zip ]
#then
#    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_boundary_lines_land.zip
#    mv ne_50m_admin_0_boundary_lines_land.zip tmp/
#fi

unzip -u tmp/ne_50m_admin_0_countries.zip -d tmp
unzip -u tmp/ne_50m_admin_0_boundary_lines_land.zip -d tmp

rm *.json

#ogr2ogr -f GeoJSON world.json tmp/ne_50m_admin_0_countries.shp
# ogr2ogr -f GeoJSON -where "continent IN ('North America')" north_america.json tmp/ne_50m_admin_0_countries.shp
# ogr2ogr -f GeoJSON -where "continent IN ('South America')" south_america.json tmp/ne_50m_admin_0_countries.shp
# ogr2ogr -f GeoJSON -where "continent IN ('Africa')" africa.json tmp/ne_50m_admin_0_countries.shp
# ogr2ogr -f GeoJSON -where "continent IN ('Asia')" asia.json tmp/ne_50m_admin_0_countries.shp
# ogr2ogr -f GeoJSON -where "continent IN ('Europe') AND NOT sov_a3 IN ('RUS')" europe.json tmp/ne_50m_admin_0_countries.shp
#ogr2ogr -f GeoJSON -where "continent IN ('Asia') OR sov_a3 IN ('RUS')" asia.json tmp/ne_50m_admin_0_countries.shp
./ogr2ogr -f GeoJSON -where " sov_a3 IN ('DEU') OR sov_a3 IN ('RUS')" exemplum.json tmp/ne_50m_admin_0_countries.shp

