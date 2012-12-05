<?php
	error_reporting(E_ALL);
	ini_set('display_errors', '1');

require_once('array_reduce.php');

/**
 * Returns an array of points containing the points from the SVG (given as a string).
 * This string will be serialized, so (apparently) commas should be avoided or escaped.
 * $zoom: zoom level
 * $force: point forcing, i.e. this SVG is important so force points to appear that otherwise wouldn't
 */ 

function getPointsFromSVGString($svgstring, $zoom, $force) {
	// read in xml doc structure 
	$svgxml = new SimpleXMLElement($svgstring);
	

	// split by whitespace
	$multilines = array();
	
	foreach ($svgxml->g->polyline as $key => $val) {
		$points = preg_split("/\s+/", trim($val->attributes()->points));
		
		$enclosed = false;
		// assume circular path = island
		if ($points[0] == $points[count($points)-1]) $enclosed = true;
		
		// skip if unreduced island has very few points, unless forced
		if (!$force && (8-$zoom)*2 > count($points)) continue;
		
		foreach ($points as $key => $val) {
			$points[$key] = preg_split("/,/", trim($val));
		}
		
		// reduce points in array, give a lower factor if forced
	    $points = reduce_array_merc2($points, $zoom, $force?1:2);
	    
	    // skip if reduced island has few points, unless forced
	    if (!$force && count($points) < pow((9-$zoom),1.5) && $enclosed) {
	    	continue;
	    }
		$multilines[] = $points;
	}
	return $multilines;
}



