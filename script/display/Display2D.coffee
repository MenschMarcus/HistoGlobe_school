#include HiventHandler.js
#include HiventMarker2D.js

window.HG ?= {}

class HG.Display2D extends HG.Display

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, hiventHandler) ->
    @_container = container
    @_hiventHandler = hiventHandler
    @_initMembers()
    @_initCanvas()
    @_initEventHandling()
    @_initHivents()

  # ============================================================================
  start: ->
    unless @_isRunning
      @_isRunning = true
      @_mapParent.style.display = "block"

  # ============================================================================
  stop: ->
    @_isRunning = false
    @_mapParent.style.display = "none"

  # ============================================================================
  isRunning: ->
    @_isRunning

  # ============================================================================
  getCanvas: ->
    @_mapParent

  # ============================================================================
  center: (longLat) ->
    @_map.panTo [longLat.y, longLat.x]

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initMembers: ->
    @_map       = null
    @_mapParent = null
    @_isRunning = false

  # ============================================================================
  _initCanvas: ->
    @_mapParent = document.createElement "div"
    @_mapParent.style.width = $(@_container.parentNode).width() + "px"
    @_mapParent.style.height = $(@_container.parentNode).height() + "px"

    @_container.appendChild @_mapParent

    options =
      maxZoom:      7
      minZoom:      1
      zoomControl:  false

    @_map = L.map @_mapParent, options
    @_map.setView [51.505, 10.09], 4
    @_map.attributionControl.setPrefix ''

    L.tileLayer('data/tiles/{z}/{x}/{y}.png').addTo @_map

    # boundaries ---------------------------------------------------------------
    $.getJSON "data/ne_50m_admin_0_boundary_lines_land.json", (statesData) =>

      normalStyle =
        color:        "#FFEDC6"
        weight:       2
        opacity:      1

      options =
        style: normalStyle

      data = topojson.feature statesData, statesData.objects.ne_50m_admin_0_boundary_lines_land

      boundaryLayer = L.geoJson(data, options)
      boundaryLayer.addTo @_map

    # areas --------------------------------------------------------------------
    $.getJSON "data/world_low.json", (statesData) =>
      highlightStyle =
        fillColor:    "#000000"
        weight:       0
        opacity:      0
        fillOpacity:  0.05

      normalStyle =
        fillColor:    "#000000"
        weight:       0
        opacity:      0
        fillOpacity:  0

      options =
        style: normalStyle
        onEachFeature:  (feature, layer) => layer.on(
          click:      (e) => @_map.fitBounds e.target.getBounds()
          mouseover:  (e) => e.target.setStyle highlightStyle
          mouseout:   (e) => boundaryLayer.resetStyle e.target
        )

      data = topojson.feature statesData, statesData.objects.countries

      boundaryLayer = L.geoJson(data, options)
      boundaryLayer.addTo @_map

    # africa -------------------------------------------------------------------
    # $.getJSON "data/africa.json", (statesData) =>
    #   normalStyle =
    #     color:        "#AD9B76"
    #     weight:       2
    #     opacity:      1

    #   options =
    #     style: normalStyle

    #   boundaryLayer = L.geoJson(statesData, options)
    #   boundaryLayer.addTo @_map

    @_isRunning = true

  # ============================================================================
  _initEventHandling: ->
    window.addEventListener 'resize', @_onWindowResize, false

  # ============================================================================
  _initHivents: ->
    @_hiventHandler.onHiventsChanged (handles) =>
      marker = new HG.HiventMarker2D handle, this, @_map for handle in handles

    @_map.on "click", HG.deactivateAllHivents

  # ============================================================================
  _onWindowResize: (event) =>
    @_mapParent.style.width = $(@_container.parentNode).width() + "px"
    @_mapParent.style.height = $(@_container.parentNode).height() + "px"
