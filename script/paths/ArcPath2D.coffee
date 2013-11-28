window.HG ?= {}

class HG.ArcPath2D extends HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (coordinates, dates, map) ->

    HG.Path.call @, coordinates, dates

    @_map = map

    @_createArcs()

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
  _createArcs: () ->

    coordCount = @_coordinates.length
    if coordCount > 1
      for i in [1...coordCount]
        p1 = @_coordinates[i-1]
        p1 = new HG.Vector p1.long, p1.lat
        p2 = @_coordinates[i]
        p2 = new HG.Vector p2.long, p2.lat

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

        polyline = new L.polyline arcPoints
        @_map.addLayer polyline



  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  RESOLUTION = 30 # lines drawn per arc












