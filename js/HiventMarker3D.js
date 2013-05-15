var HG = HG || {};

HG.HiventMarker3D = function(inHivent, geometry, material) {
  
  THREE.Mesh.call(this, geometry, material);
  
  var hivent = inHivent;
    
  function init() {
    
  }
  
  this.getHivent = function() {
    return hivent;  
  }

  init();
    

  return this;

};

HG.HiventMarker3D.prototype = Object.create(THREE.Mesh.prototype);

