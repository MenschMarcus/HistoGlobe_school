//include Hivent.js
//include HiventHandle.js

var HG = HG || {};

HG.HiventHandler = function(inPathToHivents) {
  
  //////////////////////////////////////////////////////////////////////////////
  //                          PUBLIC INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  ////////////////////////////// FUNCTIONS /////////////////////////////////////

  // ===========================================================================  
  this.create = function(pathToHivents) {
    initHivents(pathToHivents);
  }
 
  // ===========================================================================  
  this.onHiventsChanged = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      if (!myHiventsChanged)
        myOnHiventsChangedCallbacks.push(callbackFunc);
      else
        callbackFunc(myHiventHandles);
    }
  }
  
  // ===========================================================================  
  this.setTimeFilter = function(timeFilter) {
    myCurrentTimeFilter = timeFilter;
    filterHivents();
  }
  
  // ===========================================================================  
  this.setSpaceFilter = function(spaceFilter) {
    myCurrentSpaceFilter = spaceFilter;
    filterHivents();
  }
  
  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// MEMBER VARIABLES /////////////////////////////////
  var mySelf = this;
  
  var myHiventHandles = [];
  var myFilteredHiventHandles = [];
  var myHiventsChanged = false;
  var myOnHiventsChangedCallbacks = [];
  
  var myCurrentTimeFilter = null; // {start: <Date>, end: <Date>}
  var myCurrentSpaceFilter = null; // { min: {lat: <float>, long: <float>}, 
                                   //   max: {lat: <float>, long: <float>}}
  
  ////////////////////////// INIT FUNCTIONS ////////////////////////////////////

  // ===========================================================================
  function initHivents(pathToHivents) {    
    $.getJSON(pathToHivents, function(h){
      for (var i=0; i<h.length; i++) {
        var hivent = new HG.Hivent(
          h[i].name,
          h[i].category,
          new Date(h[i].date),
          h[i].displayDate,
          h[i].long,
          h[i].lat,
          h[i].description,
          h[i].parties
        );
        
        myHiventHandles.push(new HG.HiventHandle(hivent));
      }
      
      myHiventsChanged = true;

      filterHivents();
      
    }); 

  }
  
  /////////////////////////// MAIN FUNCTIONS ///////////////////////////////////
  
  // ===========================================================================
  function filterHivents() {

    for (var i=0, j=myFilteredHiventHandles.length; i<j; i++) {
      myFilteredHiventHandles[i].destroyAll();
    }
      
    myFilteredHiventHandles = [];
    
    for (var i=0, j=myHiventHandles.length; i<j; i++) {
      var hivent = myHiventHandles[i].getHivent(); 
      var isInTime = myCurrentTimeFilter == null;
      if (!isInTime) {
        isInTime = hivent.date.getTime() >= myCurrentTimeFilter.start.getTime() && 
                   hivent.date.getTime() <= myCurrentTimeFilter.end.getTime();
      }
      
      var isInSpace = myCurrentSpaceFilter == null;
      if (!isInSpace) {
        isInSpace = hivent.lat >= myCurrentTimeFilter.min.lat &&
                    hivent.long >= myCurrentTimeFilter.min.long && 
                    hivent.lat <= myCurrentTimeFilter.max.lat && 
                    hivent.long <= myCurrentTimeFilter.max.long;
      }
      
      if (isInTime && isInSpace)
        myFilteredHiventHandles.push(myHiventHandles[i]);
    }
    
    for (var i=0; i < myOnHiventsChangedCallbacks.length; i++)
      myOnHiventsChangedCallbacks[i](myFilteredHiventHandles);
  } 
  
  // create the object
  this.create(inPathToHivents);
  
  // all done
  return this;

};
