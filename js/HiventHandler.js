//include Hivent.js

var HG = HG || {};

HG.HiventHandler = function() {
  
  var hivents = [];
  
  function init() {    
    
    $.getJSON("data/hivents.json", function(h){
      for (var hivent=0; hivent<h.length; hivent++) {
        hivents.push(new HG.Hivent(
            h[hivent].name,
            h[hivent].category,
            h[hivent].date,
            h[hivent].long,
            h[hivent].lat,
            h[hivent].parties
        ));
      }
    }); 

  }
  
  this.getAllHivents = function() {
    return hivents;
  }
  
  init();
  
  return this;


};

