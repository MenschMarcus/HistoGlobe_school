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
    @_mapParent.style.zIndex = "#{HG.Display.Z_INDEX}"

    @_container.appendChild @_mapParent

    options =
      maxZoom:      6
      minZoom:      1
      zoomControl:  false
      # maxBounds:    [[-180,-90], [180, 90]]

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

    @_markerGroup = new L.MarkerClusterGroup(
      {
        showCoverageOnHover: false,
        maxClusterRadius: 5
      })

    @_hiventController.onHiventsChanged (handles) =>
      marker = new HG.HiventMarker2D handle, this, @_map, @_markerGroup for handle in handles

    @_map.on "click", HG.HiventHandle.DEACTIVATE_ALL_HIVENTS
    @_map.addLayer @_markerGroup

  # ============================================================================
  _animate: (area, attributes, durartion) ->
    if area._layers?
      for id, path of area._layers
        d3.select(path._path).transition().duration(durartion).attr(attributes)
    else if area._path?
      d3.select(area._path).transition().duration(durartion).attr(attributes)

  # ============================================================================
  _initAreas: ->
    @_areaController.onShowArea @, (area) =>
      @_showAreaLayer area

    @_areaController.onHideArea @, (area) =>
      @_hideAreaLayer area

  # ============================================================================
  _onWindowResize: (event) =>
    @_mapParent.style.width = $(@_container.parentNode).width() + "px"
    @_mapParent.style.height = $(@_container.parentNode).height() + "px"

  # ============================================================================
  _showAreaLayer: (area) ->

    # add area
    area.leafletLayer = null

    options = area.getNormalStyle()

    area.leafletLayer = L.multiPolygon(area.getData(), options)

    area.leafletLayer.on "mouseover", @_onHover
    area.leafletLayer.on "mouseout", @_onUnHover
    area.leafletLayer.on "click", @_onClick

    area.onStyleChange @, @_onStyleChange

    area.leafletLayer.addTo @_map

    # add label
    area.label = new L.Label();
    area.label.setContent area.getLabel()
    area.label.setLatLng area.getLabelLatLng()

    @_map.showLabel area.label

    area.label.options.offset = [
      -area.label._container.offsetWidth/2,
      -area.label._container.offsetHeight/2
    ]

    area.label._updatePosition()


  # ============================================================================
  _onHover: (event) =>
    @_animate event.target, {"fill-opacity": 0.6}, 150

  # ============================================================================
  _onUnHover: (event) =>
    @_animate event.target, {"fill-opacity": 0.4}, 150

  # ============================================================================
  _onClick: (event) =>
    @_map.fitBounds event.target.getBounds()

  # ============================================================================
  _onStyleChange: (area) =>
    if area.leafletLayer?
      @_animate area.leafletLayer, {"fill": area.getNormalStyle().fillColor}, 350

  # ============================================================================
  _hideAreaLayer: (area) ->
    if area.leafletLayer?

      area.leafletLayer.off "mouseover", @_onHover
      area.leafletLayer.off "mouseout", @_onUnHover
      area.leafletLayer.off "click", @_onClick

      area.removeListener "onStyleChange", @

      @_map.removeLayer area.leafletLayer
      @_map.removeLayer area.label
