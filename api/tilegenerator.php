<?php
	
	header("Content-Type: application/json; charset=utf-8");
	
	ob_start("ob_gzhandler");


	// Display detailed info on errors
	error_reporting(E_ALL);
	ini_set('display_errors', '1');
 
  // All files required
	require_once("db.php");
	require_once("convert.php");
	require_once("featurecollection.php");
	require_once("event.php");
	require_once("cache.php");
	require_once("perf.php");

	// This gets included in filenams and ETag as a
	// simple way of keeping track if caches are stale.
	// Increase the number when changing the database, or
	// the way borders are output to force cache refresh.
	$cache_version = "v1v";
	
	// Create a feature collection object
	$featurecollection = new FeatureCollection();

	// Create a database object
	$db = new DataBase();
	
	// Get zoom level or set default
	if (isset($_GET['zoom']) && $_GET['zoom'] != '')
	{
        $zoom = $_GET['zoom'];
    }
		else
	{
        $zoom = 6;
    }

	// Get parameters from the URL and create features depending on the case
	switch($_GET['layer'])
	{
		case 'borders':
			if (isset($_GET['now']) && $_GET['now'] != '')
			{
				$now = $_GET["now"];

				$_pf->start('testcanon'); // timing checks for testing
				// Test if the date is canonical
				$canonicalTime = $db->checkCanonicalDate($now);
				$_pf->stop('testcanon');
				
				// If not, redirect the browser to try again
				if ($canonicalTime != $now) 
				{
					$poid = '';
					if (isset($_GET['poid']))
						$poid = '&poid=' + $_GET['poid'];
					header("Location: tilegenerator.php?layer=borders&now=" . $canonicalTime . "&zoom=" . $zoom . $poid);
					exit();
				}
				
				// date is canonical, allow browser to cache the result by
				// setting browser caching directives
				$ETag = "Cache_" . $cache_version . "_borders_" . "z$zoom" . "t$now";
				header("ETag: $ETag");
				header("Last-Modified: Tue, 15 Nov 1994 12:45:26 GMT");

				// Open the existing file and read the content
				$content = getCache($ETag);
				if ($content !== FALSE && !isset($_GET['nocache']))
				{
					echo $content;
					exit();
				}
				else
				{ // If no file has been created yet and we need to load the data
					$_pf->start('getborders');
					$result = $db->getborders($now);
					$_pf->stop('getborders');
					
					// For each row received convert SVG to geoJSON and create a feature of the result
					while ($row = $result->fetch(PDO::FETCH_ASSOC))
					{

						$_pf->start('convert_tot');
						$something = convert($row, $zoom);
						$_pf->stop('convert_tot');
						
						// Create a feature with the coordinates
						$featurecollection->add($something);
					}
					
					// fetch adminUnit list
					$aus = array();
					foreach ($db->getAdminUnits($now) as $val) {
					    $cols = array();
					    foreach($val as $key => $val) {
					        array_push($cols, '"'.$key.'":"'.$val.'"');
					    }
					    array_push($aus,'{' . implode(',', $cols) . "}\n");
					}
					
					$featurecollection -> addExtra('adminUnits','[' . implode(',', $aus) . ']');
					
					// Create the feature collection
					$fc = $featurecollection -> makeFC();
					
					// Create a new file
					$createNewFile = writeCache($ETag, $fc);
					
					// If we can't write a new file containing the feature collection then we send an error
					if ($createNewFile =! true)
					{
						echo ("An error occured!!!");
					}
					// Else we send the feature collection
					else
					{
						echo $fc;
					}
				}
			}
			break;
			
		case 'events':	
			if (isset($_GET['start']) && $_GET['start'] != '' && isset($_GET['end']) && $_GET['end'] != '') 
			{   
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

				$start = $_GET["start"];
				$end = $_GET["end"];
				// only search if something is selected
				if ($soc != "0" || $dom != "0" || $for != "0") {
				    // Get events
				    $result = $db->getevent($start, $end, $soc, $dom, $for);

				    // For each row received, create a geoJSON feature of the result
				    while ($row = $result->fetch(PDO::FETCH_ASSOC))
				    {
					    $something = event::eventFC($row, $zoom);
					    // Create a feature with the coordinates
					    $featurecollection->add($something); 
				    }
				}
			}
			$fc = $featurecollection -> makeFC();
			echo $fc;
			break;
			
		default:
			// no such layer, send empty FC
			echo $featurecollection-> makeFC();
			break;
	}
	
