window.HG ?= {}

class HG.HiventInfoPopovers

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      allowMultiplePopovers : false

    @_config = $.extend {}, defaultConfig, config

    @_hiventsOnMap = null
    @_hiventsOnGlobe = null

    @_hiventMarkers = []
    @_onPopoverAddedCallbacks = []

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventInfoPopovers = @

    @_hgInstance = hgInstance
    @_hiventsOnMap = hgInstance.hiventsOnMap
    @_hiventsOnGlobe = hgInstance.hiventsOnGlobe
    @_hiventsOnTimeline = hgInstance.hiventsOnTimeline
    @_globe = hgInstance.globe
    @_mapArea = hgInstance._map_area

    if @_hiventsOnMap
      @_hiventsOnMap.onMarkerAdded (marker) =>
        if marker.parentDiv
          @_addPopover marker, @_hgInstance.mapCanvas, true

    if @_hiventsOnGlobe
      @_hiventsOnGlobe.onMarkerAdded (marker) =>
        if marker.parentDiv
          @_addPopover marker, @_globe._globeCanvas, true

    if @_hiventsOnTimeline
      @_hiventsOnTimeline.onMarkerAdded (marker) =>
        if marker.parentDiv
          unless marker.getHiventHandle().getHivent().lat? or marker.getHiventHandle().getHivent().long?
            @_addPopover marker, @_hgInstance.mapCanvas, false

  # ============================================================================
  onPopoverAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onPopoverAddedCallbacks.push callbackFunc

      if @_markersLoaded
        callbackFunc marker for marker in @_hiventMarkers

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################
  _addPopover: (marker, container, useMarkerPosition) =>
    @_hiventMarkers.push(marker)

    marker.hiventInfoPopover = null

    handle = marker.getHiventHandle()

    i = 0
    if useMarkerPosition
      i = handle.getHivent().lat.indexOf marker.getPosition().lat

    showHiventInfoPopover = (displayPosition) =>

      unless @_config.allowMultiplePopovers
        HG.HiventHandle.DEACTIVATE_ALL_OTHER_HIVENTS(handle)

      marker.hiventInfoPopover?= new HG.HiventInfoPopover handle, container, @_hgInstance, i, useMarkerPosition

      if useMarkerPosition
        marker.hiventInfoPopover.show new HG.Vector(displayPosition.x, displayPosition.y)

      else
        marker.hiventInfoPopover.show new HG.Vector(container.offsetWidth/2, container.offsetHeight/2)

    hideHiventInfoPopover = () =>
      marker.hiventInfoPopover?.hide()

    handle.onActive marker, showHiventInfoPopover
    handle.onInActive marker, hideHiventInfoPopover

    if useMarkerPosition
      handle.onFocus marker, () =>
        setTimeout () =>
          handle.active marker, marker.getDisplayPosition()
        , 500

      marker.onPositionChanged @, (displayPosition) ->
        marker.hiventInfoPopover?.updatePosition new HG.Vector(displayPosition.x, displayPosition.y)

    marker.onDestruction @, () ->
      marker.hiventInfoPopover?.destroy()

    callbackFunc marker for callbackFunc in @_onPopoverAddedCallbacks


