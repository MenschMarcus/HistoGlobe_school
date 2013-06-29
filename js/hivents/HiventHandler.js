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
  this.onHiventsLoaded = function(callbackFunc) {
    if (callbackFunc && typeof(callbackFunc) === "function") {
      if (!myHiventsLoaded)
        myOnHiventsLoadedCallbacks.push(callbackFunc);
      else
        callbackFunc(myHiventHandles);
    }
  }
 
  // ===========================================================================  
  this.getHiventHandles = function() {
    return myHiventHandles;
  }
 
  // ===========================================================================  
  this.setTimeFilter = function(timeFilter) {
    myCurrentTimeFilter = timeFilter;
  }
  
  // ===========================================================================  
  this.setSpaceFilter = function(spaceFilter) {
    myCurrentSpaceFilter = spaceFilter;
  }
  
  //////////////////////////////////////////////////////////////////////////////
  //                         PRIVATE INTERFACE                                //
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////// MEMBER VARIABLES /////////////////////////////////
  var mySelf = this;
  
  var myHiventHandles = [];
  var myHiventsLoaded = false;
  var myOnHiventsLoadedCallbacks = [];
  
  var myCurrentTimeFilter = null;
  var myCurrentSpaceFilter = null;
  
  ////////////////////////// INIT FUNCTIONS ////////////////////////////////////

  // ===========================================================================
  function initHivents(pathToHivents) {    
    $.getJSON(pathToHivents, function(h){
      for (var i=0; i<h.length; i++) {
        var hivent = new HG.Hivent(
          h[i].name,
          h[i].category,
          h[i].date,
          h[i].displayDate,
          h[i].long,
          h[i].lat,
          h[i].description,
          h[i].parties
        );
        
        myHiventHandles.push(new HG.HiventHandle(hivent));
      }
      
      myHiventsLoaded = true;
      
      for (var i=0; i < myOnHiventsLoadedCallbacks.length; i++)
        myOnHiventsLoadedCallbacks[i](myHiventHandles);
    }); 

  }
  // create the object
  this.create(inPathToHivents);
  
  // all done
  return this;

};
