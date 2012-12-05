// ======= Initializations, controller and debugging ======= //

/** main function **/
var main = (function() {
    var m = {},
        infoFilled = false,
        infobox_baseheight = $('#infoBox').height();
        
    // put event information to infoBox
    // params: event on map, click event OR true-> get only first, force specific id, goto=true: set map to view event
    m.getEventInfo = function(mapevent, evt, forceid, goto) {
        var getfirst = false;
        if (evt === true) getfirst = true;
    	
        var id = mapevent.histEventID;
        if (getfirst) {
            $.ajax({
             type: 'GET',
             url: "api/eventinfo.php?eventid=" + id,
             success: eventdone,
             dataType:"json"
            });
        } else {
            var cats = m.timeline.getCategories();
            $.ajax({
             type: 'GET',
             url: "api/eventinfo.php?eventid=" + id +
                 "&start=" + main.timeline.getPeriodStart().getFullYear() + 
                 "&end="+ main.timeline.getPeriodEnd().getFullYear() + 
                 "&zoom=" + Math.floor(main.histomap.map.zoom()) +
                 cats.asUrlParam(),
             success: eventdone,
             dataType: "json"
            });
        }
        
        return true;
        
        function eventdone(data) {
            if (data.length == 1 || getfirst) {
                m.setEventInfo(data[0], goto);
                return;
            }
            
            // more than one event close by, display selection box
            var div = document.createElement('div');
            div.setAttribute('id','eventSelectBox');
            
            var tbl = document.createElement('table');
            var headerr = document.createElement('tr');
            var header = document.createElement('th');
            header.innerHTML = "Events that happened here";
            headerr.appendChild(header);
            tbl.appendChild(headerr);
            
            for (var i = 0; i < data.length; i++) {
                var trow = document.createElement("tr");
                trow.setAttribute('class','row' + i % 2); // cycle row class
                trow.onclick = (function(thisdata) {
                  return function() { m.setEventInfo(thisdata);};
                }(data[i]));
                var td = document.createElement("td");
                td.innerHTML = m.l10n.formatISODateString(data[i].date) + ' &mdash; ' +data[i].name;
                trow.appendChild(td);
                tbl.appendChild(trow);
            }
            div.appendChild(tbl);
            $('#body').height();
            var mpos = mousePosFromEv(evt);
            var body = $('body');
            div.setAttribute('style',
                (mpos[0] > body.width()/2? "right:" + (body.width() - mpos[0]):"left:" + mpos[0]) + "px;" +
                (mpos[1] > body.height()/2? "bottom:" + (body.height() - mpos[1]):"top:" + mpos[1] ) + "px");
            $('body').append(div);
        }
    };
    m.setEventInfo = function(data, goto) {
        
        infobox_baseheight = $('#infoBox').height();
        // which date to use
        var usedate;
        if (data.effectDate && data.effectDate != "")
        	usedate = data.effectDate;
        else
        	usedate = data.date;
        infoFilled = false; // prevent setNow from clearing infobox
        m.timeline.setNow(new Date(usedate));
        openWithInfo(data.name, m.l10n.formatISODateString(usedate),
                     data.abstract, data.link)
        
        // set nowdate and highlight borders
        //if (goto) m.histomap.gotopoint(data);
        m.histomap.setEventId(data.histEventID);
    };
    
    // Open and fill infobox with given information
    function openWithInfo(title,date,abstr,link) {
        infoFilled = true;
        m.removeEventSelect();
        
        // set texts, then animate opening
        $("#eventTitle").html(title);
        $("#eventDate").html(date);
        $("#eventAbstract").html(abstr);
        $("#infoBoxHr").html('<hr>');
        if (link != '') {
          $("#eventInfo").html('<a href="' + link + '" target="_blank">MORE</a>');
        }
        $("#closelink").html('x');
        
        // set maxheight to current height, so animation goes smoother
        // assuming no more than 350px is needed for now
        $("#infoBox")
            .css('max-height', infobox_baseheight)
            .animate({'max-height':350}).addClass('infoBox-filled');
    }
    
    
    // Fill infobox with contry information
    m.setCountryInfo = function(props) {
      openWithInfo(
        props.nameOfficial + ' (' +props.nameCommon + ')',
        m.l10n.formatISODateString(props.start) + " &ndash; " +
        (props.end ? m.l10n.formatISODateString(props.end):'Today'),
        '', // TODO ancestors & successors with links
        'http://en.wikipedia.org/wiki/' + props.nameCommon);
    };
    
    m.clearInfo = function() {
        if (!infoFilled) return;
        
        var info = $("#infoBox");
        // remove event marker and coloured borders on map        
        m.histomap.setEventId();
        // remove list of events, if open
        m.removeEventSelect();
        
        // set maxheight to current height, so animation goes smoother
        info.css('max-height',info.height());
        
        // hide text and show logo before animating
        info.css('color','transparent');
        $('#eventInfo > a').css('color','transparent');
        info.removeClass('infoBox-filled');
        
        // animate the infobox (close) and clear when done
        info.animate(
            {'max-height':infobox_baseheight},
            200,
            'swing',
            function() {
                // erase content from infobox
                $("#eventTitle").empty();
                $("#eventDate").empty();
                $("#eventAbstract").empty();
                $("#eventInfo").empty();
                $("#infoBoxHr").empty();
                $("#closelink").empty();
                // reset text color
                info.css('color','');       
                $('#eventInfo > a').css('color','');
            }
        );
        infoFilled = false;
    };
    m.removeEventSelect = function() {
       // remove any selection box
       $("#eventSelectBox").remove();
    };
    
    m.periodChanged = function() {
       // remove any selection box
       $("#eventSelectBox").remove();
    };
    
    m.nowChanged = function(date) {
	      $('#bigDateBox').text(date.getFullYear());
        m.clearInfo();
        if (m.histomap) m.histomap.setEventId();    	
    };
    m.categoryChanged = function() {}; // NOOP
    
    // date localization
    m.l10n = {};
    m.l10n.locale = 'europe';
    m.l10n.formatDate = function (dateObj) {
        switch (m.l10n.locale) {
        case 'europe':
        default:
            return padZero(dateObj.getDate()) + "." +
                   padZero(dateObj.getMonth()+1) + "." +
                   dateObj.getFullYear();
            break;
        case 'ISO8601':
        case 'c':
            return dateObj.getFullYear() + "-" +
                   padZero(dateObj.getMonth()+1) + "-" +
                   padZero(dateObj.getDate());
            break;
        }
    };
    m.l10n.formatISODateString = function(str) {
        return m.l10n.formatDate(m.l10n.ISOStringToDate(str));
    }
    m.l10n.ISOStringToDate = function(str) {
        var p = str.split('-');
        return new Date(p[0], p[1]-1, p[2], 0, 0, 0);
    }
    
    return m;
}());

