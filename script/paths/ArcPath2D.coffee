window.HG ?= {}

class HG.ArcPath2D extends HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (start_hivent, end_hivent, map) ->

    if start_hivent.endDate < end_hivent.startDate
      HG.Path.call @, start_hivent, end_hivent
    else
      HG.Path.call @, end_hivent, start_hivent

    @_map = map
    @_arc = undefined

    p1 = new HG.Vector @_start_hivent.long, @_start_hivent.lat
    p2 = new HG.Vector @_end_hivent.long, @_end_hivent.lat
    p3 = new HG.Vector (p2.at(0) + p1.at(0)) / 2, Math.max p2.at(1), p1.at(1)

    @_initParabolaParameters p1, p2, p3
    @_initArc p1, p2, p3

  # ============================================================================
  getMarkerPos: (date) ->
    long = @_getLongFromDate date
    lat = @_getLatFromLong long

    {long:long, lat:lat}

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  # returns parameters a, b, c of equation y= a * x^2 + b * x + c for three
  # given points
  _initParabolaParameters: (p1, p2, p3) ->
    denom = (p1.at(0) - p2.at(0)) * (p1.at(0) - p3.at(0)) * (p2.at(0) - p3.at(0))
    a = (p3.at(0) * (p2.at(1) - p1.at(1)) + p2.at(0) * (p1.at(1) - p3.at(1)) + p1.at(0) * (p3.at(1) - p2.at(1))) / denom
    b = (p3.at(0) * p3.at(0) * (p1.at(1) - p2.at(1)) + p2.at(0) * p2.at(0) * (p3.at(1) - p1.at(1)) + p1.at(0) * p1.at(0) * (p2.at(1) - p3.at(1))) / denom
    c = (p2.at(0) * p3.at(0) * (p2.at(0) - p3.at(0)) * p1.at(1) + p3.at(0) * p1.at(0) * (p3.at(0) - p1.at(0)) * p2.at(1) + p1.at(0) * p2.at(0) * (p1.at(0) - p2.at(0)) * p3.at(1)) / denom

    @_param = {a:a, b:b, c:c}

  # ============================================================================
  _getLatFromLong: (long) ->
    long*long * @_param.a + long * @_param.b + @_param.c

  # ============================================================================
  _getLongFromDate: (date) ->
    start = @_start_hivent.endDate.getTime()
    end   = @_end_hivent.startDate.getTime()
    now   = date.getTime()

    delta = (now - start)/(end - start)

    long = @_start_hivent.long + delta*(@_end_hivent.long - @_start_hivent.long)

  # ============================================================================
  _initArc: (p1, p2, p3) ->
    dist = p2.at(0) - p1.at(0)
    stepSize = dist/RESOLUTION

    arcPoints = []
    long = p1.at(0)

    for i in [0..RESOLUTION]
      lat = @_getLatFromLong long
      arcPoints.push {lng: long, lat: lat}
      long += stepSize

    @_arc = new L.polyline arcPoints, {
      color: "#952"
      lineCap: "butt"
      weight: "3"
      opacity: "0.8"
      dashArray: "5, 2"
    }

    @_map.addLayer @_arc

  # ============================================================================
  _destroyArcPath2D: () ->
    @_map.removeLayer @_arc
    @_arc = null

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  RESOLUTION = 30 # lines drawn per arc












