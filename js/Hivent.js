var HG = HG || {};

HG.Hivent = function(inName, inCategory, inDate, 
                     inLong, inLat, inParties) {
  
  this.name = inName;
  this.category = inCategory;
  this.date = inDate;
  this.long = inLong;
  this.lat = inLat;
  this.parties = inParties;

  return this;

};

