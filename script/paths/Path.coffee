window.HG ?= {}

class HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (startHiventHandle, endHiventHandle) ->

    if startHiventHandle.endDate < endHiventHandle.startDate
      @_startHiventHandle = startHiventHandle
      @_endHiventHandle   = endHiventHandle
    else
      @_startHiventHandle = endHiventHandle
      @_endHiventHandle   = startHiventHandle

    @_initMarker()

  # ============================================================================
  # overide this in derived classes!
  getMarkerPos: (date) ->
    {long:0, lat:0}

  # ============================================================================
  setDate: (date) ->
    @_updateAnimation date

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initMarker: () ->
    icon = new L.DivIcon {className: "hivent_marker_2D_#{@_startHiventHandle.getHivent().category}_default", iconSize: null}
    @_marker = new L.Marker [@_startHiventHandle.getHivent().lat, @_startHiventHandle.getHivent().long], {icon: icon}
    @_markerVisible = false

    date = new Date(2003, 1, 1)

    setInterval () =>
      date.setDate(date.getDate()+5)
      @_updateAnimation date
    , 16

  # ============================================================================
  _updateAnimation: (date) ->
    if @_isValidDate date
      unless @_markerVisible
        @_marker.addTo @_map
        @_markerVisible = true

      pos = @getMarkerPos date

      @_marker.setLatLng([pos.lat, pos.long])

    else if @_markerVisible
      @_map.removeLayer @_marker
      @_markerVisible = false

  # ============================================================================
  _isValidDate: (date) ->
    date > @_startHiventHandle.getHivent().endDate and date < @_endHiventHandle.getHivent().startDate
