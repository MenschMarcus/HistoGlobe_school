<?php
    session_start();
    
    // define language whitelist
    $allowedLangs = array('en', 'de');
    
    if(isset($_GET['lang']) && in_array($_GET['lang'], $allowedLangs)) {
        $_SESSION['lang'] = $_GET['lang'];
    }
    if(!isset($_SESSION['lang'])) {
        $_SESSION['lang'] = 'de'; // default value
    }
    include('locale/' . $_SESSION['lang'] . '.php'); // include lang file
    
    function locale($phrase) {
        global $lang;
        
        if(array_key_exists($phrase, $lang)) {
            echo $lang[$phrase];
        } else {
            echo $phrase;
        }
    } 
?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-de" lang="de-de" dir="ltr">
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        
        <title>HistoGlobe</title>
        
        <link rel="icon" type="image/png" href="img/favicon.png">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="css/bootstrap-responsive.min.css">
        <link rel="stylesheet" type="text/css" href="css/font-awesome.min.css">
        <link rel="stylesheet" type="text/css" href="css/style.css">
        
        <script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
        <script type="text/javascript" src="js/bootstrap.min.js"></script>
        
        <script type="text/javascript">
            jQuery(document).ready(function($) {
	            $(".smooth").click(function(event){		
		            event.preventDefault();
		            $('html,body').animate({scrollTop:$($(this).attr('href')).offset().top}, 500);
	            });
	            
	            $('#demo-link').tooltip();
            });
        </script>

    </head>
    <body data-spy="scroll" data-target="#mainNavigation" data-offset="20">
        <div class="navbar navbar-fixed-top">
            <div class="navbar-inner">
                <div class="container">
                    <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </a>
                    <a class="brand active smooth" href="#home">
                        <img src="img/logo_small.svg" alt="HistoGlobe">
                    </a> 
                    <div class="nav-collapse collapse" id="mainNavigation">
                        <ul class="nav">
                            <li class=""><a class="smooth" href="#home"><i class="<?php locale("iconHome")?>"></i> <?php locale("buttonHome")?></a></li>
                            <li class=""><a class="smooth" href="#summary"><i class="<?php locale("iconDetails")?>"></i> <?php locale("buttonDetails")?></a></li>
                            <li class=""><a class="smooth" href="#about"><i class="<?php locale("iconAbout")?>"></i> <?php locale("buttonAbout")?></a></li>
                            <li class=""><a class="smooth" href="#contact"><i class="<?php locale("iconContact")?>"></i> <?php locale("buttonContact")?></a></li>
                        </ul>
                    </div>
                    <!--<div class="nav-collapse collapse">
                        <ul class="nav pull-right">
                            <li class="dropdown" id="fat-menu">
                                <a data-toggle="dropdown" class="dropdown-toggle" role="button" id="language-drop" href="#"><i class="icon-comment-alt"></i> Language <b class="caret"></b></a>
                                <ul aria-labelledby="language-drop" role="menu" class="dropdown-menu">
                                    <li class=""><a href="?lang=de">Deutsch</a></li>
                                    <li class=""><a href="?lang=en">English</a></li>
                                </ul>
                            </li>
                        </ul>
                    </div>-->
                </div>
            </div>
        </div>

        <div class="container" id="home">
            <div class="hero-unit">
                <center>
                    <img src="img/logo_big.svg" alt="logo">
                    <!--<a href="#" id="demo-link" class="btn" data-placement="bottom" data-original-title="Warnung: Der Globus benötigt einen sehr aktuellen Browser."><small>3D-Globus anzeigen!</small></a>-->
                </center>
            </div>
            
            <div class="info-box">
                <div class="row">
                    <p><i class="icon-warning-sign pull-left" style="font-size:300%"></i>  <?php locale("not_ready")?></p>
                </div>
            </div>

            <div class="row">
                <div class="span4">
                    <div class="gradient-down summary">
                        <h3><i class="<?php locale("icon_1")?>"></i> <?php locale("feature_1")?></h3>
                        <p><?php locale("summary_1")?> <br>
                    </div>
                </div>
                <div class="span4">
                    <div class="gradient-down summary">
                        <h3><i class="<?php locale("icon_2")?>"></i> <?php locale("feature_2")?></h3>
                        <p><?php locale("summary_2")?> <br>
                    </div>
                </div>
                <div class="span4">
                    <div class="gradient-down summary">
                        <h3><i class="<?php locale("icon_3")?>"></i> <?php locale("feature_3")?></h3>
                        <p><?php locale("summary_3")?> <br>
                    </div>
                </div>
            </div>
        </div>

        <div class="container" id="summary">
            <div class="details gradient-up">
                    <i class="<?php locale("icon_4")?> pull-left icon-feature"></i> 
                    <h2>HistoGlobe <span class="muted"> <?php locale("heading_1")?></span></h2> 
                    <p><?php locale("explanation_1")?> <br>

                <hr id="summary2">

                    <i class="<?php locale("icon_5")?> pull-right icon-feature"></i> 
                    <h2>HistoGlobe <span class="muted"> <?php locale("heading_2")?></span></h2> 
                   <p><?php locale("explanation_2")?> <br>

                
            </div>
        </div>

       <div class="container" id="about"> 
            <div class="row" >
                <div class="span12">
                    <div class="details gradient-down">
                        <h4><i class="<?php locale("iconAbout")?>"></i> <?php locale("buttonAbout")?></h4>
                        <?php locale("about")?>
                    </div>
                </div> 
            </div> 

        </div>
            
        <div class="container" id="contact"> 
            <div class="row" >
                <div class="span6">
                    <div class="details muted">
                        <h4><i class="<?php locale("iconContact")?>"></i> <?php locale("buttonContact")?></h4>
                        <small><?php locale("contact")?></small>
                    </div> 
                </div> 
                <div class="span6">
                    <div class="details muted">
                        <h4><i class="<?php locale("iconImpressum")?>"></i> <?php locale("buttonImpressum")?></h4>
                        <small><?php locale("impressum")?></small>
                    </div> 
                </div> 
            </div> 

        </div>
    </body>
</html>
