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

          mouseover: (e) =>
            @_animate e.target, {"fill-opacity": 0.5}, 50

          mouseout: (e) =>
            @_animate e.target, {"fill-opacity": 0.2}, 150
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
    @_mapParent.style.zIndex = "#{HG.Display.Z_INDEX}"

    @_container.appendChild @_mapParent

    options =
      maxZoom:      6
      minZoom:      1
      zoomControl:  false

    @_map = L.map @_mapParent, options
    @_map.setView [51.505, 10.09], 4
    @_map.attributionControl.setPrefix ''

    L.tileLayer('data/tiles/{z}/{x}/{y}.png').addTo @_map


    # eu = {
    #   "BEL": new Date(1958, 1, 1)
    #   "FR1": new Date(1958, 1, 1)
    #   "ITA": new Date(1958, 1, 1)
    #   "LUX": new Date(1958, 1, 1)
    #   "NL1": new Date(1958, 1, 1)
    #   "DEU": new Date(1958, 1, 1)
    #   "DN1": new Date(1973, 1, 1)
    #   "IRL": new Date(1973, 1, 1)
    #   "GB1": new Date(1973, 1, 1)
    #   "GRC": new Date(1981, 1, 1)
    #   "PRT": new Date(1986, 1, 1)
    #   "ESP": new Date(1986, 1, 1)
    #   "FI1": new Date(1995, 1, 1)
    #   "AUT": new Date(1995, 1, 1)
    #   "SWE": new Date(1995, 1, 1)
    #   "EST": new Date(2004, 5, 1)
    #   "LVA": new Date(2004, 5, 1)
    #   "LTU": new Date(2004, 5, 1)
    #   "MLT": new Date(2004, 5, 1)
    #   "POL": new Date(2004, 5, 1)
    #   "SVK": new Date(2004, 5, 1)
    #   "SVN": new Date(2004, 5, 1)
    #   "CZE": new Date(2004, 5, 1)
    #   "HUN": new Date(2004, 5, 1)
    #   "CYP": new Date(2004, 5, 1)
    #   "BGR": new Date(2007, 1, 1)
    #   "ROU": new Date(2007, 1, 1)
    #   "HRV": new Date(2013, 7, 1)
    # }

    # now = new Date(2014, 1, 1)

    # getColor = (state) ->
    #   if eu[state]? and eu[state] < now then "#ff5511" else "#ffffff"

    # # areas --------------------------------------------------------------------
    # $.getJSON "data/geo.json", (statesData) =>
    #   highlightStyle =
    #     fillColor:    "#000000"
    #     weight:       0
    #     opacity:      0
    #     fillOpacity:  0.5

    #   normalStyle = (feature) ->
    #     fillColor:    getColor(feature.properties.sov_a3)
    #     weight:       0
    #     opacity:      0
    #     fillOpacity:  0.2

    #   options =
    #     style: normalStyle
    #     onEachFeature:  (feature, layer) =>
    #       #coord2 = feature.geometry.coordinates[0][0][0][0]
    #       #coord1 = feature.geometry.coordinates[0][0][0][1]
    #       coord2 = feature.geometry.coordinates[0][0][0]
    #       coord1 = feature.geometry.coordinates[0][0][1]

    #       array = feature.geometry.coordinates
    #       if feature.geometry.coordinates.length == 1
    #         array = array[0]
    #       console.log array
    #       if coord2[0] isnt undefined and coord1[0] isnt undefined
    #         coord2 = coord1[0]
    #         coord1 = coord1[1]

    #       if coord1 isnt undefined and coord2 isnt undefined
    #         polygon = L.polyline([
    #           [coord1, coord2],
    #           [coord1, coord2],
    #           [coord1, coord2],
    #         ])
    #         label = new L.Label();
    #         label.setContent(feature.properties.admin)
    #         label.setLatLng(polygon.getBounds().getCenter())
    #         @_map.showLabel(label)

    #       layer.on(
    #         click:      (e) => console.log e.target.feature.geometry.coordinates
    #         #click:      (e) => @_map.fitBounds e.target.getBounds()
    #         mouseover:  (e) => e.target.setStyle highlightStyle
    #         mouseout:   (e) => boundaryLayer.resetStyle e.target
    #       )

    #   # data = topojson.feature statesData, statesData.objects.geo

    #   boundaryLayer = L.geoJson(statesData, options)
    #   boundaryLayer.addTo @_map


      # polygon = L.polyline([
      #   [50.7612, 10.2756],
      #   [50.7702, 10.2796],
      #   [50.7802, 10.2750],
      #   ])

      # label = new L.Label();
      # label.setContent('Germany')
      # label.setLatLng(polygon.getBounds().getCenter())
      # @_map.showLabel(label)




    @_isRunning = true

  # ============================================================================
  _initEventHandling: ->
    window.addEventListener 'resize', @_onWindowResize, false

  # ============================================================================
  _initHivents: ->
    @_hiventController.onHiventsChanged (handles) =>
      marker = new HG.HiventMarker2D handle, this, @_map for handle in handles

    @_map.on "click", HG.HiventHandle.DEACTIVATE_ALL_HIVENTS

  # ============================================================================
  _animate: (area, attributes, durartion) ->
    if area._layers?
      for id, path of area._layers
        d3.select(path._path).transition().duration(durartion).attr(attributes)
    else if area._path?
      d3.select(area._path).transition().duration(durartion).attr(attributes)

  # ============================================================================
  _initAreas: ->
    @_areaController.onAreaChanged @, (area) =>
      @addAreaLayer area

  # ============================================================================
  _onWindowResize: (event) =>
    @_mapParent.style.width = $(@_container.parentNode).width() + "px"
    @_mapParent.style.height = $(@_container.parentNode).height() + "px"
