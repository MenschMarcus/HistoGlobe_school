window.HG ?= {}

class HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (start_hivent, end_hivent) ->

    if start_hivent.endDate < end_hivent.startDate
      @_start_hivent = start_hivent
      @_end_hivent   = end_hivent
    else
      @_start_hivent = end_hivent
      @_end_hivent   = start_hivent

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
    icon = new L.DivIcon {className: "hivent_marker_2D_#{@_start_hivent.category}_default", iconSize: null}
    @_marker = new L.Marker [@_start_hivent.lat, @_start_hivent.long], {icon: icon}
    @_marker_visible = false

    date = new Date(2003, 1, 1)

    setInterval () =>
      date.setDate(date.getDate()+5)
      @_updateAnimation date
    , 16

  # ============================================================================
  _updateAnimation: (date) ->
    if @_isValidDate date
      unless @_marker_visible
        @_marker.addTo @_map
        @_marker_visible = true

      pos = @getMarkerPos date

      @_marker.setLatLng([pos.lat, pos.long])

    else if @_marker_visible
      @_map.removeLayer @_marker
      @_marker_visible = false

  # ============================================================================
  _isValidDate: (date) ->
    date > @_start_hivent.endDate and date < @_end_hivent.startDate
