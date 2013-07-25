function timeline(inHiventHandler) {

  // create empty timeline object and fill it with member functions
  var timeline = {};

// =========================== H E A D E R =========================== //

  /* MEMBER FUNCTIONS */

  // constructor
  timeline.initTimeline = initTimeline;           // initializes the whole timeline
  timeline.resizeTimeline = resizeTimeline;       // redraws the timeline after resizing of the window
  timeline.drawScroller = drawScroller;           // initializes the timeline scroller

  // setter
  timeline.setNowDate = setNowDate;               // sets the now date and its marker
  timeline.setPeriod = setPeriod;                 // sets the period dates (start and end)
  timeline.setHistEvents = setHistEvents;         // sets the historical events on timeline scroller
  timeline.setMapExtent = setMapExtent;           // sets the viewport coordinates of the maps

  // getter
  timeline.getNow = getNow;                       // gets now date [Date object]
  timeline.getPeriodStart = getPeriodStart;       // gets start date of timeline [decimal year]
  timeline.getPeriodEnd = getPeriodEnd;           // gets end date of timeline [decimal year]
  timeline.getCategories = getCategories;         // gets the selected categories for historical events

  // listener handling
  timeline.addListener = addListener;             // adds a listener to the timeline
  timeline.catChangeHandler = catChangeHandler;   // tells the timeline that the categories have changed

  // event handling                               // event that happens, when ...
  timeline.clickMouse = clickMouse;               // ... mouse button is clicked on timeline
  timeline.moveMouse = moveMouse;                 // ... mouse is moved while button is clicked
  timeline.releaseMouse = releaseMouse;           // ... mouse button is released somewhere
  timeline.clickMoveButtonLeft = clickMoveButtonLeft;     // ... the left/right move buttons of the timeline are pressed
  timeline.clickMoveButtonRight = clickMoveButtonRight;     // ... the left/right move buttons of the timeline are pressed
  timeline.zoom = zoom;                           // ... the timeline gets zoomed by mouse wheel or by zoom buttons
  timeline.togglePlayer = togglePlayer;            // ... history player gets toggled

  /* MEMBER VARIABLES */

  // general histoglobe          (internal date representation of all dates: decimal year, NOT js Date object)
  var minDate, maxDate;         // start and end dates of histoglobe
  var now = {};                 // object containing now date (political date) and its marker on timeline
  var histEvents = [];          // array of historical events visible on the map
  var extent = [];              // array of viewport coordinates (xMin,yMin,xMax,yMax)
  var listeners = [];           // external objects that listen to date changes

  // scroller
  var tlMain;                   // object containing #tlMain -> get width of the timeline viewport by 'tlMain.offsetWidth'
  var tlScroller;               // object containing #tlScroller (larger than tlMain)
  var tlDateMarkers;
  var refDate, refPos;          // reference date and position, used to draw the markers
  var dayDist;                  // pixel distance between two days on the timeline (pixel per day)
  var leftPos, rightPos;        // position of leftmost and rightmost drawn year markers
  var innerThres;               // threshold for now marker in the timeline scroller
  var markerInterval;           // interval [year] in which year markers are drawn

  var currentTimeFilter = null;

	var hiventMarkers = [];

  // play history
  var playerIntervalTime;       // time it takes to jump to next event
  var playerInterval;           // setInterval reference
  var playerAnim;               // animation time

  // event handling
  var downScroller;             // bool: clicked in timeline scroller?
  var downNowMarker;            // book: clicked on now marker?
  var lastPos;                  // x-coordinate of last clicked position
  var totalDragMovement;        // pixel distance dragged on scroller with clicked mouse button
  var moveInterval;             // interval needed for moving with left and right button
  var mouseEvent;               // arbitrary mouse event


// =================== I M P L E M E N T A T I O N =================== //

  /*** CONSTRUCTOR ***/

  function initTimeline() {

    /* INIT MEMBER VARIABLES */

    // general histoglobe
    now.date = 1825; // now = today
    now.marker = $("#nowMarkerWrap")[0];
    now.marker.markerDate = now;          // self-reference, so that now.marker refers to now date
    minDate = 1820;                       // no historical information before 1800
    maxDate = 1845;                   // prevents futuristic timeline

    // scroller
    tlMain = $("#tlMain")[0];
    tlScroller = $("#tlScroller")[0];
    tlDateMarkers = $("#tlDateMarkers")[0];
    refDate = now.date;
    refPos = 0;                           // initially set to 0 for startup animation
    leftPos = 0;
    rightPos = 0;
    dayDist = 0.05;
    innerThres = 0;                       // initially set to 0 for startup animation
    markerInterval = 0;

    // play history
    playerIntervalTime = 8000;
    playerInterval = null;
    playerAnim = 1600;

    // event handling
    downScroller = false;
    downNowMarker = false;
    lastPos = 0;
    totalDragMovement = 0;
    moveInterval = null;
    mouseEvent = null;


    initHivents();
    /* INIT SCROLLER */
    // write now date onto now marker
    $("#polDate").text(decYearToString(now.date));
    // initially draw scroller, scroller at the end, now marker at 0
    $(tlScroller).width($("#tlMain").width()*1.5);
    drawScroller();

    /* STARTUP ANIMATION */
    // set start time of animation after loading the page [ms]

    setTimeout(startAni,300);

    // startup animation function
    function startAni() {
      // set desired position for now marker (golden ratio from the right) and get its actual position
      var desPos = tlMain.offsetWidth*0.618;
      var actPos = rightPos-tlMain.scrollLeft;

      // if difference not too small, recursively scroll timeline towards desired position for now marker
      if (Math.abs(desPos-actPos)>3) {
        scrollTimeline((desPos-actPos)/3, true);
        setTimeout(startAni,50);
      }

      // if close enough to real final width, set it there and finish animation
      else {
        scrollTimeline((desPos-actPos), true);
        innerThres = tlMain.offsetWidth*0.1;
        periodChanged();
      }
    }
  }

  /* browser resize (not redraw whole timeline, only reset variables relative to width) */
  function resizeTimeline() {
    innerThres = tlMain.offsetWidth*0.1;
    $(tlScroller).width(tlMain.offsetWidth*1.5);
    drawScroller();
  }


  /*** SETTER ***/

  /* set now date and position now marker on the timeline scroller, synchronise with period dates */
  function setNowDate(date) {
    // if date given convert it, otherwise take as it was before
    if (date) date = anyToDecYear(date);
    else      date = now.date;

    // move now marker to new position
    var pos = decYearToPos(date);
    setNowPos(pos);

    // tell everybody that now date changed
    nowChanged();
  }

  /* set position now marker on the timeline scroller, synchronise with period dates and min and max dates */
  function setNowPos(pos) {
    // clamp to positions of min and max dates and start and end of main
    var minPos = Math.max(decYearToPos(minDate), $(tlMain).scrollLeft()+(now.marker.offsetWidth/2));
    var maxPos = Math.min(decYearToPos(maxDate), tlMain.offsetWidth+$(tlMain).scrollLeft()-(now.marker.offsetWidth/2));
    pos = Math.min(maxPos, Math.max(minPos, pos));
    // change now date
    now.date = posToDecYear(pos);
    // set now marker to new position
    $(now.marker).css("left", pos);
    // write now date into head of now marker
    $("#polDate").text(decYearToString(now.date));
  }


  /* when period dates have changed, synchronise the now date and its marker on the timeline */
  function synchNow() {
    // init values
    var nowPos = decYearToPos(now.date);        // position of now marker
    var leftThres = $("#tlMain").scrollLeft()+innerThres;
    var rightThres = $("#tlMain").scrollLeft()+$("#tlMain").width()-innerThres;

    // if now date is inside inner threshold, everything is good
    if ((nowPos >= leftThres) && (nowPos <= rightThres)) {
      return
    }
    // if before start, clip now date to start threshold
    if (nowPos < leftThres) {
      now.date = posToDecYear(leftThres);
    }
    // if after end, clip now date to end threshold
    else {
      now.date = posToDecYear(rightThres);
    }
    // set now marker on timeline
    $("#polDate").text(decYearToString(now.date));
    $(now.marker).css("left", decYearToPos(now.date));     // because of rounding errors recalculation of nowPos necessary

    // tell everybody about it
    nowChanged();
  }

  // set period start and end date and draw the scroller on their base
  function setPeriod(start, end) {
    // fix ID10T bug
    if (start > end)
    {
      var temp = start;
      start = end;
      end = temp;
    }
    // clip period dates to minimum and maximum dates of histoglobe
    start = Math.max(start,minDate);    // no historical info before minYear
    end = Math.min(end,maxDate);        // prevents futuristic timeline

    // distance between start and end needs to be at least 3 years
    if (end - start < 3)
    {
      if (end < maxDate-3)  end = start + 3;    // prevents futuristic timeline
      else                  start = end - 3;
    }

    // calculate new reference and redraw scroller
    dayDist = tlMain.offsetWidth / dayDiff(start, end);
    refDate = now.date;
    refPos = (dayDiff(start, now.date) * dayDist) + $(tlMain).scrollLeft();
    drawScroller();

    // synchronise the now date with the period dates
    synchNow();

    // tell everybody that period dates changed
    periodChanged();
  }

  /* set the extent of the map, called on map move events
      lat/lon coordinate pair as lower-left, upper-right
      lat limited to -90 - +90, lon does not wrap around */
  function setMapExtent(ext) {
    extent[0] = ext[0].lon; // xMin
    extent[1] = ext[0].lat; // yMin
    extent[2] = ext[1].lon; // xMax
    extent[3] = ext[1].lat; // yMax

    // get all historical event markers
    var list = histEvents;
    for (var i in list) {
      var x = histEvents[i].data.properties.lon;
      var y = histEvents[i].data.properties.lat;
      var marker = $("#event" + histEvents[i].data.properties.histEventID);
      // check if inside the viewport
      if ((x <= extent[2]) && (x >= extent[0]) && (y <= extent[3]) && (y >= extent[1])) {
        marker.css("display", "block");   // make it visible
      }
      else {
        marker.css("display", "none");    // make it invisible
      }
    }
  }

  function setHistEvents(eventArr) {
    histEvents = eventArr;
    // TODO make this more generic: only update new event markers
  }


  /*** GETTER ***/

  function getNow()         { return now;                           }
  function getPeriodStart() { return posToDate(0);                  }
  function getPeriodEnd()   { return posToDate(tlMain.offsetWidth); }

  function getCategories() {
    var social = $("#catSociety").is(':checked');
    var domestic = $("#catDomestic").is(':checked');
    var foreign = $("#catForeign").is(':checked');
    return {social:social, domestic:domestic, foreign:foreign,
      asUrlParam : function () {
        return (social?"&social=1":"&social=0") +
          (domestic?"&domestic=1":"&domestic=0") +
          (foreign?"&foreign=1":"&foreign=0");
      }
    };
  }


  /*** LISTENER HANDLING ***/

  function addListener(lis) {
    listeners.push(lis);
    lis.nowChanged(decYearToDate(now.date));
    lis.periodChanged(posToDate(0), posToDate(tlMain.offsetWidth));
    lis.categoryChanged(getCategories());
  }

  function nowChanged() {
    var d1 = decYearToDate(now.date);
    for (var idx in listeners) {
      listeners[idx].nowChanged(d1);
    }
  }

  function periodChanged() {

    // inHiventHandler.setTimeFilter(currentTimeFilter);
    var d1 = posToDate($(tlMain).scrollLeft());
    var d2 = posToDate(tlMain.offsetWidth+$(tlMain).scrollLeft());
    for (var i in listeners) {
      listeners[i].periodChanged(d1, d2);
    }
  }

  function catChangeHandler(evt) {
    categoryChanged();
  }

  function categoryChanged() {
    var cats = getCategories();
    for (var i in listeners) {
      listeners[i].categoryChanged(cats);
    }
  }


  /*** SCROLLER ***/

  function drawScroller() {
    // clear the scroller from event markers and year markers
    $('.yearMarker').remove();

    // calculate interval for year markers
    var minDist = 45;
    var yearIntervals = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000];
    var intervalIt = 0;
    while ((dayDist*365.242199) < (minDist / yearIntervals[intervalIt])) {
      intervalIt++;
      var xxxxxxx = 1;      // XXX: avoids weird behaviour in while loop
    }
    markerInterval = yearIntervals[intervalIt];

    // set position of now marker on timeline
    $(now.marker).css("left",(decYearToPos(now.date)));

    // draw first marker on timeline (close to now date)
    var firstYear = Math.ceil(now.date);
    firstYear = firstYear + (markerInterval - (firstYear % markerInterval));
    if (firstYear > maxDate) firstYear -= markerInterval;
    $("#tlDateMarkers").append(makeYearMarker(firstYear));

    // initialize position of leftmost and rightmost marker on timeline
    leftPos = rightPos = decYearToPos(firstYear);

    // set the rest of the year markers in timeline scroller
    appendYearMarkers();

    // put period dates into their fields
    var left = $(tlMain).scrollLeft();
    var right = tlMain.offsetWidth+left;
    var perStart = Math.max(Math.round(posToDecYear(left)),minDate);
    var perEnd = Math.min(Math.round(posToDecYear(right)),Math.floor(maxDate));
    $('#periodStart').val(perStart);
    $('#periodEnd').val(perEnd);

    // eventually set markers for historical events
    updateHivents();
  }


  /** YEAR MARKERS **/

  // fill scroller in between outer threshold with year markers
  function appendYearMarkers() {
    while (leftPos > 0) {
      // get next year to draw
      var prevYear = Math.round(posToDecYear(leftPos))-markerInterval;
      if (prevYear < minDate) break;      // never goes before start year of histoglobe
      $("#tlDateMarkers").prepend(makeYearMarker(prevYear));
      // reset position of leftmost drawn marker
      leftPos = decYearToPos(prevYear);
    }
    while (rightPos < tlScroller.offsetWidth) {
      // get next year to draw
      var nextYear = Math.round(posToDecYear(rightPos))+markerInterval;
      if (nextYear > maxDate) break;      // prevents futuristic timeline
      $("#tlDateMarkers").append(makeYearMarker(nextYear));
      // reset position of rightmost drawn marker
      rightPos = decYearToPos(nextYear);
    }
  }

  // clear all the markers that are beyond the outer threshold
  function stripYearMarkers() {
    while (leftPos <= 0) {
      $("#tlDateMarkers > div.yearMarker:first").remove();
      var leftYear = Math.round(posToDecYear(leftPos));
      leftPos = decYearToPos(leftYear+markerInterval);
    }
    while (rightPos >= tlScroller.offsetWidth) {
      $("#tlDateMarkers > div.yearMarker:last").remove();
      var rightYear = Math.round(posToDecYear(rightPos));
      rightPos = decYearToPos(rightYear-markerInterval);
    }
  } // TODO try if it performs faster when left and rightDate are hold and used

  // create a single year marker
  function makeYearMarker(year) {
    var newMarker = document.createElement('div');
    newMarker.setAttribute('id',year);
    newMarker.setAttribute('class','yearMarker ' + yearMarkerClass(year));
    newMarker.style.left = decYearToPos(year) + 'px';
    newMarker.innerHTML = '<p>'+year+'</p>';
    newMarker.markerDate = {date: year};
    return newMarker;
  }

  // set class of markers for different time periods
  function yearMarkerClass(year) {
    if (year%(20*markerInterval) == 0)
      return 'yearMark1';
    else if (year%(5*markerInterval) == 0)
      return 'yearMark2';
    else
      return 'yearMark3';
  }

  /** HISTORICAL EVENT MARKER **/

  function initHivents() {
    inHiventHandler.onHiventsChanged(function(handles){

      hiventMarkers = [];

      for (var i=0; i<handles.length; i++) {

        var hivent = handles[i].getHivent();
        var posX = dateToPos(hivent.date);

        var hiventMarker = new HG.HiventMarkerTimeline(handles[i],
																										   tlScroller,
																									     posX);
				hiventMarkers.push(hiventMarker);
      }
    });
  }

  function updateHivents() {

		for (var i=0; i<hiventMarkers.length; i++) {
			var posX = dateToPos(hiventMarkers[i].getHiventHandle().getHivent().date);
			hiventMarkers[i].setPosition(posX);
		}
  }

  /** HISTORY PLAYER **/
  function eventUITarget(evt, node)
  {
    /* check if clicked on certain elements or
      if desired element is one of their parents
      syntax: "closest(desEl)" is an object containing all elements
      in the DOM tree of the node clicked on that match with desEl
      => if there is one element in this object, then it is
      the one we are looking for, so the length of the object is 1
      (otherwise it is 0)
    */
    return $(evt.target).closest(node).length==1;
  }

  function togglePlayer(evt)
  {
    /*
      logic: for each player (1, 2, 3) check if
      - player button active => pause animation and toggle player
      - player button inactive => play animation, toggle player and other two players
    */
    // shortcuts for players
    var p1 = $("#histPlayer1");
    var p2 = $("#histPlayer2");
    var p3 = $("#histPlayer3");

    // check state: 0 = not playing, 1 = speed1, 2 = speed2, 3 = speed3
    var state = null;
    if (p1.hasClass('active')) state = 1;
    if (p2.hasClass('active')) state = 2;
    if (p3.hasClass('active')) state = 3;

    // check which play button clicked on
    var playButt = null;
    if (eventUITarget(evt, p1)) playButt = 1;
    if (eventUITarget(evt, p2)) playButt = 2;
    if (eventUITarget(evt, p3)) playButt = 3;

    // first, stop player and toggle clicked button
    stopPlayer();
    if (playButt == 1) p1.button('toggle');
    if (playButt == 2) p2.button('toggle');
    if (playButt == 3) p3.button('toggle');

    // if clicked on active playButt, only pause the animation and do not do anything else
    if (state == playButt)
      return
    // if clicked on inactive playButt, toggle also the old active playButt
    else
    {
      if (state == 1) p1.button('toggle');
      if (state == 2) p2.button('toggle');
      if (state == 3) p3.button('toggle');
      startPlayer(playButt);
    }
  }

  function startPlayer(speed)
  {
    var counter = 0;
    playerInterval = setInterval( function()
      {
        // move timeline into threshold and reset now date
        var nowPos = decYearToPos(now.date);
        nowPos += 5*speed;

        // calculate, if now marker is outside the inner threshold and how far
        var moveDiff = 0;
        if (nowPos < innerThres) {
          moveDiff = innerThres-nowPos;
        }
        else if (nowPos > (tlMain.offsetWidth-innerThres)) {
          moveDiff = tlMain.offsetWidth-innerThres-nowPos;
        }

        // if outside the inner threshold, smoothly move timeline so that now marker is inside the threshold
        if (moveDiff != 0) {
          var f;
          setTimeout(f = function() {
            // special case: really small move diff -> return
            if (Math.abs(moveDiff)<1) return;
            // move timeline by 50% of move diff
            scrollTimeline(moveDiff/2);
            // update movediff
            moveDiff /= 2;
            // go into recursion
            setTimeout(f, 20);
          }, 20);
        }

        setNowPos(nowPos);

        // if max date reached, stop animation
        if (now.date >= maxDate)
        {
          stopPlayer();
          // toggle active player
          var p1 = $("#histPlayer1");
          var p2 = $("#histPlayer2");
          var p3 = $("#histPlayer3");
          if (p1.hasClass('active')) p1.button('toggle');
          if (p2.hasClass('active')) p2.button('toggle');
          if (p3.hasClass('active')) p3.button('toggle');
        }

        // tell everybody that now date changed
        if (counter == 50)
        {
          nowChanged();
          periodChanged();
          counter = 0;
        }

        counter++;
      }, 10
    );
  }

  function stopPlayer() {

    clearInterval(playerInterval);
    playerInterval = null;

    // stop any running movement
    $(now.marker).stop();
  }


  /*** EVENT HANDLING ***/

  /** DIRECT EVENT HANDLING FUNCTIONS **/

  // recognise click on scroller
  function clickMouse(evt) {
    // only react on left mouse button
    if (evt.which != 1) return;
    // change mouse cursor
    $('body').attr('style','cursor: move;');
    // set event handling variables
    lastPos = evt.pageX;
    totalDragMovement = 0;
    // clicked on now marker -> drag it
    if (evt.target.id == 'nowMarkerMain' ||
        evt.target.id == 'nowMarkerHead') {
      downNowMarker = true;
      return;
    }
    if (evt.target.id == 'polDate') return;
    // clicked on scroller -> move timeline
    else {
      downScroller = true;
    }
  }

  // move with clicked mouse button in scroller
  function moveMouse(evt) {
    // set event handling variables
    var xDist = evt.pageX-lastPos;            // distance moved since last event (mostly be <5px)
    totalDragMovement += Math.abs(xDist);
    // clicked on scroller -> move timeline
    if (downScroller) {
      scrollTimeline(xDist);
      synchNow();
    }
    // clicked on now marker -> drag it
    if (downNowMarker) {
      dragNowMarker(evt);
    }
    // reset event handling variables
    lastPos = evt.pageX;
  }

  // release the mouse button
  function releaseMouse(evt) {
    // change cursor back
    $('body').attr('style','');
    // scrolling or moving => reset periods
    if (downScroller || moveInterval) {
      periodChanged();
    }
    // clicking => reset now date to click position
    if (downScroller && totalDragMovement < 5) {
      setNowDate(clickToDecYear(evt));
    }
    // move timeline into threshold and reset now date
    var nowPos = $(now.marker).position().left-$(tlMain).scrollLeft();
    // calculate, if now marker is outside the inner threshold and how far
    var moveDiff = 0;
    if (nowPos < innerThres) {
      moveDiff = innerThres-nowPos;
    }
    else if (nowPos > (tlMain.offsetWidth-innerThres)) {
      moveDiff = tlMain.offsetWidth-innerThres-nowPos;
    }
    // if outside the inner threshold, smoothly move timeline so that now marker is inside the threshold
    if (moveDiff != 0) {
      var f;
      setTimeout(f = function() {
        // special case: really small move diff -> return
        if (Math.abs(moveDiff)<1) return;
        // move timeline by 50% of move diff
        scrollTimeline(moveDiff/2);
        // update movediff
        moveDiff /= 2;
        // go into recursion
        setTimeout(f,50);
      }, 50);
    }
    // finally set now date
    setNowDate();

    // stop scrolling and dragging
    downScroller = false;
    downNowMarker = false;
    // stop moving
    clearInterval(moveInterval);
    moveInterval = null;

    // debugYearMarkers();
  }

  // click on the left and right move button
  function clickMoveButtonRight(pix) {
    // set initial speed of button moving and time moving started
    var buttonMoveSpeed = pix;
    var moveStartTime = new Date().getTime();
    // speed up the moving when clicking
    clearInterval(moveInterval);
    moveInterval = setInterval(function () {
      var nowTime = new Date().getTime();
      var speedup = Math.min(0.05,(nowTime - moveStartTime) / 50000);
      if (buttonMoveSpeed > 0) {
        zoomFromPos(0, buttonMoveSpeed + speedup);
      }
      else {
        zoomFromPos(0, buttonMoveSpeed - speedup);
      }
      synchNow();
    }, 20);
  }

  // click on the left and right move button
  function clickMoveButtonLeft(pix) {
    // set initial speed of button moving and time moving started
    var buttonMoveSpeed = pix;
    var moveStartTime = new Date().getTime();
    // speed up the moving when clicking
    clearInterval(moveInterval);
    moveInterval = setInterval(function () {
      var nowTime = new Date().getTime();
      var speedup = Math.min(0.05,(nowTime - moveStartTime) / 50000);
      if (buttonMoveSpeed > 0) {
        zoomFromPos($('#tlMain').width() - 0, buttonMoveSpeed + speedup);
      }
      else {
        zoomFromPos($('#tlMain').width() - 0, buttonMoveSpeed - speedup);
      }
      synchNow();
    }, 20);
  }

  /** MOVE TIMELINE AND NOW MARKER **/

  function scrollTimeline(pix, ignoreLimit) {
    var fixDist = tlScroller.offsetWidth/3;

    // move only by amount of pixels to clip to golden ratio
    if (!ignoreLimit) {
      pix = Math.min(pix, (tlMain.offsetWidth*0.382)-(leftPos-tlMain.scrollLeft));
      pix = Math.max(pix, (tlMain.offsetWidth*0.618)-(rightPos-tlMain.scrollLeft));
    }

    if (pix == 0) return;     // stops unnecessary calculation

    // perform fixup if necessary
    if ((tlMain.scrollLeft-pix) <= 0) {
      scrollFixup(fixDist);
      $("#tlMain").scrollLeft(tlMain.scrollLeft+fixDist);
    }
    else if ((tlMain.scrollLeft-pix) >= (tlScroller.offsetWidth-tlMain.offsetWidth)) {
      scrollFixup(-fixDist);
      $("#tlMain").scrollLeft(tlMain.scrollLeft-fixDist);
    }
    // actual scrolling activity
    $("#tlMain").scrollLeft(tlMain.scrollLeft-pix);

    // reset date fields
    var start = Math.ceil(posToDecYear(tlMain.scrollLeft));
    var end = Math.floor(posToDecYear(tlMain.scrollLeft+tlMain.offsetWidth));
    $('#periodStart').val(Math.max(start,minDate));
    $('#periodEnd').val(Math.min(end,Math.floor(maxDate)));

    currentTimeFilter = {start: posToDate(tlMain.scrollLeft),
                         end: posToDate(tlMain.scrollLeft+tlMain.offsetWidth)};
  }

  function scrollFixup(pix) {
    // move all elements on timeline by "pix" pixels to the left / rigth;
    var list = $("#tlDateMarkers > div");
    list.each(function(idx) {
      $(this).css("left", decYearToPos(this.markerDate.date)+pix);
    });
    // reset position variables
    refPos += pix;
    leftPos += pix;
    rightPos += pix;

    // clip year markers
    updateHivents();
    appendYearMarkers();
    stripYearMarkers();
  }

  function dragNowMarker(evt) {
    var moveFact = 0.2;   // speeding factor
    mouseEvent = evt;              // get current event
    if (moveInterval === null) {
      var moveCounter = 0;
      moveInterval = setInterval(function () {
        // check if moving of timeline necessary
        var posX = mouseEvent.pageX - $(tlMain).offset().left;
        // move timeline left
        if (posX < innerThres) {
          var off = (innerThres-posX)*moveFact;
          scrollTimeline(off);
        }
        // move timeline right
        else if (posX > (tlMain.offsetWidth-innerThres)) {
          var off = ((tlMain.offsetWidth-innerThres)-posX)*moveFact;
          scrollTimeline(off);
        }
        // put now marker where mouse is
        var newNowPos = posX + $(tlMain).scrollLeft();
        setNowPos(newNowPos);

        // every x times really change now date
        if ((++moveCounter)%5 == 0) {
          nowChanged();
          periodChanged();
        }

      },20);
    }
  }


  /** ZOOM TIMELINE **/
  function zoomFromPos(pos, delta) {
    var evt = {
        'pageX': pos + $('#tlMain').offset().left
    };

    zoom(evt, delta);
  }


  function zoom (evt, delta) {

    // prevent from scrolling the page
    if (evt.preventDefault) evt.preventDefault();

    // init values
    var zoomFactor = 1.15;
    var minDist = tlMain.offsetWidth/dayDiff(minDate,maxDate);
    var maxDist = 0.45;

    // if mouse wheel used
    if (evt)
    {
      refDate = clickToDecYear(evt);
      refPos = evt.pageX-$('#tlScroller').offset().left;
    }
    // if zoom in or out buttons used
    else
    {
      refDate = posToDecYear(tlMain.offsetWidth/2);
      refPos = tlMain.offsetWidth/2;
    }
    // change day distance and clip it
    dayDist *= Math.pow(zoomFactor,delta);
    dayDist  = Math.min(Math.max(dayDist,minDist),maxDist);

    // redraw the scroller
    drawScroller();

    // synch the now date to new period dates
    synchNow();

    // make sure extreme markers stay inside golden ratio
    // Take the code as it is. Do not question it. Do not change it. Is works :) Thank you!
    if ((leftPos-tlMain.scrollLeft) >= (tlMain.offsetWidth*0.382)) {
      scrollTimeline((tlMain.offsetWidth*0.382)-(leftPos-tlMain.scrollLeft));
    }
    else if ((rightPos-tlMain.scrollLeft) <= (tlMain.offsetWidth*0.618)) {
      scrollTimeline((tlMain.offsetWidth*0.618)-(rightPos-tlMain.scrollLeft));
    }
    synchNow();

    // tell everyone, that period dates changed
    periodChanged();
  }


  /*** DEBUG FUNCTIONS ***/

  function debugYearMarkers() {
    _d.clearlog();
    var list = $(".yearMarker");
    list.each(function(idx) {
      var year = $(this).attr("id");
      var actPos = $(this).position().left;
      var assPos = decYearToPos(year);
      var diff = actPos - assPos;
      _d.log(year + " " + actPos + " " + assPos + " " + diff);
    });
  }


  /*** AUXILIARY FUNCTIONS ***/

  // input: a Date object, output: x-position [px] in the timeline scroller
  function dateToPos(date) {
    // 1. make it a decimal year
    date = dateToDecYear(date);
    // 2. calculate the x-position of the marker
    return dayDiff(refDate,date)*dayDist + refPos;
  }

  // input: a decimal year, output: x-position [px] in the timeline scroller
  function decYearToPos(decYear) {
    // return the position of the marker for that date
    return dayDiff(refDate,decYear)*dayDist + refPos;
  }


  // input: position [px], output: a Date object
  function posToDate(pos) {
    // inverse function of dateToPos
    var decYear = refDate + ((pos-refPos)/dayDist)/365.242199;
    return decYearToDate(decYear);
  }

  // input: position [px], output: a decimal year
  function posToDecYear(pos) {
    // inverse function of dateToPos
    return refDate + ((pos-refPos)/dayDist)/365.242199;
  }

  // input: Date object (internal), output: string 'DD.MM.YYYY' (external)
  function decYearToString(date) {
    var dateObj = decYearToDate(date);
    return padZero(dateObj.getDate()) + "." + padZero(dateObj.getMonth()+1) + "." + dateObj.getFullYear();
  }

  // input: decimal year, output: Date object
  function decYearToDate(decYear) {
    if (decYear instanceof Date) return decYear;        // if already a date, return it
    var fullYear = Math.floor(decYear);
    if (isLeapYear(fullYear)) return new Date(fullYear, 0, ((decYear-fullYear)*366)+1,0,0,0);
    else                      return new Date(fullYear, 0, ((decYear-fullYear)*365)+1,0,0,0);
  }

  // input: Date object, output: decimal year
  function dateToDecYear(date) {
    var fullYear = date.getFullYear();
    // calculate difference in days between actual date and 1. Jan of that year
    var diff = dayDiff(new Date(fullYear, 0, 1), date);
    // day difference is the fractional part of the year
    if (isLeapYear(fullYear)) return fullYear + (diff/366);
    else                      return fullYear + (diff/365);
  }

  // input: anything, output: decimal year
  function anyToDecYear(str) {
    // if Date object
    if (str instanceof Date)    return dateToDecYear(str);
    // if already decimal year
    if (!isNaN(str))             return str;
    // otherwise it must be "DD.MM.YYYY"
    var dateParts = String(str).split('.');     // [0] = DD, [1]=MM, [2]=YYYY
    var dateObj = new Date(dateParts[2], dateParts[1]-1, dateParts[0]);
    return dateToDecYear(dateObj);
  }

  // input: click event on timeline, output: a DateObject
  function clickToDate(evt) {
    var clickPix = evt.pageX-$('#tlScroller').offset().left;
    return posToDate(clickPix);
  }

  // input: click event on timeline, output: a decimal year
  function clickToDecYear(evt) {
    var clickPix = evt.pageX-$('#tlScroller').offset().left;
    return posToDecYear(clickPix);
  }

  // input: two dates as Date objects or fractional years, output: the difference between both dates in days
  function dayDiff(date1, date2) {
    // make both a Date object
    if ((date1 instanceof Date)==false) date1 = decYearToDate(date1);
    if ((date2 instanceof Date)==false) date2 = decYearToDate(date2);
    // get difference in ms
    var msDiff = date2.getTime() - date1.getTime();
    // return difference in days
    return (msDiff / 86400000);
  }

  // input: year, output: boolean (leapYear=1, commYear=0)
  function isLeapYear(year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        if (year % 400 == 0) {
          return true;
        }
        return false;
      }
      return true;
    }
    return false;
  }

  // input: one- or two-digit Integer, output: two-digit Integer (with leading 0 if necessary)
  function padZero(int) {
    return int < 10 ? ("0"+int) : (int);
  }


  // return the timeline object
  return timeline;
}
