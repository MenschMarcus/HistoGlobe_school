window.HG ?= {}

class HG.HiventsOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_map = null
    @_hiventController = null
    @_hiventMarkers = []

    @_onMarkerAddedCallbacks = []
    @_markersLoaded = false
    @_dragStart = new HG.Vector 0, 0

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventsOnMap = @

    if hgInstance.categoryIconMapping
      for category in hgInstance.categoryIconMapping.getCategories()
        icons = hgInstance.categoryIconMapping.getIcons(category)
        for element of icons
          HG.createCSSSelector ".hivent_marker_2D_#{category}_#{element}",
          "width: #{HGConfig.hivent_marker_2D_width.val}px !important;
           height: #{HGConfig.hivent_marker_2D_height.val}px !important;
           margin-top: -#{HGConfig.hivent_marker_2D_height.val/2}px;
           margin-left: -#{HGConfig.hivent_marker_2D_width.val/2}px;
           position: absolute !important;
           background-image: url(#{icons[element]}) !important;
           background-size: cover !important;"

    @_map = hgInstance.map._map
    @_hiventController = hgInstance.hiventController

    if @_hiventController
      @_markerGroup = new L.MarkerClusterGroup(
        {
          showCoverageOnHover: false,
          maxClusterRadius: 20
        })

      @_hiventController.onHiventAdded (handle) =>
        handle.onShow @, (self) =>
          marker = new HG.HiventMarker2D self, hgInstance.map, @_map, @_markerGroup

          @_hiventMarkers.push marker
          @_markersLoaded = @_hiventController._hiventsLoaded
          callback marker for callback in @_onMarkerAddedCallbacks

      @_map.getPanes().overlayPane.addEventListener "mousedown", (event) =>
        @_dragStart = new HG.Vector event.x, event.y

      @_map.getPanes().overlayPane.addEventListener "mouseup", (event) =>
        mousepos = new HG.Vector event.x, event.y
        distance = mousepos.clone()
        distance.sub @_dragStart
        if distance.length() <= 2
          HG.HiventHandle.DEACTIVATE_ALL_HIVENTS()

      @_map.addLayer @_markerGroup
    else
      console.error "Unable to show hivents on Map: HiventController module not detected in HistoGlobe instance!"

  # ============================================================================
  onMarkerAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onMarkerAddedCallbacks.push callbackFunc

      if @_markersLoaded
        callbackFunc marker for marker in @_hiventMarkers

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

