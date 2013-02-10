<?php
//$_SERVER["HTTP_USER_AGENT"] :
if (ereg("MSIE", $_SERVER["HTTP_USER_AGENT"])) {
    //Internet explorer
    echo "<link rel=\"stylesheet\" media=\"screen\" type=\"text/css\" title=\"Design\" href=\"../useracc/css.css\" />";
} else if (ereg("^safari/", $_SERVER["HTTP_USER_AGENT"])) {
    //Safari
    echo "<link rel=\"stylesheet\" media=\"screen\" type=\"text/css\" title=\"Design\" href=\"../useracc/safari.css\" />";
} else if (ereg("^Mozilla/", $_SERVER["HTTP_USER_AGENT"])) {
    //Mozilla - Firefox
    echo "<link rel=\"stylesheet\" media=\"screen\" type=\"text/css\" title=\"Design\" href=\"../useracc/css.css\" />";
} else {
    //Les autres
    echo "<link rel=\"stylesheet\" media=\"screen\" type=\"text/css\" title=\"Design\" href=\"../useracc/css.css\" />";
}
?>


<?php
        // Display detailed info on errors
        error_reporting(E_ALL);
        ini_set('display_errors', '1');

//<!--registration.php - Page for registering (includes both individual and private institution forms)-->

//<!--Process for an individual-->

// It tests if the visitor submitted the registration form
	if (isset($_POST['inscription']) && $_POST['inscription'] == 'Save') {
		
		// It tests if our variables exist in database. It also tests if they are no empty
		if ((isset($_POST['login']) && !empty($_POST['login'])) && (isset($_POST['pass']) && !empty($_POST['pass'])) && (isset($_POST['pass_confirm']) && !empty($_POST['pass_confirm']))) {

			// It verifies if the two passwords are exactly the same
			if ($_POST['pass'] != $_POST['pass_confirm']) {
				$erreur = 'Passwords are differents.';
			}
			else {
				$base = mysql_connect ('localhost', 'root', '1234');
				mysql_select_db ('user_account', $base);

				// It tests if the login - pseudo - is available in the database
				$sql = 'SELECT count(*) FROM individual WHERE login="'.mysql_escape_string($_POST['login']).'"';
				$req = mysql_query($sql) or die('Erreur SQL !<br />'.$sql.'<br />'.mysql_error());
				$data = mysql_fetch_array($req);

					if ($data[0] == 0) {
						$sql = 'INSERT INTO individual VALUES("", "'.mysql_escape_string($_POST['login']).'", "'.mysql_escape_string(sha1($_POST['login'].$_POST['pass'])).'","'.mysql_escape_string($_POST['member_mail']).'",NOW(),"'.mysql_escape_string($_POST['member_age']).'",NOW())';
						mysql_query($sql) or die('Erreur SQL !'.$sql.'<br />'.mysql_error());
						session_start();
						$_SESSION['login'] = $_POST['login'];
						header('Location: confirmationIND.php');
						exit();
					}
					else {
						$erreur = 'This login is not available - already used.';
					}
			}
		}
		else {
			$erreur = 'At least one field is empty. Please fill fields correctly.';
		}
	}
	// <!--Process for a private institution-->

	// It tests if the visitor submitted the registration form
	if (isset($_POST['pi_inscription']) && $_POST['pi_inscription'] == 'Send') {
	
		if ((isset($_POST['PI_name']) && !empty($_POST['PI_name'])) && (isset($_POST['PI_address']) && !empty($_POST['PI_address'])) && (isset($_POST['PI_contactName']) && !empty($_POST['PI_contactName'])) && (isset($_POST['PI_contactEmail']) && !empty($_POST['PI_contactEmail'])) && (isset($_POST['PI_contactPhoneNumber']) && !empty($_POST['PI_contactPhoneNumber']))) {
			$base = mysql_connect ('localhost', 'root', '1234');
			mysql_select_db ('user_account', $base);
			$sql = 'INSERT INTO private_institution VALUES("", "'.mysql_escape_string($_POST['PI_name']).'", "'.mysql_escape_string($_POST['PI_address']).'","'.mysql_escape_string($_POST['PI_contactName']).'",NOW(),"'.mysql_escape_string($_POST['PI_contactPhoneNumber']).'","'.mysql_escape_string($_POST['PI_contactEmail']).'","'.mysql_escape_string($_POST['PI_size']).'")';
			mysql_query($sql) or die('Erreur SQL !'.$sql.'<br />'.mysql_error());
			header('Location: confirmationPI.php');
			}
		else {
			$erreur = 'At least one field is empty. Please fill fields correctly.';
		}
	}
?>

<html>
	<head>

	    <link rel="stylesheet" type="text/css" href="../css/adminarea.css" />
		<title>Registration</title>
		<script type="text/javascript" src="../lib/jquery/jquery.min.cookies.js"></script>
		
		
		<script language="javascript" type=text/javascript>
