window.HG ?= {}

class HG.AreasOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_map = null
    @_areaController = null

    # areaColorMapping
    # map: type -> color
    # -> in config

    @_visibleAreas = []

    defaultConfig =
      areaNormalColor: "#FCFCFC"
      areaHighlightColor: "#fff",
      labelVisibilityFactor: 5

    @_config = $.extend {}, defaultConfig, config

    # HACK !!! TODO: make nice
    @_normalStyle =
      fillColor:    @_config.areaNormalColor
      fillOpacity:  0.75
      lineColor:    "#BBBBBB"
      lineOpacity:  1
      weight:       1.8         # stroke width
      labelOpacity: 1
      color:        "#BBBBBB"   # lineColor
      opacity:      1           # lineOpacity


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
  _showAreaLayer: (area, isAnimated) ->

    # add area
    @_visibleAreas.push area

    area.myLeafletLayer = null

    options = @_normalStyle

    area.myLeafletLayer = L.multiPolygon area.getGeometry(), options

    area.myLeafletLayer.on "mouseover", @_onHover     # TODO: why does hover not work?
    area.myLeafletLayer.on "mouseout", @_onUnHover
    area.myLeafletLayer.on "click", @_onClick

    # area.onStyleChange @, @_onStyleChange

    area.myLeafletLayer.addTo @_map   # finally puts are on the map

    area.myLeafletLayer.hgArea = area

    # add label if given
    if area.getName()
      area.myLeafletLabel = new L.Label();
      area.myLeafletLabel.setContent area.getName()
      area.myLeafletLabel.setLatLng area.getLabelPos()

      area.myLeafletLabel.options.className = "invisible"   # makes label invisible onLoad

      @_map.showLabel area.myLeafletLabel

      # too lazy to change .getLabelDir(), so changed back to original version
      # ---- original version ----
      area.myLeafletLabel.options.offset = [
        -area.myLeafletLabel._container.offsetWidth/2,
        -area.myLeafletLabel._container.offsetHeight/2
      ]

      area.myLeafletLabel._updatePosition()

      # ---- new version ----
      # if area.getLabelDir() is "center"
      #   area.myLeafletLabel.options.offset = [
      #     -area.myLeafletLabel._container.offsetWidth/2,
      #     -area.myLeafletLabel._container.offsetHeight/2
      #   ]
      #   area.myLeafletLabel._updatePosition()
      # else if area.getLabelDir() is "right"
      #   area.myLeafletLabel.options.offset = [
      #     -area.myLeafletLabel._container.offsetWidth,
      #     -area.myLeafletLabel._container.offsetHeight
      #   ]
        # area.myLeafletLabel._updatePosition()

      area.myLeafletLabelIsVisible = false

      if @_isLabelVisible area          # makes label visible only after determined if actually active
        @_showAreaLabel area

  # ============================================================================
  _hideAreaLayer: (area, isAnimated) ->
    if area.myLeafletLayer?

      @_visibleAreas.splice(@_visibleAreas.indexOf(area), 1)

      area.myLeafletLayer.off "mouseover", @_onHover
      area.myLeafletLayer.off "mouseout", @_onUnHover
      area.myLeafletLayer.off "click", @_onClick

      # area.removeListener "onStyleChange", @

      @_hideAreaLabel area

      @_map.removeLayer area.myLeafletLabel if area.myLeafletLabel?
      @_map.removeLayer area.myLeafletLayer if area.myLeafletLayer?

  # ============================================================================
  _isLabelVisible: (area) ->
    bb = area.getBoundingBox()
    minPt = [bb[0], bb[1]]
    maxPt = [bb[2], bb[3]]

    min = @_map.project minPt
    max = @_map.project maxPt

    visible = no
    if area.getName()?
      width = area.getName().length * @_config.labelVisibilityFactor  # MAGIC number!
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
    @_animate event.target, {"fill": "#{@_config.areaNormalColor}"}, 150
    # @_animate event.target, {"fill": "#{event.target.hgArea.getNormalStyle().fillColor}"}, 150

  # ============================================================================
  _onClick: (event) =>
    @_map.fitBounds event.target.getBounds()

  # ============================================================================
  _onZoomEnd: (event) =>
    for area in @_visibleAreas
      shouldBeVisible = @_isLabelVisible area

      if shouldBeVisible and not area.myLeafletLabelIsVisible
        @_showAreaLabel area
      else if not shouldBeVisible and area.myLeafletLabelIsVisible
        @_hideAreaLabel area

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

