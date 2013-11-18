<?php

$lowerLimit = intval($_GET['lowerLimit']);
$upperLimit = intval($_GET['upperLimit']);

// create connection
$mysqli = new mysqli("localhost", "root", "1234", "hivents");

// check connection
if ($mysqli->connect_errno) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$query = "SELECT * FROM hivent_data";

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
