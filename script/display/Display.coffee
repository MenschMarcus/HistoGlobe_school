window.HG ?= {}

class HG.Display

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  hgInit: (hgInstance) ->
    HG.Display.CONTAINER ?= hgInstance.mapCanvas
    @overlayContainer = null

    hgInstance.onAllModulesLoaded @, () =>
      hgInstance.hiventInfoAtTag?.onHashChanged @, (key, value) =>
        if key is "bounds"
          minMax = value.split ";"
          mins = minMax[0].split ","
          maxs = minMax[1].split ","
          @zoomToBounds(mins[0], mins[1], maxs[0], maxs[1])

  # ============================================================================
  focus: (hivent) -> # hivent coords and offset coords
    @setCenter {x: hivent.long, y: hivent.lat}, {x: 0.07, y: 0.2}

  # ============================================================================
  zoomToBounds: (minLong, minLat, maxLong, maxLat) ->

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  @Z_INDEX = 0
  @CONTAINER = null
