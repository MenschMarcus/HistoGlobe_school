//include Hivent.js

var HG = HG || {};

HG.Display = function() {

  return this;
};

HG.Display.prototype.focus = function(hivent) {
  this.center({x: hivent.long, y: hivent.lat});
}
