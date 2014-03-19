<?php

$serverName = strval($_GET['serverName']);
$dbName     = strval($_GET['dbName']);
$tableName  = strval($_GET['tableName']);
$condition  = strval($_GET['condition']);


if ($condition != "") {
  // create connection
  $mysqli = new mysqli($serverName, "hivents", "hivents", $dbName);

  // check connection
  if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }

  $query = "DELETE FROM " . $tableName .
           " WHERE " . $condition;

  if (!($result = $mysqli->query(utf8_decode($query)))) {
    echo $query . "\n";
    echo $mysqli->error;
  }

  $mysqli->close();
} else {
  echo "Cannot remove data without a condition!";
}

?>
