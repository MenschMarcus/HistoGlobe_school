var HG = HG || {};

HG.HiventInfoPopover = function(inHivent) {

  var div;

  function init() {
    div = document.createElement("div");
    div.id = "hiventInfoPopover";
    div.innerHTML = "huhu!!!!";
    div.style.position = "absolute";
    div.style.left = "200px";
    div.style.top = "200px";
    div.style.width = "150px";
    div.style.height = "150px";
    div.style.backgroundColor = "#ff0000";

    document.getElementsByTagName("body")[0].appendChild(div);

    div.addEventListener('mousedown', onMouseDown, false);
  }

  function onMouseDown(event) {
    div.addEventListener('mousemove', onMouseMove, false);
    div.addEventListener('mouseup', onMouseUp, false);
    div.addEventListener('mouseout', onMouseOut, false);
    event.preventDefault();
  }

  function onMouseUp(event) {
    div.removeEventListener('mousemove', onMouseMove, false);
    div.removeEventListener('mouseup', onMouseUp, false);
    div.removeEventListener('mouseout', onMouseOut, false);
  }

  function onMouseMove(event) {
    var currentPos = $(div).offset();
    console.log(currentPos);
    $(div).offset({left: event.clientX - currentPos.left,
                   top:  event.clientY - currentPos.top});
  }

  function onMouseOut(event) {
    div.removeEventListener('mousemove', onMouseMove, false);
    div.removeEventListener('mouseup', onMouseUp, false);
    div.removeEventListener('mouseout', onMouseOut, false);
  }

  this.show = function() {
    div.style.visibility = "visible";
  }

  this.hide = function() {
    div.style.visibility = "hidden";
  }

  init();

  return this;

};

