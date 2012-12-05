<?php

require_once('trig.php');


// not used
function reduce_array_simple($arr, $factor) {
    $factor = min(count($arr) / 8,$factor);
    if ($factor < 1) $factor = 1;
    $res = array();
    foreach (range(0, count($arr) - 2, $factor) as $key) {
        array_push($res, $arr[$key]);
    }
    array_push($res, end($arr));
    
    return $res;
}

// not used
function reduce_array_sph($arr, $fact) {
	$fact = calcFactor($fact);
	$len = count($arr);
	$olddist = greatDist_vincenty($arr[0], $arr[1]);
	
	$dists = array();
	$angles = array();
	$scores = array();
	$pi2 = pi()/2;
	
	for ($i = 1; $i < $len - 1; $i++) {
		$a = $olddist;
		$b = greatDist_vincenty($arr[$i], $arr[$i + 1]);
		$c = greatDist_vincenty($arr[$i - 1], $arr[$i + 1]);
		$dists[$i] = $a + $b;
		$ang = sphAngleSides($a,$b,$c);
		$angles[$i] = $ang < $pi2 ? $ang : pi() - $ang;
		$olddist = $b;
	}
	
	asort($dists);
	arsort($angles);
	foreach(array_keys($dists) as $key => $val) {
		$scores[$val] = $key;
	}
	foreach(array_keys($angles) as $key => $val) {
		$scores[$val] += $key;
	}
	asort($scores);
	
	$sclen = ($len - 2) - (($len - 2)/$fact);
		
	$count = 0;
	$tmparr = $arr;
	foreach ($scores as $key => $val) {
		unset($tmparr[$key]);
		if ($count++ > $sclen)
			break;
	} 
	return $tmparr;
}

/**
 * Reduce array containing spherical coordinates by zoom level and
 * arbitrary unitless factor.
 */
function reduce_array_merc2($arr, $zoom, $fact) {
	// get distance of one pixel at this zoom
	$merc_pixel = 40075016.68 / pow(2,$zoom) / 256;
	
	$len = count($arr);
	
	// reproject to mercator
	for ($i = 0; $i < $len; $i++) {
		$arr[$i] = toMerc($arr[$i]);
	}
	
	// first order brute force reduce: average points based on zoom, path length
	// and overall factor, but taking endpoints as-is
	$avg_factor = max(1,floor((8 - $zoom + 1) * log($len/30) ));
	if ($fact == 1)
		$avg_factor = max(1,floor($avg_factor/4));
	
	if ($avg_factor > 1 && $avg_factor*8<$len) {
		$arr2 = array();
		$arr2[] = $arr[0];
		for ($i = 1; $i < $len - 1; $i++) {
			$x = $arr[$i][0];
			$y = $arr[$i][1];
			$curr = $i;
			$count = 1;
			for ($j = $curr + 1;$count < $avg_factor && $j < $len - 1; $j++, $count++) {
				$x += $arr[$j][0];
				$y += $arr[$j][1];
				$i = $j;
			}
			$arr2[] = array($x/$count,$y/$count);
		}
		$arr2[] = $arr[$len-1];
		$arr = $arr2;
	}
	
	
	$len = count($arr);
	
	$dists = array(); //distances between point pairs
	$pi2 = pi()/2;
	
	// index "pointers" to previous and next array element
	$prev = range(-1,count($arr));
	$next = range(1,count($arr));
	
	$dists[0] = dist($arr[0], $arr[1]);
	for ($i = 1; $i < $len - 1; $i = $next[$i]) {
		$b = dist($arr[$i], $arr[$next[$i]]);
		$dists[$i] = $b;
		
		
		// Lookahead for shorter paths to points further on,
		// but skip for important borders.
		if ($fact > 1) {
			
			$u = $i+1;
			$la_limit = (40*$fact) / ($zoom*2);
		    
			// check points at increasing distance from $i, until $la_limit
			// also, exit if going too far over the total path
			for ( $off = 2, $j = $i + $off, $counter = 0;
				  $off < $la_limit && $j < $len && $counter < $len/($zoom*2);
				  $off= floor($off * 1)+2, $j+=$off, $counter++) {
				$short = dist($arr[$i],$arr[$j]);
				
				// if the distance to this point is a bit shorter
				if ($dists[$i] > $short * 1.5 ) {
					for (;$u<$j; $u++) {
						unset($arr[$u]);
					}
					$dists[$i] = $short;
					$next[$i] = $j;
					$prev[$j] = $i;
				}
			}
		}
	}
 	// Iteratively remove points whose distance is below threshold
 	// based on pixel size at this zoom level.
	$pixlimit = $merc_pixel * $fact * 1.5;
	
    for ($zlimit = 7; $zlimit >$zoom; $zlimit--) {
		for ($i = $next[0]; $i < count($arr) - 1; $i = $next[$i]) {
			$testdist = $dists[$i];
			if ($testdist < $pixlimit) {
				unset($arr[$i]);
				unset($dists[$i]);
				$dists[$prev[$i]] = dist($arr[$prev[$i]],$arr[$next[$i]]);
				$next[$prev[$i]] = $next[$i];
				$prev[$next[$i]] = $prev[$i];
				$i = $next[$i];
			}
		}
	}
	
    // back to spherical coordinates
	foreach ($arr as $key => $val) {
		$arr[$key] = inverseMerc($val);
	}
    
    // compact array before returning
	return array_values($arr);
}

