<?php
require_once('trig.php');

class DataBase {
	private $dbconnection;
	
	function __construct() {
		try {
			// Open the database historyDatabase
			$this->dbconnection = new PDO('mysql:dbname=histoglobe;host=localhost;charset=UTF-8','__USER__','__PASSWD__');
			// TODO set options
			$this->dbconnection -> exec("set names utf8");
			//print_r($this->dbconnection->errorInfo());
		}
		// If a problem occurs
		catch (Exception $e) {
			// avoid printing error output if on
			// non-development site,
			// output may include connection information!
			//echo $e->getMessage();
			die("died while connecting DB");
		}
	}
	
	// print out error info 
	function dbginfo()
	{
		print "<pre>";
		print_r($this->dbconnection->errorInfo());
	}
	
	/*
	 * Find latest border change before $time
	 */
	function checkCanonicalDate($time)
	{
		$statement = $this->dbconnection->prepare(
			"SELECT * FROM auBorder ".
			" WHERE start = str_to_date(?, '%Y-%m-%d') ".
			"      or end = str_to_date(?, '%Y-%m-%d');");
		
		$statement->execute(array($time,$time));
		
		// if no border starts or ends on $time
		if ($statement->fetch() == false)
			{

			$canonicalDateStart = $this->dbconnection->prepare(
				"SELECT start ".
				"  FROM auBorder ".
				"  WHERE start <= str_to_date(?, '%Y-%m-%d') ".
				"  ORDER BY start DESC LIMIT 0,1;");
			$canonicalDateStart->execute(array($time));
			$start = $canonicalDateStart-> fetchAll();

			$canonicalDateEnd = $this->dbconnection->prepare(
				"SELECT end ".
				"  FROM auBorder ".
				"  WHERE end <= str_to_date(?, '%Y-%m-%d') ".
				"  ORDER BY end DESC LIMIT 0,1;");

			$canonicalDateEnd->execute(array($time));
			$end = $canonicalDateEnd-> fetchAll();
			if (count($start) == 0) {
				if (count($end) == 0) {
					return $time;
				} else {
				    // TODO use 1800-01-01 instead of time?
					return max($end[0][0], $time);
				}
			}
			if (count($end) == 0) {
				return max($start[0][0], $time);
			}
			return max($start[0][0], $end[0][0]);
		}
		else
			return $time;
	}
	
	/*
	 * Find earliest border change after $time
	 */
	function checkUpperBound($time) {
		$canonicalDateStart = $this->dbconnection->prepare(
			"SELECT start ".
			"  FROM auBorder ".
			"  WHERE start > str_to_date(?, '%Y-%m-%d') ".
			"  ORDER BY start ASC LIMIT 0,1;");
		$canonicalDateStart->execute(array($time));
		$start = $canonicalDateStart-> fetchAll();
		
		$canonicalDateEnd = $this->dbconnection->prepare(
			"SELECT end ".
			"  FROM auBorder ".
			"  WHERE end > str_to_date(?, '%Y-%m-%d') ".
			"  ORDER BY end ASC LIMIT 0,1;");
		$canonicalDateEnd->execute(array($time));
		$end = $canonicalDateEnd-> fetchAll();
		if (count($start) == 0) {
		    if (count($end) == 0) return '2020-01-01'; // no data from this point on, return some fantastic future date
		    else return min('2020-01-01', $end[0][0]);
		} if (count($end) ==0) {
		    return min($start[0][0], '2020-01-01');
		}
		
		return min($start[0][0], $end[0][0]);
		
	}
	/**
	 * Query all borders for a date. This also gets the "layer" column,
	 * representing the level of border (national, 1st level, 2nd level etc).
	 * If a border file is represented more than once, only take the highest level.
	 */
	function getborders($time) {
		// Preparing the query
		$statement = $this->dbconnection->prepare(
			"SELECT auBorder.*,adminUnit.level,adminUnit.nameCommon,adminUnit.nameOfficial " .
			" FROM auBorder,adminUnit " .
			" WHERE auBorder.start <= str_to_date(?, '%Y-%m-%d')".
			"     and (auBorder.end > str_to_date(?, '%Y-%m-%d') or auBorder.end is null) ".
			"     and adminUnit.adminID = auBorder.au1 ".
			" GROUP BY borderFile,start;");
		$statement->execute(array($time,$time));
		
		return $statement;
	}
	
