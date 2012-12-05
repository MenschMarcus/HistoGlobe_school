<!--modulestore.php page-->

<?php
session_start();  
if (!isset($_SESSION['login'])) { 
	header ('Location: login.php');
	exit();  
}  
?>

<html>
    <head>
		<link rel="stylesheet" media="screen" type="text/css" title="Design" href="css.css" />
		<link rel="stylesheet" media="screen" type="text/css" title="Design" href="../css/adminarea.css" />
		<title>Module Store</title>
    </head>
     
    <body>

<!--Menu-->
<div id="rightboxContainer">
	<div id="rightbox">
		<!-- ADMIN AREA -->
		  <div id="adminArea">
			<table id="loggedout">
			  <tr>
				<td><a href="../" onclick="return showlogin();">Home</a></td>
				<td><a href="logout.php">Logout</a></td>
				<td><a href="about.php">About</a></td>
			  </tr>
			</table>
		</div>
	</div>
</div>
	
	<div class="form1">
		<center>Welcome to the module store <?php echo $_SESSION['login']; ?></center><br />
	</div>
	
	<div class="footPrintCopyright">
		&copy; 2012 by HistoglObe.<br>
		All rights reserved. No part of this document may be reproduced in any form, without prior permission of HistoglObe.<br>
	</div>
	
    </body>
</html>