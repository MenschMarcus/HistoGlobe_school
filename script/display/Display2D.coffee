window.HG ?= {}

class HG.Display2D extends HG.Display

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container) ->

    HG.Display.call @, container

    # @_labelController = labelController
    @_initMembers()
    @_initCanvas()
    @_initEventHandling()
    # @_initLabels()

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
  setCenter: (longLat) ->
    @_map.panTo [longLat.y, longLat.x]

  # ============================================================================
  getCenter: () ->
    [@_map.getCenter().long, @_map.getCenter().lat]

  # ============================================================================
  resize: (width, height) ->
    @_mapParent.style.width = width + "px"
    @_mapParent.style.height = height + "px"
    @_map.invalidateSize()

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
    @_mapParent.style.width = HG.Display.CONTAINER.offsetWidth + "px"
    @_mapParent.style.height = HG.Display.CONTAINER.offsetHeight + "px"
    @_mapParent.style.zIndex = "#{HG.Display.Z_INDEX}"

    HG.Display.CONTAINER.appendChild @_mapParent

    options =
      maxZoom:      6
      minZoom:      1
      zoomControl:  true
      #maxBounds:    [[-180,-90], [180, 90]]

    @_map = L.map @_mapParent, options
    @_map.setView [51.505, 10.09], 4
    @_map.attributionControl.setPrefix ''

    L.tileLayer('data/tiles/{z}/{x}/{y}.png').addTo @_map

    @_isRunning = true

  # ============================================================================
  _initEventHandling: ->
    window.addEventListener 'resize', @_onWindowResize, false

  # ============================================================================
  _initLabels: ->

    @_visibleLabels = []

    @_labelController.onShowLabel @, (label) =>
      @_showLabel label

    @_labelController.onHideLabel @, (label) =>
      @_hideLabel label

  # ============================================================================
  _onWindowResize: (event) =>
    @_mapParent.style.width = $(HG.Display.CONTAINER.parentNode).width() + "px"
    @_mapParent.style.height = $(HG.Display.CONTAINER.parentNode).height() + "px"


  # ============================================================================
  _showLabel: (label) =>
    label.myLeafletLabel = new L.Label();
    label.myLeafletLabel.setContent label.getName()
    label.myLeafletLabel.setLatLng label.getLatLng()
    @_map.showLabel label.myLeafletLabel
    label.myLeafletLabel.options.offset = [
      -label.myLeafletLabel._container.offsetWidth/2,
      -label.myLeafletLabel._container.offsetHeight/2
    ]

    label.myLeafletLabel._updatePosition()
    $(label.myLeafletLabel._container).addClass("visible")


  # ============================================================================
  _hideLabel: (label) =>
    $(label.myLeafletLabel._container).removeClass("visible")
    @_visibleLabels.splice(@_visibleLabels.indexOf(label), 1)
    @_map.removeLayer label.myLeafletLabel
