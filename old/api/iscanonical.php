<?php
require_once('db.php');

$db = new DataBase();
$canonicalTime = $db->checkCanonicalDate($_GET['now']);
$upper = $db->checkUpperBound($_GET['now']);
echo $canonicalTime . ';' . $upper;
