window.HG ?= {}

class HG.AreasOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_map = null
    @_areaController = null

    @_visibleAreas = []

    defaultConfig =
      areaHighlightColor: "#fff"

    @_config = $.extend {}, defaultConfig, config


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
    options.color = area.getNormalStyle().lineColor
    options.opacity = 0       # bugfix: makes border invisible onLoad
    # options.clickable = false
    # options.pointerEvents = "none"

    area.myLeafletLayer = L.multiPolygon(area.getData(), options)

    area.myLeafletLayer.on "mouseover", @_onHover
    area.myLeafletLayer.on "mouseout", @_onUnHover
    area.myLeafletLayer.on "click", @_onClick

    area.onStyleChange @, @_onStyleChange
    console.log "NOW HERE!"

    # area.myLeafletLayer.addTo @_map
    area.myLeafletLayer.bindLabel(area.getLabel()).addTo @_map

    area.myLeafletLayer.hgArea = area

    # add label
    area.myLeafletLabel = new L.Label();
    area.myLeafletLabel.setContent area.getLabel()
    area.myLeafletLabel.setLatLng area.getLabelLatLng()
    area.myLeafletLabel.options.className = "invisible"   # bugfix: makes label invisible onLoad

    @_map.showLabel area.myLeafletLabel

    if area.getLabelDir() is "center"
      area.myLeafletLabel.options.offset = [
        -area.myLeafletLabel._container.offsetWidth/2,
        -area.myLeafletLabel._container.offsetHeight/2
      ]
      area.myLeafletLabel._updatePosition()
    else if area.getLabelDir() is "right"
      area.myLeafletLabel.options.offset = [
        -area.myLeafletLabel._container.offsetWidth,
        -area.myLeafletLabel._container.offsetHeight
      ]
      area.myLeafletLabel._updatePosition()

    area.myLeafletLabelIsVisible = false
    # if @_isLabelVisible area
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

      @_map.removeLayer area.myLeafletLabel if area.myLeafletLabel?
      @_map.removeLayer area.myLeafletLayer if area.myLeafletLayer?

  # ============================================================================
  _isLabelVisible: (area) ->
    max = @_map.project area._maxLatLng
    min = @_map.project area._minLatLng

    visible = false
    if area.getLabel()?
      width = area.getLabel().length * 5

      visible = (max.x - min.x) > width or @_map.getZoom() is @_map.getMaxZoom()

  # ============================================================================
  _showAreaLabel: (area) =>
    area.myLeafletLabelIsVisible = true
    $(area.myLeafletLabel._container).removeClass("invisible")


  # ============================================================================
  _hideAreaLabel: (area) =>
    area.myLeafletLabelIsVisible = false
    $(area.myLeafletLabel._container).addClass("invisible")


  # ============================================================================
  _onStyleChange: (area) =>
    console.log "HERE NOW!"
    if area.myLeafletLayer?
      @_animate area.myLeafletLayer,
        "fill":           area.getNormalStyle().fillColor
        "fill-opacity":   area.getNormalStyle().fillOpacity
        "stroke":         area.getNormalStyle().lineColor
        "stroke-opacity": area.getNormalStyle().lineOpacity
        "stroke-width":   area.getNormalStyle().lineWidth
      , 200
    if area.myLeafletLabel?
      area.myLeafletLabel._container.style.opacity = area.getNormalStyle().labelOpacity


  # ============================================================================
  _animate: (area, attributes, durartion) ->
    if area._layers?
      for id, path of area._layers
        d3.select(path._path).transition().duration(durartion).attr(attributes)
    else if area._path?
      d3.select(area._path).transition().duration(durartion).attr(attributes)

  # ============================================================================
  _onHover: (event) =>
    @_animate event.target, {"fill": "#{@_config.areaHighlightColor}"}, 150

  # ============================================================================
  _onUnHover: (event) =>
    @_animate event.target, {"fill": "#{event.target.hgArea.getNormalStyle().fillColor}"}, 150

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

