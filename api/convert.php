<?php

	require_once('svg.php');
	require_once('cache.php');
	// Example of SVG input: <polyline fill="none" stroke='#FF00FF' stroke-width="0.1" points="28,69 28,68 30,67 29,66 31,62 27,60" />

	function convert($row, $zoom) {
		
		// Variables
		$country1 = $row['au1'];
		$country2 = $row['au2'];

		$file = $row['borderFile'];

		
		// see if we've already cached this path array @ zoom
		$cachename = 'SVG_' . $file . "_zoom" .$zoom;
		$read = getCache($cachename);
		if ($read === FALSE || isset($_GET['nocache']))
		{
			// cache miss: load svg file, reduce points
			// and serialize + write
			$svgfilename = '../borders/' . $file . '.svg';
			if (file_exists($svgfilename))
			{
				$svgstring = file_get_contents($svgfilename);
				// Contains coordinates from SVGstring in a multidim array
				// Note to future: be careful with commas in any strings that get serialized
				// json_encode only available in 5.3
				$linestrings = getPointsFromSVGString($svgstring, $zoom, $country2 != null);
				writeCache($cachename,serialize($linestrings));
			}
			else
			{
				// svg file not found, continue with no points
				$linestrings = array();
			}

		} else {
			// cache hit, unserialize it
			$linestrings = unserialize($read);
		}


		// Output: wrap in geoJSON syntax
		$geojson = "";
		
		// main part
		$geojson =  '{"type":"Feature",';
		$geojson .=  '"properties":{';
		
		$exclude = array('borderFile' => 1);
    	$list = array();
		foreach ($row as $key => $val) {
		    if (isset($exclude[$key])) continue;
            $list[] = '"' . $key . '":"'.str_replace('"','\\"',$val).'"';
        }
        $geojson .= implode(',', $list);
        $geojson .= ',"zoom":"' . $zoom . '"},';
        
		// points
		$geojson .=  '"geometry":{ "type":"MultiLineString", "coordinates":[';
		$converts = array();
        foreach ( $linestrings as $idx => $linestring) {
            $tmp =  '[';
            
    		// Each point is currently an array [x,y]	
    		// Wrap each point in brackets
    		for ($i=0; $i<count($linestring); $i++) {
	    		
    			$linestring[$i] = '['. $linestring[$i][0].','. $linestring[$i][1] .']';
    		}
    		
    		// Add commas between points
    		$tmp .=  implode(",", $linestring);
    		$tmp .=  ']';
    		array_push($converts,$tmp);
		}
		// add commans between point arrays
   		$geojson .=  implode(",", $converts);		
		// Add last brackets
		$geojson .= ']}}';
		
		return $geojson;
	}

	function bracketize($a) {
		return '[' . $a[0] .','. $a[1] . ']';
	}