// input: one- or two-digit Integer, output: two-digit Integer (with leading 0 if necessary)
function padZero(int) {
    return int < 10 ? ("0"+int) : (int);
}
function mousePosFromEv(e) {
    if (e.pageX || e.pageY) {
        posx = e.pageX;
        posy = e.pageY;
    }
    else if (e.clientX || e.clientY) {
        posx = e.clientX + document.body.scrollLeft
                + document.documentElement.scrollLeft;
        posy = e.clientY + document.body.scrollTop
                + document.documentElement.scrollTop;
    }
    return [posx,posy];
}

// dynamically load css from URL

function loadCss(url) {
  // keep a static counter for tag id
	if ( typeof loadCss.counter == 'undefined' ) {
        loadCss.counter = 0;
    }
	var cssId = 'dynCss_' + loadCss.counter;
	if (!document.getElementById(cssId))
	{
	    var head  = document.getElementsByTagName('head')[0];
	    var link  = document.createElement('link');
	    link.id   = cssId;
	    link.rel  = 'stylesheet';
	    link.type = 'text/css';
	    link.href = url;
	    link.media = 'all';
	    head.appendChild(link);
	}
}

/*** INITIALIZATION OF EVERYTHING ***/
$(function() {

  // initiate debug box
  _d.addbox();

  // profiling
  // main.ptimer = setInterval(function(){_d.log(__POLYPERF.printTot());},150);
  
  // initiate the timeline
  main.timeline = timeline();
  main.timeline.initTimeline();
  
  window.onload = function() {
    //main.timeline.initTimeline();
  };
  window.onresize = main.timeline.resizeTimeline;

  main.timeline.addListener(main);


  /** EVENT HANDLING **/

  /* DATES */
  
  // defaults for date entries
  $.dateEntry.setDefaults({minDate: new Date(1800, 0, 1), maxDate: new Date(), spinnerImage: ''});
  
  // now = political date
  $("#polDate").dateEntry({
    dateFormat: 'dmy.',
    initialField: 2,
    // spinnerImage: 'lib/jquery/dateentry/spinnerHistoglobe.png',
    // spinnerBigImage: 'lib/jquery/dateentry/spinnerHistoglobeBig.png'
  });
    
  $("#polDate")
    // press "enter" after typing date in now field
    .bind("keypress",nowKeyHandler)
    // allow certain keys to be pressed while date gets entered
	  .bind("keydown",allowCertainKeys)
	  .bind("keypress",allowCertainKeys);
	  
	// period = historical dates
  $("#periodStart")
    // press "enter" after typing date in period fields
    .bind("keydown",periodKeyHandler)
    // allow certain keys to be pressed while date gets enteres    
    .bind("keydown",allowCertainKeys)
    .bind("keypress",allowCertainKeys);
    
  $("#periodEnd")
    // press "enter" after typing date in period fields
    .bind("keydown",periodKeyHandler)
    // allow certain keys to be pressed while date gets enteres    
    .bind("keydown",allowCertainKeys)
    .bind("keypress",allowCertainKeys);

	function nowKeyHandler(evt) {
    // send "now" date to timeline (does not need to be a date object yet)
		if (evt.which == 13) {
		  main.timeline.setNow($("#polDate").val());
		  return false;
		}
	}
	
	function nowClickHandler(evt) {
    // send "now" date to timeline (does not need to be a date object yet)
    main.timeline.setNow($("#polDate").val());
	}
  
	function periodKeyHandler(evt) {
    // send both period start and end date to timeline
    if (evt.which == 13) {
      main.timeline.setPeriod(
        parseInt($("#periodStart").val(),10),
        parseInt($("#periodEnd").val(),10));
    }
	}
	
	function periodClickHandler() {
	  // send both period start and end date to timeline
	  main.timeline.setPeriod(
	    parseInt($("#periodStart").val(),10),
	    parseInt($("#periodEnd").val(),10));
  }
  
  function allowCertainKeys(evt) {
 		switch(evt.which) {
			case 37: case 38: case 39: case 40:     // arrow keys
			case 45: case 95:                       // -
			case 43: case 61:                       // +
				evt.stopPropagation();
				break;

			default:
				break;
		}
  }
  
  
  /* INTERACTION WITH TIMELINE */

  // global bindings -> called when mouse event happend somewhere in the viewport
	$(window).mousemove(main.timeline.moveMouse);       // mouse is moved -> if happened in timeline, move it <-> otherwise ignore it
	$(window).mouseup(main.timeline.releaseMouse);      // mouse button released -> differentiates between scrolling/moving and only clicking

	$("#tlScroller").bind("mousedown",main.timeline.clickMouse);
	$("#tlScroller").bind("mousewheel",main.timeline.zoom);
	
	// dragging the now marker
	$("#tlScroller").bind("mousemove",main.timeline.moveMouseOutThres);
	
	// moving the timeline scroller with left and right buttons
	$("#tlMoveRight").bind("mousedown", function(evt) { if (evt.button == 0) main.timeline.clickMoveButton(-10)});
	$("#tlMoveLeft").bind("mousedown",  function(evt) { if (evt.button == 0) main.timeline.clickMoveButton(10)});
	
	// zooming the timeline scroller with + and -
	$('#tlZoomIn').bind("click", function() {main.timeline.zoom(null, 1)});
	$('#tlZoomOut').bind("click", function() {main.timeline.zoom(null, -1)});

  // play history
  $('.playerGo').click(main.timeline.togglePlayer);


  /* CONVENIENCE FEATURES */

  // defocusing the input fields, clearing boxes
  $("#map").bind("click", function() {
	  $("#polDate").blur();
	  $("#periodStart").blur();
	  $("#periodEnd").blur();
	  main.removeEventSelect();
  });

  // disable selection of years in timeline
  $("#tlMain").disableTextSelect();  
  $("#tlScroller").disableTextSelect();
  $("#tlMoveLeft").disableTextSelect();
  $("#tlMoveRight").disableTextSelect();
  $("#tlPlayer").disableTextSelect();
  $("#bigDateBox").disableTextSelect();
  
  // close infobox link
  $("#closelink").click(main.clearInfo);
  // apply some css locally
  $("#infoBox").css({'max-height':'0px','overflow':'hidden'});
  $("#catSociety").click(main.timeline.catChangeHandler);
  $("#catForeign").click(main.timeline.catChangeHandler);
  $("#catDomestic").click(main.timeline.catChangeHandler);

  // Init map
  main.histomap = HistoMap(main.timeline);
  
  // load special css for Firefox
  // load special css for browsers that botch up rendering svg font stroke
  var ffox = /firefox\/(\d+)\./i.exec(navigator.userAgent);
  var chrome = /chrome/i.exec(navigator.userAgent);
  var windows = /windows/i.exec(navigator.userAgent);
  var opera = /opera/i.exec(navigator.userAgent);
  if (opera) {
    loadCss('css/cname_fix.css');
  }
  
  }
);

