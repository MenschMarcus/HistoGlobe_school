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
    # 2 arrays of 6 arrays (one for each label priority, 0 is empty and is ignored, so that prio value matched array index)
    # one for all visible, one for all invisible labels
    @_visibleLabels   = []
    @_invisibleLabels = []
    i = 0
    while i <= NUM_LABEL_PRIOS
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

    @_zoomLevel = @_map.getZoom()

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

      @_map.on "zoomend", @_updateLabels

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
      label.myLeafletLabel.options.className = "invisible"   # makes label invisible onLoad

      # add label to map
      @_map.showLabel label.myLeafletLabel

      # put in center of label
      label.myLeafletLabel.options.offset = [
        -label.myLeafletLabel._container.offsetWidth/2,
        -label.myLeafletLabel._container.offsetHeight/2
      ]
      label.myLeafletLabel._updatePosition()

      @_updateLabelStyle label

      # show if visible label
      @_checkLabelOnAdd label

  # ============================================================================
  _removeLabel: (label) ->
    if label.myLeafletLabel?
      # remove double-link: leaflet label from HG label and HG label from leaflet label
      @_map.removeLayer label.myLeafletLabel
      label.myLeafletLabel = null

      # remove from visible or invisible list
      @_removeLabelFromList @_visibleLabels, label
      @_removeLabelFromList @_invisibleLabels, label

      @_checkLabelOnRemove


  # ============================================================================
  _checkLabelOnAdd: (labelA) ->

    # idea: check for each label with higher priority if it collides
    # -> if so: hide
    i = labelA.getPriority()+1
    while i <= NUM_LABEL_PRIOS
      for labelB in @_visibleLabels[i]
        if @_labelsCollide labelA, labelB
          # console.log "hide", labelA.getName()
          @_hideLabel labelA
          return
      ++i

    # -> if it does not collide: show
    # console.log "show", labelA.getName()
    @_showLabel labelA

    # and hide all labels with lower priority that collide
    i = labelA.getPriority()
    while i > 0
      # create list of labels that should be hidden to not remove elements from a list currently iterated through
      labelsToBeHidden = []
      for labelB in @_visibleLabels[i]
        if labelB? # why is this test necessary -> seems to be unreasonable
          if @_labelsCollide labelA, labelB
            labelsToBeHidden.push labelB
      # finally hide labels
      for label in labelsToBeHidden
        if not @_areEqual labelA.getName(), labelB.getName()
          # console.log "label", labelA.getName(), "hides label", labelB.getName()
          @_hideLabel label
      --i

  # ============================================================================
  _checkLabelOnRemove: (labelA) ->

    # check for all labels with lower priority if they have now space to be shown
    i = labelA.getPriority()
    while i > 0
      # create list of labels that should be shown to not add elements to a list currently iterated through
      labelsToBeShown = []
      for labelB in @_visibleLabels[i]
        if @_labelsCollide labelA, labelB
          labelsToBeShown.push labelB
      # finally show labels if they do not collide themselves
      for label in labelsToBeShown
        if not @_areEqual labelA.getName(), labelB.getName()
          @_showLabel label   # caution! this could be a problem, because if more than one label is shown, they might actually collide
      --i

  # ============================================================================
  _updateLabels: (event) =>
    # check if zoomed in or out
    zoomedIn = yes
    if @_zoomLevel > @_map.getZoom()
      zoomedIn = no
    # update zoom level
    @_zoomLevel = @_map.getZoom()

    if zoomedIn
      # check if any hidden labels have space to be shown now
      i = NUM_LABEL_PRIOS
      while i > 0
        for label in @_invisibleLabels[i]
          @_checkLabelOnAdd label if label?
        --i

    else # zoomed out
      # for each label check upwards if it collides
      # HORRIBLE ALGORITHM with high complexity O(n^2) ???
      i = NUM_LABEL_PRIOS
      while i > 0
        for labelA in @_visibleLabels[i]
          if labelA?
            j = labelA.getPriority()
            while j <= NUM_LABEL_PRIOS
              labelsToBeHidden = []
              for labelB in @_visibleLabels[j]
                if labelB?
                  if @_labelsCollide labelA, labelB
                    labelsToBeHidden.push labelB
              for label in labelsToBeHidden
                @_hideLabel labelB
              ++j
        --i

  # ============================================================================
  _labelsCollide: (labelA, labelB) ->
    # get center, width and height for both labels
    posA = @_map.project labelA.getPosition()
    widthA = labelA.myLeafletLabel._container.clientWidth * @_labelCollisionFactor labelA.getPriority()
    heightA = labelA.myLeafletLabel._container.clientHeight * @_labelCollisionFactor labelA.getPriority()
    posB = @_map.project labelB.getPosition()
    widthB = labelB.myLeafletLabel._container.clientWidth * @_labelCollisionFactor labelB.getPriority()
    heightB = labelB.myLeafletLabel._container.clientHeight * @_labelCollisionFactor labelB.getPriority()

    # On each axis, check to see if the centers of the boxes are close enough that they'll intersect.
    # If they intersect on both axes, then the boxes intersect. If they don't, then they don't.
    return  (Math.abs(posA.x - posB.x) * 2 < (widthA + widthB)) and
            (Math.abs(posA.y - posB.y) * 2 < (heightA + heightB))

  # ============================================================================
  _labelCollisionFactor: (prio) ->
    # idea: the lower the priority, the "larger" the label box, the earlier it gets hidden
    @_config.labelVisibilityFactor * (1 + 1/prio)


  # ============================================================================
  _showLabel: (label) =>
    label.myLeafletLabelIsVisible = true
    $(label.myLeafletLabel._container).removeClass("invisible")

    # add to visible label list
    @_visibleLabels[label.getPriority()].push label

    # remove from invisible label list (if it exists)
    @_removeLabelFromList @_invisibleLabels, label

  # ============================================================================
  _hideLabel: (label) =>
    label.myLeafletLabelIsVisible = false
    $(label.myLeafletLabel._container).addClass("invisible")

    # add to invisible label list
    @_invisibleLabels[label.getPriority()].push label

    # remove from visible label list (if it exists)
    @_removeLabelFromList @_visibleLabels, label

  # ============================================================================
  _removeLabelFromList: (array, label) =>
    posInArray = array[label.getPriority()].indexOf(label)
    if posInArray >= 0
      array[label.getPriority()].splice(posInArray, 1)


  # ============================================================================
  _updateLabelStyle: (label) ->
    style = label.getStyle()
    if label.myLeafletLabel?
      label.myLeafletLabel._container.style.color = style.labelColor
      label.myLeafletLabel.setOpacity style.labelOpacity

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


  # ============================================================================
  _areEqual: (str1, str2) ->
    (str1?="").localeCompare(str2) is 0

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

