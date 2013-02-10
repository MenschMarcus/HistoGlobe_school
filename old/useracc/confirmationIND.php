<!--confirmationIND.php - Displayed to confirm the individual registration form + redirection-->

<?php
session_start();
if (!isset($_SESSION['login'])) {
	header ('Location: login.php');
	exit();
}
?>

<html>
    <head>
		<title>Confirmation</title>
		<link rel="stylesheet" media="screen" type="text/css" title="Design" href="css.css" />
		<meta http-equiv="refresh" content="10; ../">
    </head>
     
<body>
	<div class="adminArea">

	</div>
	
	<div class="confirmation">
		Thank you for registering <?php echo htmlentities(trim($_SESSION['login'])); ?>! Now you can login and have an access to the HISTOGLOBE module store.<br>
		You are going to be redirected to home page.<br>
		<br>
		<br>
		If you don't want to wait for, please click here:  <a href="../">Home.</a>
	</div>
	
	<div class="footPrintCopyright">
		&copy;012 by HistoglObe.<br>
		All rights reserved. No part of this document may be reproduced in any form, without prior permission of HistoglObe.<br>
	</div>
	
</body>
</html> 


