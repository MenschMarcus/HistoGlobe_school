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

    # # boundaries ---------------------------------------------------------------
    # $.getJSON "data/world.json", (statesData) =>

    #   normalStyle =
    #     color:        "#FFEDC6"
    #     weight:       2
    #     opacity:      1

    #   options =
    #     style: normalStyle

    #   data = topojson.feature statesData, statesData.objects.geo

    #   boundaryLayer = L.geoJson(data, options)
    #   boundaryLayer.addTo @_map

    eu = {
      "BEL": new Date(1958, 1, 1)
      "FR1": new Date(1958, 1, 1)
      "ITA": new Date(1958, 1, 1)
      "LUX": new Date(1958, 1, 1)
      "NL1": new Date(1958, 1, 1)
      "DEU": new Date(1958, 1, 1)
      "DN1": new Date(1973, 1, 1)
      "IRL": new Date(1973, 1, 1)
      "GB1": new Date(1973, 1, 1)
      "GRC": new Date(1981, 1, 1)
      "PRT": new Date(1986, 1, 1)
      "ESP": new Date(1986, 1, 1)
      "FI1": new Date(1995, 1, 1)
      "AUT": new Date(1995, 1, 1)
      "SWE": new Date(1995, 1, 1)
      "EST": new Date(2004, 5, 1)
      "LVA": new Date(2004, 5, 1)
      "LTU": new Date(2004, 5, 1)
      "MLT": new Date(2004, 5, 1)
      "POL": new Date(2004, 5, 1)
      "SVK": new Date(2004, 5, 1)
      "SVN": new Date(2004, 5, 1)
      "CZE": new Date(2004, 5, 1)
      "HUN": new Date(2004, 5, 1)
      "CYP": new Date(2004, 5, 1)
      "BGR": new Date(2007, 1, 1)
      "ROU": new Date(2007, 1, 1)
      "HRV": new Date(2013, 7, 1)
    }

    now = new Date(2014, 1, 1)

    getColor = (state) ->
      if eu[state]? and eu[state] < now then "#ff5511" else "#ffffff"

    # areas --------------------------------------------------------------------
    $.getJSON "data/geo.json", (statesData) =>
      highlightStyle =
        fillColor:    "#000000"
        weight:       0
        opacity:      0
        fillOpacity:  0.5

      normalStyle = (feature) ->
        fillColor:    getColor(feature.properties.sov_a3)
        weight:       0
        opacity:      0
        fillOpacity:  0.2

      options =
        style: normalStyle
        onEachFeature:  (feature, layer) => layer.on(
          click:      (e) => @_map.fitBounds e.target.getBounds()
          mouseover:  (e) => e.target.setStyle highlightStyle
          mouseout:   (e) => boundaryLayer.resetStyle e.target
        )

      # data = topojson.feature statesData, statesData.objects.geo

      boundaryLayer = L.geoJson(statesData, options)
      boundaryLayer.addTo @_map

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
