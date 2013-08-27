#!/bin/bash

ogr2ogr -f GeoJSON geo.json shape_files/ne_50m_admin_0_countries.shp
#ogr2ogr -f GeoJSON -where "sov_a3 IN ('DEU', 'GB1')" geo.json shape_files/ne_50m_admin_0_countries.shp
topojson -o world.json geo.json
