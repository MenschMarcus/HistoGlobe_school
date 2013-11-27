<?php

$dbName       = strval($_GET['dbName']);
$tableName    = strval($_GET['tableName']);

$values  = $_POST;
$dbLayout = ['`id`', '`name`', '`description`', '`startDate`', '`endDate`',
             '`locName`', '`long`', '`lat`', '`category`', '`multimedia`'];

foreach ($values as &$value) {
  $value = "'" . $value . "'";
}

if (sizeof($values) == sizeof($dbLayout)) {

  // create connection
  $mysqli = new mysqli("localhost", "root", "1234", $dbName);

  // check connection
  if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }

  $query = "INSERT INTO " . $tableName . " (" . implode(', ', $dbLayout) .") " .
           "VALUES (" . implode(', ', $values) . ")";

  if ($result = $mysqli->query($query)) {

    echo "Successfully added hivent!";
    $result->close();
  } else { }
  //   echo $mysqli->error;
  // }

  $mysqli->close();
}


?>