$(function () {
	$("#loginform").submit(postlogin);
	function postlogin() {
	var inputs = $("#loginform :input");
	var values = {};
    	inputs.each(function() {
	        values[this.name] = $(this).val();
    		});
	$.ajax({
	 type: 'POST',
	 url: "useracc/login.php",
	 data: values,
	 success: logindone
	 
	});
	closeLogin();
	return false;
	}
	function logindone(data) {
		_d.log(data);
		switchmenu();
	}
	switchmenu();
	});
	
	function switchmenu() {
		var c = $.cookies.get('username'); 
		if( c == null ) { 
			$("#loggedin").hide();
			$("#loggedout").show();
		} else {
			$("#loggedin").show();
			$("#loggedout").hide();
		}
	}
	function closeLogin() {
		$('#loginbox').hide();
	}
	function showlogin() {
		$('#loginbox').show();
		return false;
	}
	function logout() {
		$.ajax({
		 type: 'POST',
		 url: "useracc/logout.php",
		 success: logoutdone
		});
		return false;
		function logoutdone() {
			switchmenu();
		}
	}		
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
			if (form.choice[0].checked) {
			document.getElementById('situation2').style.display = 'inline';
			document.getElementById('situation1').style.display = 'none';
			}else{
			document.getElementById('situation2').style.display = 'none';
			document.getElementById('situation1').style.display = 'inline';
			}
		}
	</script>
	</head>
	<body>

<div id="register"><h1><font color="green" size="10">Register</font></h1></div>
<div id="logo2"> </div>
<div id="rightboxContainer">
	<div id="rightbox">
    <!-- ADMIN AREA -->
      <div id="adminArea">
        <table id="loggedout">
          <tr>
            <td><a href="login.php">Login</a></td>
            <td><a href="../">Home</a></td>
            <td><a href="../useracc/about.php">About</a></td>
          </tr>
        </table>
        </div>
	</div>
</div>
	
	
<div class="registrationButtons">
	<fieldset>
		<legend align="top"> Are you ? </legend>
		<FORM NAME="form">
			<INPUT TYPE="radio" NAME="choice" checked VALUE="0" onClick="javascript:choixprop(form)">An individual<BR>
			<INPUT TYPE="radio" NAME="choice" VALUE="1" onClick="javascript:choixprop(form)">A private institution
		</FORM>
	</fieldset>
</div>

<div id="whyshouldIregister">

<center><h3>Why should I register?</h3></center>

<li>Are you an individual? Register and:</li>
- Get an access to the module store !<br>
- Complete your learning with additional content !<br>
- Buy modules and download them !<br>
<br>
<li>Are you an institution? Register and:</li>
- Get licenses to access all teaching modules !<br>
- All in One material !<br>
<br>
</div>


<!--Registration form for an individual-->
<div id='situation2' class="form2" style='display: inline'>
			<form action="registration.php" method="post" name="inscription">
				
					<center><font size="4">Registration form for an individual :</font></center>
					<br>
					<table>
						<tr>
							<td>Login *:</td>
							<td><input type="text" name="login" value="<?php if (isset($_POST['login'])) echo htmlentities(trim($_POST['login'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>Password *:</td>
							<td><input type="password" name="pass" value="<?php if (isset($_POST['pass'])) echo htmlentities(trim($_POST['pass'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>Password confirmation *:</td>
							<td><input type="password" name="pass_confirm" value="<?php if (isset($_POST['pass_confirm'])) echo htmlentities(trim($_POST['pass_confirm'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>E-mail *:</td>
							<td><input type="text" name="member_mail" value="<?php if (isset($_POST['member_mail'])) echo htmlentities(trim($_POST['member_mail'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>Age:</td>
							<td><input type="text" name="member_age" value="<?php if (isset($_POST['member_age'])) echo htmlentities(trim($_POST['member_age'])); ?>"><br /> </td>
						</tr>
					</table>
				<center><input type="submit" value="Save" name="inscription"> <br/>
							(Fields with "*" are required).</center>		
			</form>	
					<div id="RegisterErrorMessage">
					<?php
					if (isset($erreur)) echo "<center><br />",$erreur;
					?>
					</div>
</div>

<!--Registration form for a PI-->
<div id='situation1' class="form3" style='display: none'>
			<form action="registration.php" method="post" name="pi_inscription">
				
					<center><font size="4"> Registration form for a private institution :</font></center>
					<br>
	
					<table>
						<tr>
							<td>Name of the institution *:</td>
							<td><input type="text" name="PI_name" value="<?php if (isset($_POST['PI_name'])) echo htmlentities(trim($_POST['PI_name'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>Complete address of the institution *:</td>
							<td><input type="text" name="PI_address" value="<?php if (isset($_POST['PI_address'])) echo htmlentities(trim($_POST['PI_address'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>Name of the contact *:</td>
							<td><input type="text" name="PI_contactName" value="<?php if (isset($_POST['PI_contactName'])) echo htmlentities(trim($_POST['PI_contactName'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>E-mail of the contact *:</td>
							<td><input type="text" name="PI_contactEmail" value="<?php if (isset($_POST['PI_contactEmail'])) echo htmlentities(trim($_POST['PI_contactEmail'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>Contact phone number *:</td>
							<td><input type="text" name="PI_contactPhoneNumber" value="<?php if (isset($_POST['PI_contactPhoneNumber'])) echo htmlentities(trim($_POST['PI_contactPhoneNumber'])); ?>"><br /> </td>
						</tr>
						<tr>
							<td>Size of the institution (number of future users):</td>
							<td><input type="text" name="PI_size" value="<?php if (isset($_POST['PI_size'])) echo htmlentities(trim($_POST['PI_size'])); ?>"><br /> </td>
						</tr>
					</table>
				<center><input type="submit" value="Send"  name="pi_inscription"> <br/>
							(Fields with "*" are required).</center>		
			</form>	
					<div id="RegisterErrorMessage">
					<?php
					if (isset($erreur)) echo "<center><br />",$erreur;
					?>
					</div>
</div>

<div class="footPrintCopyright">
	&copy; 2012 by HistoglObe.<br>
	All rights reserved. No part of this document may be reproduced in any form, without prior permission of HistoglObe.<br>
</div>

</body>
</html>
