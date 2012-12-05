/** This file controls the functionality all around the user accounts. Due to a lack of content we disabled the user account system in the user interface, but we keep the funtionality for later. **/

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
