window.HG ?= {}

class HG.AreasOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    @_map = null
    @_areaController = null

    @_visibleAreas = []


  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areasOnMap = @

    @_map = hgInstance.map._map
    @_areaController = hgInstance.areaController

    if @_areaController
      @_areaController.onShowArea @, (area) =>
        @_showAreaLayer area

      @_areaController.onHideArea @, (area) =>
        @_hideAreaLayer area

      @_map.on "zoomend", @_onZoomEnd
    else
      console.error "Unable to show areas on Map: AreaController module not detected in HistoGlobe instance!"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _showAreaLayer: (area) ->

    # add area
    @_visibleAreas.push area

    area.myLeafletLayer = null

    options = area.getNormalStyle()

    area.myLeafletLayer = L.multiPolygon(area.getData(), options)

    # area.myLeafletLayer.on "mouseover", @_onHover
    # area.myLeafletLayer.on "mouseout", @_onUnHover
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
      @_showAreaLabel area

  # ============================================================================
  _hideAreaLayer: (area) ->
    if area.myLeafletLayer?

      @_visibleAreas.splice(@_visibleAreas.indexOf(area), 1)

      area.myLeafletLayer.off "mouseover", @_onHover
      area.myLeafletLayer.off "mouseout", @_onUnHover
      area.myLeafletLayer.off "click", @_onClick

      area.removeListener "onStyleChange", @

      @_hideAreaLabel area

      @_map.removeLayer area.myLeafletLabel
      @_map.removeLayer area.myLeafletLayer

  # ============================================================================
  _isLabelVisible: (area) ->
    max = @_map.project area._maxLatLng
    min = @_map.project area._minLatLng

    width = area.getLabel().length * 10

    visible = (max.x - min.x) > width or @_map.getZoom() is @_map.getMaxZoom()


  # ============================================================================
  _showAreaLabel: (area) =>
    area.myLeafletLabelIsVisible = true
    $(area.myLeafletLabel._container).addClass("visible")


  # ============================================================================
  _hideAreaLabel: (area) =>
    area.myLeafletLabelIsVisible = false
    $(area.myLeafletLabel._container).removeClass("visible")


  # ============================================================================
  _onStyleChange: (area) =>
    if area.myLeafletLayer?
      @_animate area.myLeafletLayer,
        "fill":           area.getNormalStyle().fillColor
        "fill-opacity":   area.getNormalStyle().fillOpacity
        "stroke":         area.getNormalStyle().lineColor
        "stroke-opacity": area.getNormalStyle().lineOpacity
        "stroke-width":   area.getNormalStyle().lineWidth
      , 200



  # ============================================================================
  _animate: (area, attributes, durartion) ->
    if area._layers?
      for id, path of area._layers
        d3.select(path._path).transition().duration(durartion).attr(attributes)
    else if area._path?
      d3.select(area._path).transition().duration(durartion).attr(attributes)

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
        @_showAreaLabel area
      else if not shoulBeVisible and area.myLeafletLabelIsVisible
        @_hideAreaLabel area
  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

