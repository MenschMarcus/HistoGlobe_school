window.HG ?= {}

class HG.Display2D extends HG.Display

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, hiventController, areaController) ->
    @_container = container
    @_hiventController = hiventController
    @_areaController = areaController
    @_initMembers()
    @_initCanvas()
    @_initEventHandling()
    @_initHivents()
    @_initAreas()

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

  # ============================================================================
  addAreaLayer: (areaLayer) ->

    leafletLayer = null

    options =
      style: areaLayer.getNormalStyle()
      onEachFeature:  (feature, layer) =>

        layer.on(
          click: (e) =>
            @_map.fitBounds e.target.getBounds()
            # if e.target._layers?
            #   for id, path of e.target._layers
            #     console.log path._path.className = "huhu"
            # else
            #   console.log e.target._path

          mouseover:  (e) => e.target.setStyle areaLayer.getHighlightStyle()
          mouseout:   (e) => leafletLayer.resetStyle e.target
        )

    areaLayer.onStyleChanged (layer) =>
      leafletLayer.setStyle areaLayer.getNormalStyle()

    leafletLayer = L.geoJson(areaLayer.getData(), options)
    leafletLayer.addTo @_map

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

    @_isRunning = true

  # ============================================================================
  _initEventHandling: ->
    window.addEventListener 'resize', @_onWindowResize, false

  # ============================================================================
  _initHivents: ->
    @_hiventController.onHiventsChanged (handles) =>
      marker = new HG.HiventMarker2D handle, this, @_map for handle in handles

    @_map.on "click", HG.deactivateAllHivents

  # ============================================================================
  _initAreas: ->
    @_areaController.onAreaChanged (area) =>
      @addAreaLayer area

  # ============================================================================
  _onWindowResize: (event) =>
    @_mapParent.style.width = $(@_container.parentNode).width() + "px"
    @_mapParent.style.height = $(@_container.parentNode).height() + "px"
