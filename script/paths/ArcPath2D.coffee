window.HG ?= {}

class HG.ArcPath2D extends HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (start_hivent, end_hivent, map) ->

    HG.Path.call @, start_hivent, end_hivent

    @_map = map
    @_arc = null

    @_createArc()

  # ============================================================================
  getPosition: (date) ->


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # returns parameters a, b, c of equation y= a * x^2 + b * x + c for three
  # given points
  # ============================================================================
  _calculateParabolaParameters: (p1, p2, p3) ->

    denom = (p1.at(0) - p2.at(0)) * (p1.at(0) - p3.at(0)) * (p2.at(0) - p3.at(0))
    a = (p3.at(0) * (p2.at(1) - p1.at(1)) + p2.at(0) * (p1.at(1) - p3.at(1)) + p1.at(0) * (p3.at(1) - p2.at(1))) / denom
    b = (p3.at(0) * p3.at(0) * (p1.at(1) - p2.at(1)) + p2.at(0) * p2.at(0) * (p3.at(1) - p1.at(1)) + p1.at(0) * p1.at(0) * (p2.at(1) - p3.at(1))) / denom
    c = (p2.at(0) * p3.at(0) * (p2.at(0) - p3.at(0)) * p1.at(1) + p3.at(0) * p1.at(0) * (p3.at(0) - p1.at(0)) * p2.at(1) + p1.at(0) * p2.at(0) * (p1.at(0) - p2.at(0)) * p3.at(1)) / denom

    {a:a, b:b, c:c}

  # ============================================================================
  _createArc: () ->


    p1 = new HG.Vector @_start_hivent.long, @_start_hivent.lat
    p2 = new HG.Vector @_end_hivent.long, @_end_hivent.lat
    p3 = new HG.Vector (p2.at(0) + p1.at(0)) / 2, Math.max p2.at(1), p1.at(1)

    param = @_calculateParabolaParameters p1, p2, p3

    dist = p2.at(0) - p1.at(0)

    stepSize = dist/RESOLUTION

    arcPoints = []
    x = p1.at(0)

    for i in [0..RESOLUTION]
      y = x*x * param.a + x * param.b + param.c
      arcPoints.push {lng: x, lat: y}
      x += stepSize

    @_arc = new L.polyline arcPoints
    @_map.addLayer @_arc

  # ============================================================================
  _destroyArcPath2D: () ->
    @_map.removeLayer @_arc
    @_arc = null

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  RESOLUTION = 30 # lines drawn per arc












