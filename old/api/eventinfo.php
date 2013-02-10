<?php

//header("Content-Type: application/json; charset=utf-8");
//ob_start("ob_gzhandler");

require_once('db.php');

$db = new DataBase();

// Display detailed info on errors
error_reporting(E_ALL);
ini_set('display_errors', '1');

$zoom = 4;
if (isset($_GET['zoom']) && $_GET['zoom'] != '') {
    $zoom = $_GET['zoom'];
}
// categories turned off by default
if (isset($_GET['social'])) {
    $soc = $_GET['social'];
} else {
    $soc = "0";
}
if (isset($_GET['foreign'])) {
    $for = $_GET['foreign'];
} else {
    $for = "0";
}
if (isset($_GET['domestic'])) {
    $dom = $_GET['domestic'];
} else {
    $dom = "0";
}

if (isset($_GET['eventid']) && $_GET['eventid'] != '') {
	if (!isset($_GET['start'])) { // return just the one event by id
	    $result = $db->getEventById($_GET['eventid']);
	} else {
	    $result = $db->getEventsById($_GET['eventid'], $_GET['start'], $_GET['end'], $zoom, $soc, $dom, $for);
    }
    $output ="[";

    $evlist = array();
    foreach ($result as $key => $val) {
        $list = array();
        foreach ($val as $key => $val) {
            $list[] = '"'.$key.'":"'.str_replace('"','\\"',$val).'"';
        }
        $evlist[] = '{' . implode(",", $list) . '}';
    }
    $output .= implode(",\n", $evlist);
    $output .= "]";
    print  $output;
}
