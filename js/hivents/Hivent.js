var HG = HG || {};

HG.Hivent = function(inName, inCategory, inDate, 
                     inLong, inLat, inDescription, inParties) {
  
  this.name = inName;
  this.category = inCategory;
  this.date = inDate;
  this.long = inLong;
  this.lat = inLat;
  this.description = inDescription;
  this.parties = inParties;

  return this;

};

