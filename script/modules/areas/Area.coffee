window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (id, name, geometry, labelPos, startDate, endDate, type, areaStyler) ->

    # HG.mixin @, HG.CallbackContainer
    # HG.CallbackContainer.call @

    # @addCallback "onShow"
    # @addCallback "onHide"

    # init necessary area data
    @_id        = id
    @_name      = name
    @_geometry  = geometry
    @_startDate = startDate
    @_endDate   = endDate
    @_type      = type

    # initally each area is inactive and is set active only by AreaController
    @_active    = false

    # get all styles from area styler
    if areaStyler?
      @_setStyles areaStyler

    # initially area has normal theme class
    @_activeThemeClass  = 'normal'
    @_prepareStyle null

    # set label from manual input or calculate it based on geometry
    if labelPos?
      @_labelPos = labelPos
    else
      @_calcLabelPos()

  # ============================================================================
  getId: ->
    @_id

  # ============================================================================
  getName: ->
    @_name

  # ============================================================================
  getLabelPos: ->
    @_labelPos

  # ============================================================================
  getBoundingBox: ->
    @_boundingBox

  # ============================================================================
  getStartDate: ->
    @_startDate

  # ============================================================================
  getEndDate: ->
    @_endDate

  # ============================================================================
  getGeometry: ->
    @_geometry

  # ============================================================================
  getType: ->
    @_type      # todo: is 'type' really necessary?

  # ============================================================================
  isActive: ->
    @_active

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
  setActive: () ->
    @_active = yes

  # ============================================================================
  setInactive: () ->
    @_active = no

  # ============================================================================
  setActiveThemeClass: (activeTheme, activeThemeClass) ->
    @_activeThemeClass = activeThemeClass
    @_prepareStyle activeTheme


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _calcLabelPos: () ->

    minLat = 180
    minLng = 90
    maxLat = -180
    maxLng = -90

    # only take largest subpart of the area into account
    maxIndex = 0
    for area, i in @_geometry
      if area.length > @_geometry[maxIndex].length
        maxIndex = i

    # calculate label position based on largest subpart
    if  @_geometry[maxIndex].length > 0
      # final position [lat, lng]
      labelLat = 0
      labelLng = 0

      # position = center of bounding box of polygon
      for coords in @_geometry[maxIndex]
        labelLat += coords.lat
        labelLng += coords.lng

        if coords.lat < minLat then minLat = coords.lat
        if coords.lat > maxLat then maxLat = coords.lat
        if coords.lng < minLng then minLng = coords.lng
        if coords.lng > maxLng then maxLng = coords.lng

      labelLat /= @_geometry[maxIndex].length
      labelLng /= @_geometry[maxIndex].length

      @_labelPos = [labelLat, labelLng]
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
  _setStyles: (areaStyler) ->
    @_normalStyle     = areaStyler.getNormalStyle()
    @_highlightStyle  = areaStyler.getHighlightStyle()

    # for each theme area has certain style in certain time period
    @_themeStyles     = areaStyler.getThemeStyles @_id
