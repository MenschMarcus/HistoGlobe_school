<!--index.php - Home page-->


<?php
	session_start();  
	if(isset($_SESSION['login']))
		{
		echo "You're connected !";
		include( "indexLogin.php" );
		}
		else
		{
		echo "You're not connected !";
		include( "indexNoLogin.php" );
		}
?>
<!--confirmationPI.php  - Displayed to confirm the Pr.Institution registration form + redirection-->

<html>
    <head>
		<link rel="stylesheet" media="screen" type="text/css" title="Design" href="css.css" />
		<title>Home</title>
    </head>

<body>

	<div class="footPrintCopyright">
		© 2012 by HistoglObe.<br>
		All rights reserved. No part of this document may be reproduced in any form, without prior permission of HistoglObe.<br>
	</div>
	
</body>
</html> 

