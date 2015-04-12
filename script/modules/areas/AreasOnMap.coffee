window.HG ?= {}

class HG.AreasOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  NUM_LABEL_PRIOS = 5

  # ============================================================================
  constructor: (config) ->
    @_map             = null
    @_areaController  = null

    # label handling
    # 2 arrays of 5 arrays (one for each label priority)
    # one for all visible, one for all invisible labels
    @_visibleLabels   = []
    @_invisibleLabels = []
    i = 0
    while i < NUM_LABEL_PRIOS
      @_visibleLabels.push []
      @_invisibleLabels.push []
      ++i

    defaultConfig =
      labelVisibilityFactor: 5

    @_config = $.extend {}, defaultConfig, config


  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.areasOnMap = @

    @_aniTime = hgInstance._config.areaAniTime
    @_map = hgInstance.map._map
    @_areaController = hgInstance.areaController

    # event handling
    if @_areaController

      # change of areas
      @_areaController.onAddArea @, (area) =>
        @_addArea area
        @_showArea area, 0

      @_areaController.onRemoveArea @, (area) =>
        @_hideArea area, 0

      @_areaController.onFadeInArea @, (area, isHighlight) =>
        @_addArea area
        @_showArea area, @_aniTime, isHighlight

      @_areaController.onFadeOutArea @, (area) =>
        @_hideArea area, @_aniTime

      @_areaController.onUpdateAreaStyle @, (area) =>
        @_updateAreaStyle area

      # change of labels
      @_areaController.onAddLabel @, (label) =>
        @_addLabel label

      @_areaController.onRemoveLabel @, (label) =>
        @_removeLabel label

      @_areaController.onUpdateLabelStyle @, (label) =>
        @_updateLabelStyle label

      @_map.on "zoomend", @_onZoomEnd

    else
      console.error "Unable to show areas on Map: AreaController module not detected in HistoGlobe instance!"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  # physically adds area to the map, but makes it invisible
  _addArea: (area) ->
    if not area.myLeafletLayer?

      # take style of country but make it invisible
      options = @_translateAreaStyle area.getStyle()
      options.fillOpacity = 0
      options.lineOpacity = 0

      # create layer with loaded geometry and style
      area.myLeafletLayer = L.multiPolygon area.getGeometry(), options

      # hack: disable interaction with countries
      # area.myLeafletLayer.on "mouseover", @_onHover     # TODO: why does hover not work?
      # area.myLeafletLayer.on "mouseout", @_onUnHover
      # area.myLeafletLayer.on "click", @_onClick

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

  # ============================================================================
  # slowly fades in area and allows interaction with it
  _showArea: (area, aniTime, isHighlight) ->
    if area.myLeafletLayer?
      if not isHighlight
        @_animate area.myLeafletLayer,
          # TODO: does that work better? translating the whole style 5 times for each item separately seems not intuitive...
          "fill-opacity":   area.getStyle().areaOpacity
          "stroke-opacity": area.getStyle().borderOpacity
        , aniTime
      else
        @_animate area.myLeafletLayer,
          # TODO: does that work better? translating the whole style 5 times for each item separately seems not intuitive...
          "fill":           "#ff0000"
          "fill-opacity":   1.0
        , aniTime


  # ============================================================================
  _hideArea: (area, aniTime) ->
    if area.myLeafletLayer?
      @_animate area.myLeafletLayer,
        # TODO: does that work better? translating the whole style 5 times for each item separately seems not intuitive...
        "fill-opacity":   0
        "stroke-opacity": 0
      , aniTime, () =>
        @_removeArea area

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
    if not label.myLeafletLabel?
      # create invisible label with name and position
      label.myLeafletLabel = new L.Label()
      label.myLeafletLabel.setContent @_addLinebreaks label.getName()
      label.myLeafletLabel.setLatLng label.getPosition()

      # add label to map
      @_map.showLabel label.myLeafletLabel

      # put in center of label
      label.myLeafletLabel.options.offset = [
        -label.myLeafletLabel._container.offsetWidth/2,
        -label.myLeafletLabel._container.offsetHeight/2
      ]
      label.myLeafletLabel._updatePosition()

      # show if visible label
      # if @_isLabelVisible label
      # @_updateLabelStyle label
      # $(area.myLeafletLabel._container).removeClass("invisible")
      # label.setActive()
      # update list of visible labels
      # @_visibleLabels.push label

  # ============================================================================
  _removeLabel: (label) ->
    if label.myLeafletLabel?
      # $(label.myLeafletLabel._container).addClass("invisible")
      label.myLeafletLabel.setOpacity(0)
      label.setInactive()

      # remove double-link: leaflet label from HG label and HG label from leaflet label
      @_map.removeLayer label.myLeafletLabel
      label.myLeafletLabel = null

      # update list of visible areas
      @_visibleLabels.splice(@_visibleLabels.indexOf(label), 1)


  # ============================================================================
  _showLabel: (label) =>
    label.myLeafletLabelIsVisible = true
    $(label.myLeafletLabel._container).removeClass("invisible")

  # ============================================================================
  _hideLabel: (label) =>
    label.myLeafletLabelIsVisible = false
    $(label.myLeafletLabel._container).addClass("invisible")

  # ============================================================================
  _updateLabelStyle: (label) ->
    style = label.getStyle()
    if label.myLeafletLabel?
      label.myLeafletLabel._container.style.color = style.labelColor
      label.myLeafletLabel.setOpacity style.labelOpacity

  # ============================================================================
  _isLabelVisible: (label) ->
    # get bounding box of largest polygon of corresponding area
    bb = label.getBoundingBox()
    minPt = [bb[0], bb[1]]
    maxPt = [bb[2], bb[3]]

    # geo coordinates -> 2D map coordinates
    min = @_map.project minPt
    max = @_map.project maxPt

    width = label.getName().length * @_config.labelVisibilityFactor  # MAGIC number!
    visible = no

    # magic line of code ?!?
    visible = (max.x - min.x) > width or @_map.getZoom() is @_map.getMaxZoom()

  # ============================================================================
  _animate: (area, attributes, durartion, finishFunction) ->
    if area._layers?
      for id, path of area._layers
        d3.select(path._path).transition().duration(durartion).attr(attributes).each("end", finishFunction)
    else if area._path?
      d3.select(area._path).transition().duration(durartion).attr(attributes).each("end", finishFunction)

  # ============================================================================
  _onHover: (event) =>
    return
    # @_animate event.target, {"fill": "#{event.target.hgArea.getHighlightStyle().areaColor}"}, 150
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
    for label in @_visibleLabels
      # shouldBeVisible = @_isLabelVisible label
      shouldBeVisible = yes

      if shouldBeVisible and not label.isActive()
        @_addLabel label
      else if not shouldBeVisible and label.isActive()
        @_removeLabel label

  # ============================================================================
  _addLinebreaks : (name) =>
    # 1st approach: break at all whitespaces and dashed lines
    name = name.replace /\s/gi, '<br\>'
    name = name.replace /\-/gi, '-<br\>'

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

