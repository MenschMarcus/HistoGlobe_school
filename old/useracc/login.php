<?php
//<!--login.php - Displayed to allow to open a session-->
//print_r($_POST);

	// Test if the visitor submitted the connexion form - Login & password
	if (isset($_POST['connexion']) && $_POST['connexion'] == 'Login') {
		if ((isset($_POST['login']) && !empty($_POST['login'])) && (isset($_POST['pass']) && !empty($_POST['pass']))) {

			$base = mysql_connect ('localhost', 'root', '1234');
			mysql_select_db ('user_account', $base);

			// Test if an input of the database contains this login/pwd couple
			$sql = 'SELECT count(*) FROM individual WHERE login="'.mysql_escape_string($_POST['login']).'" AND pass_SHA1="'.mysql_escape_string(sha1($_POST['login'].$_POST['pass'])).'"';
			$req = mysql_query($sql) or die('Erreur SQL !<br />'.$sql.'<br />'.mysql_error());
			$data = mysql_fetch_array($req);

			mysql_free_result($req);
			mysql_close();

			// If we get an answer, the user is a member
			if ($data[0] == 1) {
				session_start();
				$_SESSION['login'] = $_POST['login'];			
				//LAST_VISIT			
				//$date=date("F j, Y, g:i a");
				//$sqli = "UPDATE individual SET lastLogin='".$date."' WHERE login=".$_SESSION['login'];
				//mysql_query($sqli) or die("Erreur SQL ! ".$sql."<br>".mysql_error());			
				
				header('Location: ../');
				//// no redirect, just give status
				setcookie('username', $_POST['login'], 0, '/');
				//print("OK");
				exit();
			}
			
			// If no answer, the user either has typed wrong login or wrong pwd
			elseif ($data[0] == 0) {
				$erreur = 'Account unrecognized.';
			}
			
			// Else...Database problem (!!!)
			else {
				$erreur = 'Database problem: several members have same logins.';
			}
		}
		// Else a field is not completed by the user 
		else {
			$erreur = 'At least one field is empty. Please fill fields correctly.';
		}
		// print error and exit
		setcookie('username', '', 1, '/');
		print($erreur);
		exit();
	}
?>

<html>
	<head>
		<link rel="stylesheet" media="screen" type="text/css" title="Design" href="../useracc/css.css" />
		<link rel="stylesheet" type="text/css" href="../css/adminarea.css" />
		<title>Login</title>
		
		<!--A script which is a tool using for verifying mandatory fields-->
		<script language="javascript" type=text/javascript>  
		function verifNonVide(formulaire,champs) {
				var mess_ini = "Some information is missing. Please complete the following fields:\n";
				var mess = mess_ini ;
			for(var i=0; i < champs.length; i=i+2) {
			if ( eval('document.'+formulaire+'.'+champs[i]+'.value.length') < 1 ) {
				mess += " - " ;
				mess += champs[i+1];
				mess += "\n" ;
			}
			}
			if ( mess.length != mess_ini.length ) {
				window.alert(mess);
			}
			else {
			eval('document.'+formulaire+'.submit()');
			}
		}
		function choixprop(form) {
			if (form.choix[0].checked) {
			document.getElementById('situation').style.display = 'inline';
			}else{
			document.getElementById('situation').style.display = 'none';
			}
		}
		</script>
	</head>

	<body>
<div id="logo1"> </div>
<div id="register"><h1><font color="green" size="10">Login</font></h1></div>
<!--Menu-->
<div id="rightboxContainer">
	<div id="rightbox">
		<!-- ADMIN AREA -->
		  <div id="adminArea">
			<table id="loggedout">
			  <tr>
				<td><a href="../" onclick="return showlogin();">Home</a></td>
				<td><a href="registration.php">Register</a></td>
				<td><a href="about.php">About</a></td>
			  </tr>
			</table>
		</div>
	</div>
</div>
	
	<div class="form1">
		<form action="login.php" method="post" name="connexion">
			
				<center> Connexion to the space member : </center>
				<center><br>
				<table>
					<tr>
						<td>Login :</td>
						<td><input type="text" name="login" value="<?php if (isset($_POST['login'])) echo htmlentities(trim($_POST['login'])); ?>"><br /></td>
					</tr>
					<tr>
						<td>Password :</td>
						<td><input type="password" name="pass" value="<?php if (isset($_POST['pass'])) echo htmlentities(trim($_POST['pass'])); ?>"><br /></td>
					</tr>
				</table>
				<center><input type="submit" value="Login" onClick="verifNonVide('connexion',['login', 'Login', 'pass', 'Password']);" name="connexion"> <br/>
				</center>
			
		</form>
	</div>
	
	<div class="footPrintCopyright">
		&copy; 2012 by HistoglObe.<br>
		All rights reserved. No part of this document may be reproduced in any form, without prior permission of HistoglObe.<br>
	</div>
	
	<?php
	if (isset($erreur)) echo '<br /><br />',$erreur;
	?>
	
	</body>
</html>
