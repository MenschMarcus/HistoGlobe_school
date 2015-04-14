window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (id, area, type, styler) ->

    # init data
    @_id        = id
    @_type      = type

    # get all styles
    if styler?
      @_setStyles styler

    # create geometry
       # geometry (polygons)
    @_geometry = []

    # error handling: empty layer because of non-existing geometry
    if area.geometry.coordinates.length is 0
      @_geometry = [[]]

    else
      console.log area
      data = L.GeoJSON.geometryToLayer area
      if area.geometry.type is "Polygon"
        @_geometry.push data._latlngs
      else if area.geometry.type is "MultiPolygon"
        for id, layer of data._layers
          @_geometry.push layer._latlngs

    # get bounding box
    @_calcBoundingBox()

    # initially area has normal theme class
    @_activeThemeClass  = 'normal'
    @_prepareStyle null

  # ============================================================================
  getId: ->
    @_id

  # ============================================================================
  getBoundingBox: ->
    @_boundingBox

  # ============================================================================
  getGeometry: ->
    @_geometry

  # ============================================================================
  getType: ->
    @_type      # todo: is 'type' really necessary?

  # ============================================================================
  getStyle: ->
    @_style

  # ============================================================================
  getHighlightStyle: ->
    @_highlightStyle

  # ============================================================================
  getActiveThemeClass: () ->
    @_activeThemeClass

  # ============================================================================
  getThemeClasses: (inTheme) ->
    outThemeClasses = null
    # find correct theme
    for theme in @_themeStyles
      if theme.themeName is inTheme
        # find correct theme class
        outThemeClasses = theme.themeClasses
    outThemeClasses

  # ============================================================================
  setActiveThemeClass: (activeTheme, activeThemeClass) ->
    @_activeThemeClass = activeThemeClass
    @_prepareStyle activeTheme


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _calcBoundingBox: () ->

    minLat = 180
    minLng = 90
    maxLat = -180
    maxLng = -90

    # only take largest subpart of the area into account
    maxIndex = 0
    for area, i in @_geometry
      if area.length > @_geometry[maxIndex].length
        maxIndex = i

    # find smallest and largest lat and long coordinates of all points in largest subpart
    if  @_geometry[maxIndex].length > 0
      for coords in @_geometry[maxIndex]
        if coords.lat < minLat then minLat = coords.lat
        if coords.lat > maxLat then maxLat = coords.lat
        if coords.lng < minLng then minLng = coords.lng
        if coords.lng > maxLng then maxLng = coords.lng

      @_boundingBox = [minLat, minLng, maxLat, maxLng]

  # ============================================================================
  # idea: prepare style so it can be handed out in O(1)
  _prepareStyle: (inTheme) ->
    if not inTheme or @_activeThemeClass is 'normal'
      @_style = @_normalStyle
    else
      # find correct theme
      for theme in @_themeStyles
        if theme.themeName is inTheme
          # find correct theme class
          for themeClass in theme.themeClasses
            if themeClass.className is @_activeThemeClass
              @_style = themeClass.style

  # ============================================================================
  # get all styles from area styler
  _setStyles: (styler) ->
    @_normalStyle     = styler.getNormalStyle()
    @_highlightStyle  = styler.getHighlightStyle()

    # for each theme area has certain style in certain time period
    @_themeStyles     = styler.getThemeStyles @_id