/** function to handle date parameter given in url **/
function util() {

	var nowDate = getURLParameter('now');
	
	// quick and dirty check if the date is valid, else current date
	if (nowDate=="null") {
		nowDate = new Date();
	} else {
		nowDate = new Date(nowDate);
		if (isNaN(nowDate.getTime())) {
			nowDate = new Date();
		}
	}
	
	$(function() {
	    //set date fields
		$('#politicalDate').val(formatDate(nowDate));
	});
	
    function getURLParameter(name) {
    	return decodeURI(
	        (RegExp('[?|&]' + name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
    	);
	}
	function formatDate(d) {
		return pad(d.getFullYear(),4,'0') + '-' + pad(d.getMonth()+1,2,'0') + '-' + pad(d.getDate(),2,'0');
		function pad(s,n,p) {
			if (p.length < 1) p=0;
			for (s = s + ''; s.length<n; s = p + s);
			return s;
		}
	}
}


/* create a debugging box */
var _d = function () {
	var d = {};
	var dl;
	
	d.levels = {
		'OFF':0,
		'INFO':1,
		'DEBUG':3
	};
	d.level = d.levels.DEBUG; // default log level
  d.stuff = function () {
    main.timeline.stripMarkers();
  }
	d.addbox = function() { // build and add box to main page
		if ($('#debugbox').length > 0) return;
		
		var d = $('<div/>', {
			id: 'debugbox',
			style:'font-size:10px;left:200px;width:50%;position:absolute;background-color:black;border:1px grey solid;border-radius:2px;padding:3px;'
		});
		$('<div>',{id:'debuglog',style:'max-height:250px;overflow:auto;color:white;'}).appendTo(d);
		$('<div>',{id:'links'}).html(
			'<span style="color:#911">Debug log - </span>'
			+'<a href="" onclick="_d.clearlog();return false;">clear</a> ' 
			+'<a href="" onclick="_d.toggle();return false;">toggle</a> '
			+'<span id="dbg_ell" style="color:grey"></span>'
			+'<a onclick="_d.stuff();return false;">Ping!</a> '
			+'<a style="float:right" href="" onclick="_d.removebox();return false;">x</a>'
			).appendTo(d);
		$('body').prepend(d);
	}
		
	d.removebox = function() { // throw box away
		$('#debugbox').remove();
		dl = null;
	}
	
	d.toggle = function() { // toggle show/hide
		if (!dl)
			dl = $('#debuglog');
		if (dl.is(':hidden')) {
			$('#dbg_ell').html('');
			dl.show();
		} else{
			if (dl.html() != '') $('#dbg_ell').html('. . .');
			dl.hide();
		}
	}
	
	d.clearlog = function() {
		$('#debuglog').html('');
		$('#dbg_ell').html('');
	}
	
	d.log = function (message) { // log a message
		if (this.level > d.levels.OFF)
			_log(message);
	};
	
	d.debug = function(message) { // log a debug-level message
		if (this.level >= d.levels.DEBUG)
			_log(message);
	};
	
	function _log (message) { // append message to log and scroll
		if (!dl)
			dl = $('#debuglog');
		if (dl.length==0) return;
		// escape html
		message = String(message).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
		// make newlines
		message = String(message).replace(/\n/g,"<br>")
		dl.append($('<span>').html('' + message)).append($('<br>'));
		dl.animate({scrollTop:dl[0].scrollHeight},5);
		if (dl.is(':hidden')) {$('#dbg_ell').html('. . .');};
	}
	return d;
}();
