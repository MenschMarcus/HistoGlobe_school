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
        <script type="text/javascript" src="globe/bootstrap.min.js"></script>
        
        <script type="text/javascript" src="globe/third-party/Three/ThreeWebGL.js"></script>
        <script type="text/javascript" src="globe/third-party/Three/ThreeExtras.js"></script>
        <script type="text/javascript" src="globe/third-party/Three/RequestAnimationFrame.js"></script>
        <script type="text/javascript" src="globe/third-party/Three/Detector.js"></script>
        <script type="text/javascript" src="globe/third-party/Tween.js"></script>
        <script type="text/javascript" src="globe/third-party/paper.js"></script>
        <script type="text/javascript" src="globe/Display2D.js"></script>
        <script type="text/javascript" src="globe/Display3D.js"></script>
        <script type="text/javascript" src="globe/Map.js"></script>
               
        <script type="text/javascript">
        
            var display2D, display3D, map;
        
            jQuery(document).ready(function($) {
	            $(".smooth").click(function(event){		
		            event.preventDefault();
		            $('html,body').animate({scrollTop:$($(this).attr('href')).offset().top}, 500);
	            });
	            
	            $('#demo-link').tooltip();
	            
	            map = new HG.Map();
            });
            
            function loadGLHeader() {
            	if(!Detector.webgl){
                    Detector.addGetWebGLMessage();
                } else {
                    $('#default-header').animate({opacity: 0.0}, 1000, 'linear', 
                                                function() {   
                                                    $('#default-header').css({visibility:"hidden"});
                                                });
                    $('#gl-header').css({visibility:"visible"});
                    $('#demo-link').css({visibility:"hidden"});
                    $('#back-link').css({visibility:"visible"});
                    $('#back-link').tooltip();
                                                
                    $('.hero-unit').css({"background-image": "none"});
                    $('#logo-normal').css({visibility: "visible"});                 
                                  
                    var container = document.getElementById('container');
                    
                    load3D();
                    $('#toggle-3D').addClass("btn active"); 
                      
                }
            }
            
            
            function loadDefaultHeader() {
                $('#default-header').css({visibility:"visible"});
                $('#default-header').animate({opacity: 1.0}, 1000, 'linear');
                $('#gl-header').css({visibility:"hidden"});
                $('#demo-link').css({visibility:"visible"});
                $('#back-link').css({visibility:"hidden"}); 
                
                $('.hero-unit').css({"background-image": "url('img/logo_bg.jpg')",
                                         "background-position": "bottom right"});
                $('#logo-normal').css({visibility: "hidden"});      
                
                if (display3D && display3D.isRunning()) {
                    $(display3D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
                    display3D.stop();                
                }
                    
                if (display2D && display2D.isRunning()) {
                    $(display2D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
                    display2D.stop();                    
                }   
            }
            
            function load2D() {
                if (display3D && display3D.isRunning()) {
                    $(display3D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear');
                    display3D.stop();
                }
                    
                if (!display2D) {
                    display2D = new HG.Display2D(container, map);
                    $(display2D.getCanvas()).css({opacity: 0.0});
                }
                
                display2D.start();   
                $(display2D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');       	    
            }
            
            function load3D() {
                if (display2D && display2D.isRunning()){
                    $(display2D.getCanvas()).animate({opacity: 0.0}, 1000, 'linear'); 
                    display2D.stop();
                }
                  
                if (!display3D) {
                    display3D = new HG.Display3D(container, map);
                    $(display3D.getCanvas()).css({opacity: 0.0});
                }
              
                display3D.start();    
                $(display3D.getCanvas()).animate({opacity: 1.0}, 1000, 'linear');        	    
            }
            
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
                    <div class="nav-collapse collapse">
                        <ul class="nav pull-right">
                            <li class="dropdown" id="fat-menu">
                                <a data-toggle="dropdown" class="dropdown-toggle" role="button" id="language-drop" href="#"><i class="icon-comment-alt"></i> Language <b class="caret"></b></a>
                                <ul aria-labelledby="language-drop" role="menu" class="dropdown-menu">
                                    <li class=""><a href="?lang=de">Deutsch</a></li>
                                    <li class=""><a href="?lang=en">English</a></li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div class="container" id="home">
        
            <div class="hero-unit">
                <div id="container"></div>
                <div id="gl-header" style="visibility:hidden">
                    <div class="btn-toolbar header-button-bottom">
                        <div class="btn-group" data-toggle="buttons-radio">
                            <a id="toggle-2D" class="btn" onClick="load2D()">2D</a>
                            <a id="toggle-3D" class="btn" onClick="load3D()">3D</a>
                        </div>
                    </div>
                </div>
                
                <div class="bottom-left-logo" id="logo-normal" style="visibility:hidden"></div>
                
                <div class="banner" >
                    <p>Beta!</p>
                </div>
                
                <a id="demo-link" class="btn header-button-top" 
                   data-placement="left" 
                   data-original-title="Warnung! Der Globus benötigt einen sehr aktuellen Browser." 
                   onClick="loadGLHeader()"
                   style="margin:10px">
                    <small>3D-Globus!</small>
                </a>
                
                <a id="back-link" class="btn header-button-top" 
                   style="visibility:hidden"
                   data-placement="left" 
                   data-original-title="Zurück zum Start." 
                   onClick="loadDefaultHeader()"
                   style="margin:10px">
                    <small>Zurück!</small>
                </a>
                
                <div id="default-header">
                    <center>
                        <img src="img/logo_big.svg" alt="logo">
                    </center>
                </div>
            </div>
                        
            <div class="info-box">
                <div class="row">
                    <p><i class="icon-warning-sign pull-left" style="font-size:300%"></i>  <?php locale("not_ready")?></p>
                </div>
            </div>

            <div class="row">
                <div class="span4">
                    <div class="gradient-down summary">
                        <h3><i class="<?php locale("icon_1")?>"></i> <?php locale("feature_1a")?></h3>
                        <p><?php locale("summary_1")?> <br>
                        <a class="smooth" href="#summary"> <?php locale("read_on")?></a></p>
                    </div>
                </div>
                <div class="span4">
                    <div class="gradient-down summary">
                        <h3><i class="<?php locale("icon_2")?>"></i> <?php locale("feature_2a")?></h3>
                        <p><?php locale("summary_2")?> <br>
                        <a class="smooth" href="#summary2"> <?php locale("read_on")?></a></p>
                    </div>
                </div>
                <div class="span4">
                    <div class="gradient-down summary">
                        <h3><i class="<?php locale("icon_3")?>"></i> <?php locale("feature_3a")?></h3>
                        <p><?php locale("summary_3")?> <br>
                        <a class="smooth" href="#summary3"> <?php locale("read_on")?></a></p>
                    </div>
                </div>
            </div>
        </div>

        <div class="container" id="summary">
            <div class="details gradient-up">
                <div class="row">
                    <i class="<?php locale("icon_1")?> pull-left icon-feature"></i> 
                    <h2><?php locale("feature_1a")?> <span class="muted"><?php locale("feature_1b")?></span></h2> 
                    <?php locale("explanation_1")?>
                </div>

                <hr id="summary2">

                <div class="row">
                    <i class="<?php locale("icon_2")?> pull-right icon-feature"></i> 
                    <h2><?php locale("feature_2a")?> <span class="muted"><?php locale("feature_2b")?></span></h2> 
                    <?php locale("explanation_2")?>
                </div>

                <hr id="summary3">

                <div class="row">
                    <i class="<?php locale("icon_3")?> pull-left icon-feature"></i> 
                    <h2><?php locale("feature_3a")?> <span class="muted"><?php locale("feature_3b")?></span></h2> 
                    <?php locale("explanation_3")?>
                </div>
            </div>
        </div>

        <div class="container" id="about"> 
            <div class="details gradient-down">
                <div class="row">
                    <h4><i class="<?php locale("iconAbout")?>"></i> <?php locale("buttonAbout")?></h4>
                    <?php locale("about")?>
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
