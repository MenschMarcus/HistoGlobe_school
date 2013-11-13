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
    foreach ($row as $col) {
      echo $col . ", ";
    }
    echo "\n\n";
  }
  $result->close();
}

$mysqli->close()
?>
