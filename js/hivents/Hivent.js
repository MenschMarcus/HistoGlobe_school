var HG = HG || {};

HG.Hivent = function(inName, inCategory, inDate, inDisplayDate,
                     inLong, inLat, inDescription, inParties) {
  
  this.name = inName;
  this.category = inCategory;
  this.date = inDate;
  this.displayDate = inDisplayDate;
  this.long = inLong;
  this.lat = inLat;
  this.description = inDescription;
  this.parties = inParties;

  this.copy = function() {
    return new HG.Hivent(this.name, this.category, this.date, this.displayDate,
                         thisl.long, this.lat, this.description, this.parties);
  }

  return this;

};

