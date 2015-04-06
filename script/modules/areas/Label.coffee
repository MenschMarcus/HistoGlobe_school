window.HG ?= {}

class HG.Label

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (id, name, position, boundingBox, startDate, endDate, styler) ->

    # init data
    @_id          = id
    @_name        = name
    @_position    = position
    @_boundingBox = boundingBox   # of associated area
    @_startDate   = startDate
    @_endDate     = endDate

    # get all styles
    if styler?
      @_setStyles styler

    # initally each area is inactive and is set active only by AreaController
    @_active    = false

    # initially area has normal theme class
    @_activeThemeClass  = 'normal'
    @_prepareStyle null


  # ============================================================================
  getId: ->
    @_id

  # ============================================================================
  getName: ->
    @_name

  # ============================================================================
  getPos: ->
    @_position

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
  isActive: ->
    @_active

  # ============================================================================
  getStyle: ->
    @_style

  # ============================================================================
  getHighlightStyle: ->
    @_highlightStyle

  # ============================================================================
  getActiveThemeClass: ->
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
