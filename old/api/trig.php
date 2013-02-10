<?php

// spherical trigonometry

 // angle of p2
function sphAngle($p1,$p2,$p3) {
	$b = greatDist($p2,$p3);
	$a = greatDist($p2,$p1);
	$c = greatDist($p1,$p3);
	return sphAngleSides($a,$b,$c);
}

// angle opposite c
function sphAngleSides($a,$b,$c) {
	if ($a == 0 || $b == 0 || $c == 0)
		return pi()/2;
	return acos((cos($c) - cos($a)*cos($b))/(sin($a)*sin($b)));
}

//law of cosines
function greatDist($p1,$p2) {
	$lon1 = deg2rad($p1[0]);
	$lat1 = deg2rad($p1[1]);
	$lon2 = deg2rad($p2[0]);
	$lat2 = deg2rad($p2[1]);
	$lond = abs($lon1-$lon2);
	return acos(sin($lat1) * sin($lat2) + cos($lat1)* cos($lat2) * cos($lond));
}

// haversine
function greatDist_haversine($p1,$p2) {
	$lon1 = deg2rad($p1[0]);
	$lat1 = deg2rad($p1[1]);
	$lon2 = deg2rad($p2[0]);
	$lat2 = deg2rad($p2[1]);
	return 2 * asin(sqrt( pow(sin(abs($lat1-$lat2)/2),2)
					+ cos($lat1) * cos($lat2) * pow(sin(abs($lon1-$lon2)/2),2) ));
}

// Vincenty
function greatDist_vincenty($p1,$p2) {
	$lon1 = deg2rad($p1[0]);
	$lat1 = deg2rad($p1[1]);
	$lon2 = deg2rad($p2[0]);
	$lat2 = deg2rad($p2[1]);
	$lond = abs($lon1-$lon2);
	$y = sqrt(
		pow(cos($lat2)*sin($lond),2) +
		pow(cos($lat1) * sin($lat2) - sin($lat1) * cos($lat2)*cos($lond),2)
	);
	$x = sin($lat1)*sin($lat2)+cos($lat1)*cos($lat2)*cos($lond);
	return atan2($y,$x);
}

// cartesian trigonometry

function dist($a, $b) {
	$x = $b[0] - $a[0];
	$y = $b[1] - $a[1];
	return sqrt($x * $x + $y * $y);
}

// angle of p2
function cartAngle($p1,$p2,$p3) {
	$c = dist($p3,$p1);
	$a = dist($p1,$p2);
	$b = dist($p2,$p3);
	return cartAngleSides($a,$b,$c);
}

// angle opposite c
function cartAngleSides($a,$b,$c) {
	if ($a == 0 || $b == 0 || $c == 0)
		return pi()/2;
	return acos((pow($a,2) + pow($b,2) - pow($c,2)) / (2 * $a * $b));
}


// mercator projection
function toMerc($ll)
{
	$lon = $ll[0];
	$lat = $ll[1];
	$x = $lon * 20037508.34 / 180;
	$y = -180;
	if($lat>-90)
		$y = log(tan((90 + $lat) * M_PI / 360)) / (M_PI / 180);
	$y = $y * 20037508.34 / 180; 
	return array($x, $y);
}

// mercator indicatrix ratio for latitude/equator
function mercMagnificationFactor($lat)
{
    $eq1 = (log(tan(90 * M_PI / 360)) / (M_PI / 180)) * 20037508.34 / 180;
    // using 0.01 degrees (1.12km) as yardstick
    $eq2 = (log(tan(90.01 * M_PI / 360)) / (M_PI / 180)) * 20037508.34 / 180;

    $lat = abs($lat);
	$y1 = log(tan((90 + abs($lat)) * M_PI / 360)) / (M_PI / 180);
	$y1 = $y1 * 20037508.34 / 180;
	
	$y2 = log(tan((90 + abs($lat) + 0.01) * M_PI / 360)) / (M_PI / 180);
	$y2 = $y2 * 20037508.34 / 180;
	
	return ($y1 - $y2) / ($eq1 - $eq2);
}

function inverseMerc ($xy)
{
	$lon = ($xy[0] / 20037508.34) * 180;
	$lat = ($xy[1] / 20037508.34) * 180;

	$lat = 180/pi() * (2 * atan(exp($lat * pi() / 180)) - pi() / 2);
	return array($lon, $lat);
}


/**
 * Returns array with (longitude,latitude,height,width) for a tile at (x,y,zoom)
 * Ported from java, modified slightly
 */
function getLatLong($x, $y, $zoom) {
      $tilesAtThisZoom = 1 << ($zoom);
      $lonWidth  = 360.0 / $tilesAtThisZoom;
      $lon       = -180 + ($x * $lonWidth);
      $latHeight = -2.0 / $tilesAtThisZoom;
      $lat       = 1 + ($y * $latHeight);
      // convert lat and latHeight to degrees in a mercator projection
      // note that in fact the coordinates go from
      // about -85 to +85 not -90 to 90!
      $latHeight += $lat;
      $latHeight = (2 * atan(exp(pi() * $latHeight))) - (pi() / 2);
      $latHeight *= (180 / pi());
      $lat = (2 * atan(exp(pi() * $lat))) - (pi() / 2);
      $lat *= (180 / pi());
      $latHeight -= $lat;

      if ($latHeight < 0) { 
         $lat       = $lat + $latHeight; 
         $latHeight = -$latHeight; 
      } 
      return array($lon, $lat, $lonWidth, $latHeight); 
} 

// original function, probably no use for it
function getLatLongOriginal($x, $y, $zoom) { 
      $lon      = -180; // x 
      $lonWidth = 360; // width 360 
      //double lat = -90;  // y 
      //double latHeight = 180; // height 180 
      $lat       = -1; 
      $latHeight = 2; 
      $tilesAtThisZoom = 1 << (17 - $zoom); 
      $lonWidth  = 360.0 / $tilesAtThisZoom; 
      $lon       = -180 + ($x * $lonWidth); 
      $latHeight = -2.0 / $tilesAtThisZoom; 
      $lat       = 1 + ($y * $latHeight); 
      // convert lat and latHeight to degrees in a mercator projection 
      // note that in fact the coordinates go from 
      // about -85 to +85 not -90 to 90! 
      $latHeight += $lat; 
      $latHeight = (2 * atan(exp(pi() * $latHeight))) - (pi() / 2); 
      $latHeight *= (180 / pi()); 
      $lat = (2 * atan(exp(pi() * $lat))) - (pi() / 2); 
      $lat *= (180 / pi()); 
      $latHeight -= $lat; 
      if ($lonWidth < 0) { 
         $lon      = $lon + $lonWidth; 
         $lonWidth = -$lonWidth; 
      } 
      if ($latHeight < 0) { 
         $lat       = $lat + $latHeight; 
         $latHeight = -$latHeight; 
      } 
      return array($lon, $lat, $lonWidth, $latHeight); 
}

