//include HiventMarker

var HG = HG || {};

HG.hiventMarkerGeometry = 0; 

HG.HiventMarker3D = function(inHivent) {
    
  if (HG.hiventMarkerGeometry == 0)
    HG.hiventMarkerGeometry = new THREE.SphereGeometry(1, 10, 10);  
    
  var hiventDefaultColor = new THREE.Vector3(0.2, 0.2, 0.4);
  var hiventHighlightColor = new THREE.Vector3(1.0, 0.5, 0.0);
  
  var Shaders = {
    'hivent' : {
      uniforms: {
        'color': { type: 'v3', value: null}
      },
      vertexShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'vNormal = normalize( normalMatrix * normal );',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
      '}'
      ].join('\n'),
      fragmentShader: [
      'uniform vec3 color;',
      'varying vec3 vNormal;',
      'void main() {',
        'gl_FragColor = vec4(color, 1.0);',
      '}'
      ].join('\n')
    }
  };
  
  var shader = Shaders['hivent'];
  
  var uniforms = THREE.UniformsUtils.clone(shader.uniforms);
  uniforms['color'].value = hiventDefaultColor;

  var material = new THREE.ShaderMaterial({
    vertexShader: shader.vertexShader,
    fragmentShader: shader.fragmentShader,
    uniforms: uniforms
  });
   
  HG.HiventMarker.call(this, inHivent)
  THREE.Mesh.call(this, HG.hiventMarkerGeometry, material);

  this.getHiventHandle().onHover(function(mousePos){
    uniforms['color'].value = hiventHighlightColor;
  });
  
  this.getHiventHandle().onUnHover(function(mousePos){
    uniforms['color'].value = hiventDefaultColor;
  });
  
  
  return this;

};

HG.HiventMarker3D.prototype = Object.create(THREE.Mesh.prototype);

