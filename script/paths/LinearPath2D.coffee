window.HG ?= {}

class HG.LinearPath2D extends HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (start_hivent, end_hivent, map) ->

    HG.Path.call @, start_hivent, end_hivent

    @_map = map
    @_arc = undefined

    p1 = new HG.Vector @_start_hivent.long, @_start_hivent.lat
    p2 = new HG.Vector @_end_hivent.long, @_end_hivent.lat

    @_initArc p1, p2

  # ============================================================================
  getMarkerPos: (date) ->
    start = @_start_hivent.endDate.getTime()
    end   = @_end_hivent.startDate.getTime()
    now   = date.getTime()

    delta = (now - start)/(end - start)

    long = @_start_hivent.long + delta*(@_end_hivent.long - @_start_hivent.long)
    lat = @_start_hivent.lat + delta*(@_end_hivent.lat - @_start_hivent.lat)

    {long:long, lat:lat}

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initArc: (p1, p2) ->

    points = []
    points.push {lng: p1.at(0), lat: p1.at(1)}
    points.push {lng: p2.at(0), lat: p2.at(1)}

    @_arc = new L.polyline points, {
      color: "#952"
      lineCap: "butt"
      weight: "3"
      opacity: "0.8"
      dashArray: "5, 2"
    }

    @_map.addLayer @_arc

  # ============================================================================
  _destroy: () ->
    @_map.removeLayer @_arc
    @_arc = null