	/*
	 * Get all events between dates, belonging to given categories (as 0 or 1)
	 */
	function getevent($start, $end, $soc, $dom, $for) {
		//if (str_to_date($start, '%Y-%m-%d')<= str_to_date($end, '%Y-%m-%d')){
			// Preparing the query
			$sql ="SELECT e.* FROM histEvent as e".
				  " WHERE str_to_date(?,'%Y-%m-%d') < date ".
				  "   and str_to_date(?,'%Y-%m-%d') > date ";
			$cat = ";";
			if ($soc == "1" || $dom == "1" || $for == "1") {
				$cats = array();
				if ($soc == "1") $cats[] = " isSocial = 1 ";
				if ($dom == "1") $cats[] = " isDomestic = 1 ";
				if ($for == "1") $cats[] = " isForeign = 1 ";
				$cat = " and ( " . implode(" or ", $cats)  . " );";
			}

			$event = $this->dbconnection->prepare($sql . $cat);
			$event->execute(array($start,$end));
			return $event;
		/*}
		else
			echo ("ERROR: Start date must occur before End date");*/
	}
	
	/*
	 * Get adminUnits active at $time
	 */
	function getAdminUnits($time) {
		$statement = $this->dbconnection->prepare(
			"SELECT au.*,p.name" .
			" FROM adminUnit as au, politOrder as p " .
			" WHERE au.start <= str_to_date(?, '%Y-%m-%d')".
			"     and (au.end > str_to_date(?, '%Y-%m-%d') or au.end is null) ".
			"     and au.politOrderID = p.politOrderID");
		$statement->execute(array($time,$time));
		
		return $statement->fetchAll(PDO::FETCH_ASSOC);
	}
	
	// get single event by id
	function getEventById($id) {
    	$sql  = "SELECT e.*,link.link ".
    	       " FROM histEvent as e LEFT JOIN eventLink AS link ON e.histEventID = link.histEventID  WHERE ? = e.histEventID ";
    	$sql .= " GROUP BY e.histEventID;"; // get only one link/doc
	    $event = $this->dbconnection->prepare($sql);
		$event->execute(array($id));
		return $event->fetchAll(PDO::FETCH_ASSOC);
	}
	
    // get events nearby to event=id using zoom level and filter by categories
	function getEventsById($id, $start, $end, $zoom, $soc, $dom, $for) {
	    $event = $this->getEventById($_GET['eventid']);
	    $event = $event[0];
	    $long = $event['lon'];
   	  $lat = $event['lat'];

	    // threshold distance at equator in kilometers
	    $thres = (40075016.68 / pow(2,$zoom) / 256) * 6 / 1000; // radius 6 pixels
	    //divide by latitudinal magnification factor
	    $thres = $thres /  mercMagnificationFactor($lat);

	    $sql = "SELECT ".
	    " (6371 * acos( ".
	    "          cos(radians(?)) ". // lat
	    "           * cos(radians( lat )) ".
	    "           * cos(radians( lon ) - radians(?)) ". // long
	    "          + sin(radians(?) ) ". // lat
	    "           * sin(radians( lat )) ".
	    " )) AS distance, link.link, e.* ".
	    " FROM histEvent as e LEFT JOIN eventLink as link ON e.histEventID = link.histEventID".
	    " WHERE str_to_date(?,'%Y-%m-%d') < date ".
		"   and str_to_date(?,'%Y-%m-%d') > date ";
		
		$cat = "";
		if ($soc == "1" || $dom == "1" || $for == "1") {
			$cats = array();
			if ($soc) $cats[] = " isSocial = 1 ";
			if ($dom) $cats[] = " isDomestic = 1 ";
			if ($for) $cats[] = " isForeign = 1 ";
			$cat = " and ( " . implode(" or ", $cats)  . " ) ";
		}
		
		$sql .= $cat . " GROUP BY e.histEventID ".
	                    " HAVING distance < ? ORDER BY date LIMIT 0,10;";
        
	    $list = $this->dbconnection->prepare($sql);

        $list->execute(array($lat, $long, $lat, $start, $end, $thres));
		return $list->fetchAll(PDO::FETCH_ASSOC);
	}

	function getCountryNamesByTime($time) {
		$names = $this->dbconnection->prepare(
			"SELECT * ".
			" FROM adminUnit ".
			" WHERE start <= str_to_date(?, '%Y-%m-%d') ".
			"     and (end > str_to_date(?, '%Y-%m-%d') or end is null);");
		$names->execute(array($time,$time));
		return $names;
	}
	
	function close() {
		$this->dbconnection->close();
	}
}

