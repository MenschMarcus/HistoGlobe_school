window.HG ?= {}

class HG.HiventsOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container) ->
    @_map = null
    @_hiventController = null

  # ============================================================================
  hgInit: (hgInstance) ->
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
          marker = new HG.HiventMarker2D self, this, @_map, @_markerGroup

      @_map.on "click", HG.HiventHandle.DEACTIVATE_ALL_HIVENTS
      @_map.addLayer @_markerGroup
    else
      console.error "Unable to show hivents on Map: HiventController module not detected in HistoGlobe instance!"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

