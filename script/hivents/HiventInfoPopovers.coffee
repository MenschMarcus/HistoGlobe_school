window.HG ?= {}

class HG.HiventInfoPopovers

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    @_hiventsOnMap = null

    @_hiventMarkers = []
    @_onPopoverAddedCallbacks = []

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventInfoPopovers = @

    @_hiventsOnMap = hgInstance.hiventsOnMap

    if @_hiventsOnMap
      @_hiventsOnMap.onMarkerAdded (marker) =>
        if marker.parentDiv
          @_addPopover marker

  # ============================================================================
  onPopoverAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onPopoverAddedCallbacks.push callbackFunc

      if @_markersLoaded
        callbackFunc marker for marker in @_hiventMarkers

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################
  _addPopover: (marker) =>
    @_hiventMarkers.push(marker)

    marker.hiventInfoPopover = null

    handle = marker.getHiventHandle()

    showHiventInfoPopover = (displayPosition) ->
      marker.hiventInfoPopover?= new HG.HiventInfoPopover handle, new HG.Vector(0, 0), HG.Display.CONTAINER
      marker.hiventInfoPopover.setAnchor new HG.Vector(displayPosition.x, displayPosition.y)
      marker.hiventInfoPopover.positionWindowAtAnchor()
      marker.hiventInfoPopover.show()

    hideHiventInfoPopover = (displayPosition) =>
      marker.hiventInfoPopover?.hide()

    handle.onActive marker, showHiventInfoPopover
    handle.onInActive marker, hideHiventInfoPopover
    marker.onPositionChanged @, (displayPosition) ->
      marker.hiventInfoPopover?.setAnchor new HG.Vector(displayPosition.x, displayPosition.y)
    marker.onDestruction @, () ->
      marker.hiventInfoPopover?._destroy()

    callbackFunc marker for callbackFunc in @_onPopoverAddedCallbacks

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

