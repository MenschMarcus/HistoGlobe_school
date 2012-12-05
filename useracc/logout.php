<?php
//<!--logout.php - This page kills a session + redirects to home page-->
session_start();
session_unset();
session_destroy();
$params = session_get_cookie_params();
setcookie('PHPSESSID', '', 1, '/');
setcookie('username', '', 1, '/');
header('Location: ../');
exit();
?>

