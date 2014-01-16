<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de-de" lang="de-de" dir="ltr">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>HistoGlobe</title>

    <!-- third party css -->
    <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="style/third-party/font-awesome.min.css">

    <!-- histoglobe css -->
    <link rel="stylesheet" type="text/css" href="style/histoglobe.min.css">

    <!-- third party javascript -->
    <script type="text/javascript" src="script/third-party/jquery-1.9.0.min.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.browser.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.disable.text.select.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.mousewheel.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.prettyPhoto.js"></script>
    <script type="text/javascript" src="script/third-party/jquery.fullscreenApi.js"></script>

    <!-- histoglobe javascript -->
    <!--   <script type="text/javascript" src="script/histoglobe.min.js"></script> -->
    <script type="text/javascript" src="build/HistoGlobe.js"></script>

    <!-- init histoglobe -->
    <script type="text/javascript">
      jQuery(document).ready(function($) {
        var histoglobe = new HG.HistoGlobe(document.getElementById('histoglobe'));
      });
    </script>

  </head>

  <body>
    <!-- display warning if no javascript is available -->
    <noscript>
      <div class="container">
        <div class="jumbotron" style="margin-top:5%">
          <h1><span class="hg">HistoGlobe</span> benötigt Javascript!</h1>
          <p>Bitte aktivieren Sie in Ihrem Browser Javascript, da <span class="hg">HistoGlobe</span> sonst nicht funktioniert.</p>
          <p><a href="http://www.enable-javascript.com/de/" class="btn btn-primary btn-lg" role="button">Wie aktiviere ich Javascript?</a></p>
        </div>
      </div>
    </noscript>

    <div id="histoglobe"></div>

  </body>

  <link href='http://fonts.googleapis.com/css?family=Marcellus+SC' rel='stylesheet' type='text/css'>

</html>
