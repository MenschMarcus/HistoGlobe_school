<?php

$dbName       = strval($_GET['dbName']);
$tableName    = strval($_GET['tableName']);

$dbLayout = ['`id`', '`name`', '`description`', '`startDate`', '`endDate`',
             '`locName`', '`long`', '`lat`', '`category`', '`multimedia`'];
$values  = [];

// echo "id: " . $_POST['id'] . "\n";
// echo "name: " . $_POST['name'] . "\n";
// echo "description: " . $_POST['description'] . "\n";
// echo "startDay: " . $_POST['startDay'] . "\n";
// echo "startMonth: " . $_POST['startMonth'] . "\n";
// echo "startYear: " . $_POST['startYear'] . "\n";
// echo "endDay: " . $_POST['endDay'] . "\n";
// echo "endMonth: " . $_POST['endMonth'] . "\n";
// echo "endYear: " . $_POST['endYear'] . "\n";
// echo "locName: " . $_POST['locationName'] . "\n";
// echo "long: " . $_POST['long'] . "\n";
// echo "lat: " . $_POST['lat'] . "\n";
// echo "category: " . $_POST['category'] . "\n";
// echo "multimedia: " . $_POST['multimedia'] . "\n";

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

// foreach ($values as $value) {
//   echo $value;
// }

if (sizeof($values) == sizeof($dbLayout)) {

  // create connection
  $mysqli = new mysqli("localhost", "root", "1234", $dbName);

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
