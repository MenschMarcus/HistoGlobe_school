var HG = HG || {};

HG.VideoPlayer = function(inDivID) {
  
  var divID = inDivID;
  var player;
  
  function onPlayerReady(event) {
    event.target.playVideo();
  }
  
  function init() {
  
    player = new YT.Player(divID, {
      events: {
        'onReady': onPlayerReady,
      }
    }); 
  }
  
  this.stopVideo = function() {
    player.stopVideo();
  }
  
  init();
  
  return this;

}
