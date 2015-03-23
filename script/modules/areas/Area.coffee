window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (id, name, geometry, startDate, endDate, type, areaStyler) ->

    # HG.mixin @, HG.CallbackContainer
    # HG.CallbackContainer.call @

    # @addCallback "onShow"
    # @addCallback "onHide"

    # init necessary area data
    @_id                = id
    @_name              = name
    @_geometry          = geometry
    @_startDate         = startDate
    @_endDate           = endDate
    @_type              = type

    # initally each area is inactive and is set active only by AreaController
    @_active            = false
    @_currentStyleTheme = 'normal'

    # get all styles from area styler
    if areaStyler?
      @_setStyles areaStyler

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
    style = null
    if @_currentStyleTheme is 'normal'
      style = @_normalStyle
    else
      for theme in @_themeStyles
        if theme.themeName == @_currentStyleTheme
          style = theme.style
    style

  # ============================================================================
  getCurrentStyleTheme: () ->
    @_currentStyleTheme

  # ============================================================================
  getHighlightStyle: ->
    @_highlightStyle

  # ============================================================================
  isInTheme: (inThemeName, inNowDate) ->
    isIn = no
    for theme in @_themeStyles
      if theme.themeName == inThemeName
        if inNowDate >= theme.startDate and inNowDate < theme.endDate
          isIn = yes
          break
    isIn


  # ============================================================================
  setLabelPos: (labelPos) ->
    @_labelPos = labelPos

  # ============================================================================
  setActive: () ->
    @_active = yes

  # ============================================================================
  setInactive: () ->
    @_active = no

  # ============================================================================
  setCurrentStyleTheme: (currentStyleTheme) ->
    @_currentStyleTheme = currentStyleTheme


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
  _setStyles: (areaStyler) ->
    @_normalStyle     = areaStyler.getNormalStyle()
    @_highlightStyle  = areaStyler.getHighlightStyle()

    # for each theme area has certain style in certain time period
    @_themeStyles     = areaStyler.getThemeStyles @_id
