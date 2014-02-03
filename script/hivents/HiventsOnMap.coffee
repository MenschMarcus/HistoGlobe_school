window.HG ?= {}

class HG.HiventsOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    @_map = null
    @_hiventController = null
    @_hiventMarkers = []

    @_onMarkerAddedCallbacks = []
    @_markersLoaded = false

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventsOnMap = @

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
          # self.onDestruction @, ()
          # self.onHide @,

          @_hiventMarkers.push marker
          @_markersLoaded = @_hiventController._hiventsLoaded
          callback marker for callback in @_onMarkerAddedCallbacks

      @_map.on "click", HG.HiventHandle.DEACTIVATE_ALL_HIVENTS
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

