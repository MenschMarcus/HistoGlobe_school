#include Extendable.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarker3D extends THREE.Mesh

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hivent, display, parent) ->

    HG.mixin @, HG.HiventMarker
    HG.HiventMarker.call @, hivent, parent

    unless HIVENT_MARKER_3D_GEOMETRY?
      HIVENT_MARKER_3D_GEOMETRY = new THREE.SphereGeometry 1, 10, 10

    @_shader = HIVENT_MARKER_3D_SHADERS['hivent']

    @_uniforms = THREE.UniformsUtils.clone @_shader.uniforms
    @_uniforms['color'].value = HIVENT_DEFAULT_COLOR

    @_material = new THREE.ShaderMaterial {
      vertexShader: @_shader.vertexShader,
      fragmentShader: @_shader.fragmentShader,
      uniforms: @_uniforms
    }

    THREE.Mesh.call @, HIVENT_MARKER_3D_GEOMETRY, @_material

    @getHiventHandle().onFocus(@, (mousePos) =>
      if display.isRunning()
        display.focus @getHiventHandle().getHivent()
    )

    @getHiventHandle().onMark @, (mousePos) =>
      @_uniforms['color'].value = HIVENT_HIGHLIGHT_COLOR

    @getHiventHandle().onUnMark @, (mousePos) =>
      @_uniforms['color'].value = HIVENT_DEFAULT_COLOR

    @getHiventHandle().onLink @, (mousePos) =>
      @_uniforms['color'].value = HIVENT_HIGHLIGHT_COLOR

    @getHiventHandle().onUnLink @, (mousePos) =>
      @_uniforms['color'].value = HIVENT_DEFAULT_COLOR

    @getHiventHandle().onDestruction @, @_destroy

    @enableShowName()
    @enableShowInfo()

  # ============================================================================
  _destroy: ->
    delete @;
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  HIVENT_MARKER_3D_GEOMETRY = 0
  HIVENT_DEFAULT_COLOR = new THREE.Vector3 0.2, 0.2, 0.4
  HIVENT_HIGHLIGHT_COLOR = new THREE.Vector3 1.0, 0.5, 0.0
  HIVENT_MARKER_3D_SHADERS = {
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
  }

