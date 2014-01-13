<?php

$serverName = strval($_GET['serverName']);
$dbName     = strval($_GET['dbName']);
$tableName  = strval($_GET['tableName']);

$dbLayout = ['`id`', '`name`', '`description`', '`startDate`', '`endDate`',
             '`locName`', '`long`', '`lat`', '`category`', '`multimedia`'];
$values  = [];

array_push($values, "'" . $_POST['id'] . "'");
array_push($values, "'" . str_replace("'", "\'", $_POST['name']) . "'");
array_push($values, "'" . str_replace("'", "\'", $_POST['description']) . "'");
array_push($values, "'" . $_POST['startDay'] . "." . $_POST['startMonth'] . "." . $_POST['startYear'] . "'");
array_push($values, "'" . $_POST['endDay'] . "." . $_POST['endMonth'] . "." . $_POST['endYear'] . "'");
array_push($values, "'" . str_replace("'", "\'", $_POST['locationName']) . "'");
array_push($values, "'" . $_POST['long'] . "'");
array_push($values, "'" . $_POST['lat'] . "'");
array_push($values, "'" . str_replace("'", "\'", $_POST['category']) . "'");
array_push($values, "'" . $_POST['multimedia'] . "'");

if (sizeof($values) == sizeof($dbLayout)) {

  // create connection
  $mysqli = new mysqli($serverName, "hivents", "hivents", $dbName);

  // check connection
  if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }

  $query = "INSERT INTO " . $tableName . " (" . implode(', ', $dbLayout) .") " .
           "VALUES (" . implode(', ', $values) . ")";

  if (!($result = $mysqli->query(utf8_decode($query)))) {
    echo $query . "\n";
    echo $mysqli->error;
  }

  $mysqli->close();
}


?>
