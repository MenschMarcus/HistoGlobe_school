var HG = HG || {};

HG.hiventInfoCount = 0;

HG.HiventMarker = function(inHiventHandle, inParent) {

  var self = this;
  var hiventInfo;

  this.getHiventHandle = function() {
    return inHiventHandle;
  }

  this.showHiventName = function(displayPosition) {
    hiventInfo.style.left = displayPosition.x + "px";
    hiventInfo.style.top = displayPosition.y + "px";
    $(hiventInfo).tooltip("show");
  }

  this.hideHiventName = function(displayPosition) {
    $(hiventInfo).tooltip("hide");
  }

  this.showHiventInfo = function(displayPosition) {
    hiventInfo.style.left = displayPosition.x + "px";
    hiventInfo.style.top = displayPosition.y + "px";
    $(hiventInfo).popover("show");
    $(hiventInfo).tooltip("hide");
  }

  this.hideHiventInfo = function(displayPosition) {
    $(hiventInfo).popover("hide");
  }

  this.enableShowName = function() {
		inHiventHandle.onMark(self, this.showHiventName);
		inHiventHandle.onUnMark(self, this.hideHiventName);
	}

  this.enableShowInfo = function() {
		inHiventHandle.onActive(self, this.showHiventInfo);
		inHiventHandle.onInActive(self, this.hideHiventInfo);
	}

  function init() {
    hiventInfo = document.createElement("div");
    hiventInfo.class = "btn";
    hiventInfo.id = "hiventInfo_" + HG.hiventInfoCount;
    hiventInfo.style.position = "absolute";
    hiventInfo.style.left = "0px";
    hiventInfo.style.top = "0px";
    hiventInfo.style.visibility = "hidden";
    hiventInfo.style.pointerEvents = "none";

    if (inParent)
      inParent.appendChild(hiventInfo);

    var hivent = inHiventHandle.getHivent();

    $(hiventInfo).tooltip({title: hivent.name, placement: "top"});

    var hiventContent = "<p align=\"right\">" + hivent.displayDate + "</p>" + hivent.description;

    $(hiventInfo).popover({title: hivent.name, placement: "top", html: "true", content: hiventContent});

    HG.hiventInfoCount++;
  }

  init();

  return this;

};

