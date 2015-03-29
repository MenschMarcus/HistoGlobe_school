window.HG ?= {}

class HG.AreasOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_map             = null
    @_areaController  = null
    @_visibleAreas    = []

    defaultConfig =
      labelVisibilityFactor: 5

    @_config = $.extend {}, defaultConfig, config


  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areasOnMap = @

    @_map = hgInstance.map._map
    @_areaController = hgInstance.areaController

    # event handling
    if @_areaController

      # change of areas
      @_areaController.onAddArea @, (area) =>
        @_addArea area
        @_showArea area

      @_areaController.onRemoveArea @, (area) =>
        @_hideArea area
        @_removeArea area

      @_areaController.onFadeInArea @, (area) =>
        @_addArea area
        @_fadeInArea area

      @_areaController.onFadeOutArea @, (area) =>
        @_fadeOutArea area
        @_removeArea area

      @_areaController.onUpdateAreaStyle @, (area) =>
        @_updateAreaStyle area

      # change of labels
      @_areaController.onAddLabel @, (label) =>
        @_addLabel label
        @_showLabel label

      @_areaController.onRemoveLabel @, (label) =>
        @_hideLabel label
        @_removeLabel label

      @_areaController.onMoveLabel @, (label) =>
        @_moveLabel label

      @_areaController.onUpdateLabelStyle @, (label) =>
        @_updateLabelStyle label


      # change of style

      @_map.on "zoomend", @_onZoomEnd
    else
      console.error "Unable to show areas on Map: AreaController module not detected in HistoGlobe instance!"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  # physically adds area to the map, but makes it invisible
  _addArea: (area) ->

    # take style of country but make it invisible
    options = @_translateStyle area.getStyle()
    options.fillOpacity = 0
    options.lineOpacity = 0

    # create layer with loaded geometry and style
    area.myLeafletLayer = L.multiPolygon area.getGeometry(), options

    # enable event handling on the area
    area.myLeafletLayer.on "mouseover", @_onHover
    area.myLeafletLayer.on "mouseout", @_onUnHover
    area.myLeafletLayer.on "click", @_onClick

    # update list of visible areas
    @_visibleAreas.push area

    # create double-link: leaflet layer knows HG area and HG area knows leaflet layer
    area.myLeafletLayer.hgArea = area
    area.myLeafletLayer.addTo @_map


  # ============================================================================
  # physically removes area from the map
  _removeArea: (area) ->
    if area.myLeafletLayer?

      # disable event handling on the area
      area.myLeafletLayer.off "click", @_onClick
      area.myLeafletLayer.off "mouseover", @_onHover
      area.myLeafletLayer.off "mouseout", @_onUnHover

      # remove double-link: leaflet layer from area and area from leaflet layer
      @_map.removeLayer area.myLeafletLayer if area.myLeafletLayer?
      area.myLeafletLayer = null

      # update list of visible areas
      @_visibleAreas.splice(@_visibleAreas.indexOf(area), 1)


  # ============================================================================
  # makes area abruptly visible and allows interaction with it
  _showArea: (area) ->
    if area.myLeafletLayer?
      area.myLeafletLayer.options.fillOpacity = area.getStyle().areaOpacity
      area.myLeafletLayer.options.lineOpacity = area.getStyle().borderOpacity
      @_visibleAreas.push area

  # ============================================================================
  # makes area abruptly invisible and allows interaction with it
  _hideArea: (area) ->
    if area.myLeafletLayer?
      area.myLeafletLayer.options.fillOpacity = 0
      area.myLeafletLayer.options.lineOpacity = 0

  # ============================================================================
  # slowly fades in area and allows interaction with it
  _fadeInArea: (area) ->
    if area.myLeafletLayer?
      @_animate area.myLeafletLayer,
        # TODO: does that work better? translating the whole style 5 times for each item separately seems not intuitive...
        "fill-opacity":   area.getStyle().areaOpacity
        "stroke-opacity": area.getStyle().borderOpacity
      , 200   # TODO: get from config

  # ============================================================================
  _fadeOutArea: (area) ->
    if area.myLeafletLayer?
      @_animate area.myLeafletLayer,
        # TODO: does that work better? translating the whole style 5 times for each item separately seems not intuitive...
        "fill-opacity":   0
        "stroke-opacity": 0
      , 200   # TODO: get from config

  # ============================================================================
  _updateAreaStyle: (area) ->
    if area.myLeafletLayer?
      @_animate area.myLeafletLayer,
        # TODO: does that work better? translating the whole style 5 times for each item separately seems not intuitive...
        "fill":           area.getStyle().areaColor
        "fill-opacity":   area.getStyle().areaOpacity
        "stroke":         area.getStyle().borderColor
        "stroke-opacity": area.getStyle().borderOpacity
        "stroke-width":   area.getStyle().borderWidth
      , 200   # TODO: get from config


  # ============================================================================
  _addLabel: (label) ->
    # create label with name and position
    label.myLeafletLabel = new L.Label()
    label.myLeafletLabel.setContent @_addLinebreaks label.getName()
    label.myLeafletLabel.setLatLng label.getLabelPos()

    # needed ?!?
    label.myLeafletLabel.options.offset = [
      -label.myLeafletLabel._container.offsetWidth/2,
      -label.myLeafletLabel._container.offsetHeight/2
    ]

    # add label to map, but invisible
    @_hideLabel label
    @_map.showLabel label.myLeafletLabel

    # check if label is visible
    if @_isLabelVisible label
      @_showLabel label

  # ============================================================================
  _removeLabel: (label) ->
    if label.myLeafletLabel?

      # remove double-link: leaflet label from HG label and HG label from leaflet label
      @_map.removeLayer label.myLeafletLabel
      label.myLeafletLabel = null

  # ============================================================================
  _showLabel: (label) ->
    @_updateLabelStyle label
    # $(area.myLeafletLabel._container).removeClass("invisible")
    label.setVisible()

  # ============================================================================
  _hideLabel: (label) ->
    label.myLeafletLabel.setOpacity(0)
    # $(label.myLeafletLabel._container).addClass("invisible")
    label.setInvisible()

  # ============================================================================
  _moveLabel: (label) ->
    # TODO: animated move?
    label.myLeafletLabel.setLatLng label.getLabelPos()

  # ============================================================================
  _updateLabelStyle: (label) ->
    style = label.getStyle()
    if label.myLeafletLabel?
      label.myLeafletLabel._container.style.color = style.labelColor
      label.myLeafletLabel.setOpacity style.labelOpacity


  # ============================================================================
  # ============================================================================
  # ============================================================================
  # ============================================================================



  # ============================================================================
  _isLabelVisible: (label) ->
    bb = label.getBoundingBox()
    minPt = [bb[0], bb[1]]
    maxPt = [bb[2], bb[3]]

    min = @_map.project minPt
    max = @_map.project maxPt

    width = label.getName().length * @_config.labelVisibilityFactor  # MAGIC number!
    visible = no
    visible = (max.x - min.x) > width or @_map.getZoom() is @_map.getMaxZoom()

  # ============================================================================
  _animate: (area, attributes, durartion) ->
    if area._layers?
      for id, path of area._layers
        d3.select(path._path).transition().duration(durartion).attr(attributes)
    else if area._path?
      d3.select(area._path).transition().duration(durartion).attr(attributes)

  # ============================================================================
  _onHover: (event) =>
    @_animate event.target, {"fill": "#{event.target.hgArea.getHighlightStyle().areaColor}"}, 150
    # TODO: for countries with white labels, hovering means the country name is not readable
    # -> how to get the label of the current layer I am hovering? How to change its color?

  # ============================================================================
  _onUnHover: (event) =>
    @_animate event.target, {"fill": "#{event.target.hgArea.getStyle().areaColor}"}, 150

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

  # ============================================================================
  _addLinebreaks : (name) =>
    # 1st approach: break at all whitespaces
    name = name.replace /\s/gi, '<br\>'

    # # find all whitespaces in the name
    # len = name.length
    # regEx = /\s/gi  # finds all whitespaces (\s) globally (g) and case-insensitive (i)
    # posWhite = []
    # while result = regEx.exec name
    #   posWhite.push result.index
    # for posW in posWhite

    name

  # ============================================================================
  # user centered styling (area, border, name) -> leaflet styling options

  _translateAreaStyle: (userStyle) ->
    options =
      fillColor:    userStyle.areaColor
      fillOpacity:  userStyle.areaOpacity
      lineColor:    userStyle.borderColor
      lineOpacity:  userStyle.borderOpacity
      weight:       userStyle.borderWidth
      # backup styling for whatsoever weird browser that can only handle them
      color:        userStyle.borderColor
      opacity:      userStyle.borderOpacity

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

