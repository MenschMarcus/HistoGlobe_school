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
    @_mapParent.style.width = @_container.offsetWidth + "px"
    @_mapParent.style.height = @_container.offsetHeight + "px"
    @_mapParent.style.zIndex = "#{HG.Display.Z_INDEX}"

    @_container.appendChild @_mapParent

    options =
      maxZoom:      6
      minZoom:      1
      zoomControl:  false
      #maxBounds:    [[-180,-90], [180, 90]]

    @_map = L.map @_mapParent, options
    @_map.setView [51.505, 10.09], 4
    @_map.attributionControl.setPrefix ''

    L.tileLayer('data/tiles/{z}/{x}/{y}.png').addTo @_map

    @_isRunning = true

  # ============================================================================
  _initEventHandling: ->
    window.addEventListener 'resize', @_onWindowResize, false
    @_map.on "zoomend", @_onZoomEnd

  # ============================================================================
  _initHivents: ->

    @_markerGroup = new L.MarkerClusterGroup(
      {
        showCoverageOnHover: false,
        maxClusterRadius: 20
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

    @_visibleAreas = []

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
    @_visibleAreas.push area

    area.myLeafletLayer = null

    options = area.getNormalStyle()

    area.myLeafletLayer = L.multiPolygon(area.getData(), options)

    area.myLeafletLayer.on "mouseover", @_onHover
    area.myLeafletLayer.on "mouseout", @_onUnHover
    area.myLeafletLayer.on "click", @_onClick

    area.onStyleChange @, @_onStyleChange

    area.myLeafletLayer.addTo @_map

    # add label
    area.myLeafletLabel = new L.Label();
    area.myLeafletLabel.setContent area.getLabel()
    area.myLeafletLabel.setLatLng area.getLabelLatLng()
    @_map.showLabel area.myLeafletLabel
    area.myLeafletLabel.options.offset = [
      -area.myLeafletLabel._container.offsetWidth/2,
      -area.myLeafletLabel._container.offsetHeight/2
    ]

    area.myLeafletLabel._updatePosition()
    area.myLeafletLabelIsVisible = false

    if @_isLabelVisible area
      @_showLabel area


  # ============================================================================
  _hideAreaLayer: (area) ->
    if area.myLeafletLayer?

      @_visibleAreas.splice(@_visibleAreas.indexOf(area), 1)

      area.myLeafletLayer.off "mouseover", @_onHover
      area.myLeafletLayer.off "mouseout", @_onUnHover
      area.myLeafletLayer.off "click", @_onClick

      area.removeListener "onStyleChange", @

      @_hideLabel area

      @_map.removeLayer area.myLeafletLabel
      @_map.removeLayer area.myLeafletLayer


  # ============================================================================
  _isLabelVisible: (area) ->
    max = @_map.project area._maxLatLng
    min = @_map.project area._minLatLng

    width = area.getLabel().length * 1.5

    visible = (max.x - min.x) > width * 0.75 or @_map.getZoom() is @_map.getMaxZoom()

  # ============================================================================
  _showLabel: (area) =>
    area.myLeafletLabelIsVisible = true
    $(area.myLeafletLabel._container).addClass("visible")


  # ============================================================================
  _hideLabel: (area) =>
    area.myLeafletLabelIsVisible = false
    $(area.myLeafletLabel._container).removeClass("visible")

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
  _onZoomEnd: (event) =>
    for area in @_visibleAreas
      shoulBeVisible = @_isLabelVisible area

      if shoulBeVisible and not area.myLeafletLabelIsVisible
        @_showLabel area
      else if not shoulBeVisible and area.myLeafletLabelIsVisible
        @_hideLabel area


  # ============================================================================
  _onStyleChange: (area) =>
    if area.myLeafletLayer?
      @_animate area.myLeafletLayer, {"fill": area.getNormalStyle().fillColor}, 350
