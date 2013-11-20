<?php

$dbName     = strval($_GET['dbName']);
$tableName  = strval($_GET['tableName']);
$selector   = strval($_GET['selector']);
$condition  = strval($_GET['condition']);
$lowerLimit = intval($_GET['lowerLimit']);
$upperLimit = intval($_GET['upperLimit']);

// create connection
$mysqli = new mysqli("localhost", "root", "1234", $dbName);

// check connection
if ($mysqli->connect_errno) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

if ($selector == "") {
  $selector = "*";
}

$query = "SELECT " . $selector . " FROM " . $tableName;

if ($condition != "") {
  $query = $query . " WHERE " . $condition;
}

if ($upperLimit > 0) {
  $query = $query . " LIMIT " . $lowerLimit . ", " . $upperLimit;
}

if ($result = $mysqli->query($query)) {

  while ($row = $result->fetch_row()) {
    $row_len = sizeof($row);
    for ($i=0; $i<$row_len; ++$i) {
      echo $row[$i] . "|";
    }
    echo "\n";
  }
  $result->close();
}

$mysqli->close()
?>
