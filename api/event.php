<?php
        error_reporting(E_ALL);
        ini_set('display_errors', '1');

class event{

    static $exclude = array('abstract' => 1);
    
	function eventFC ($row, $zoom)
	{	
        		
		$geojson = "";
		// GeoJson output: main part
		$geojson =  '{"type":"Feature",';
		// TODO flip lat/lon !
		$geojson .=  '"geometry":{ "type":"Point", "coordinates":['.$row['lon'].',' .$row['lat'].']},';
		
		$geojson .=  '"properties": {';
		
		$list = array();
		foreach ($row as $key => $val) {
		    if (isset(self::$exclude[$key])) continue;
            $list[] = '"'.$key.'":"'.str_replace('"','\\"',$val).'"';
        }
		$geojson .= implode(',', $list);
		$geojson .=   	',"zoom":"'.$zoom.'"}';
		$geojson .=  '}'; // end of object
		return $geojson;
	}
}
