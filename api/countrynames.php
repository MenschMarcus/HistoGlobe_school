<?php

header("Content-Type: application/json; charset=utf-8");

ob_start("ob_gzhandler");


require_once("db.php");
require_once("featurecollection.php");


$db = new DataBase();

// Display detailed info on errors
error_reporting(E_ALL);
ini_set('display_errors', '1');

$zoom = 6;
// Get zoom level or set default
if (isset($_GET['zoom']) && $_GET['zoom'] != '')
{
   	$zoom = $_GET['zoom'];
}
else
{
 	$zoom = 5;
}

if (isset($_GET['now']) && $_GET['now'] != '') {
    $result = $db->getCountryNamesByTime($_GET['now']);

    $featurecollection = new FeatureCollection();
    foreach ($result->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $featurecollection->add(countryNamePoint($row,$zoom));
    }
    echo $featurecollection -> makeFC();
}

function countryNamePoint($obj, $zoom) {
	$vals = array();
	$geojson  = '{"type":"Feature",';
	$geojson .= '"geometry":{ "type":"Text", "coordinates":['.$obj['nameLong'].',' .$obj['nameLat'].']},';
	$geojson .= '"properties": {';
  $exclude = array();
  $list = array();
  foreach ($obj as $key => $val) {
    if (isset($exclude[$key])) continue;
      $list[] = '"'.$key.'":"'.str_replace('"','\\"',$val).'"';
  }
  $geojson .= implode(',', $list);
	$geojson .= ',"zoom":"'. $zoom .'"}';
	$geojson .= '}'; // end of object
	return $geojson;
}


