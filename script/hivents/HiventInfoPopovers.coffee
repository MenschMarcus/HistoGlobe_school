window.HG ?= {}

class HG.HiventInfoPopovers

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    @_hiventsOnMap = null

  # ============================================================================
  hgInit: (hgInstance) ->
    @_hiventsOnMap = hgInstance.hiventsOnMap

    if @_hiventsOnMap
      @_hiventsOnMap.onMarkerAdded (marker) =>
        if marker.parentDiv
          @_addPopover marker

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################
  _addPopover: (marker) =>
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

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

