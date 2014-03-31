window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShowArea"
    @addCallback "onHideArea"

    @_areas = []
    @_timeline = null
    @_now = null

    @_currentCategoryFilter = null # [category_a, category_b, ...]

    defaultConfig =
      areaJSONPaths: undefined,
      areaStylerConfig: undefined

    conf = $.extend {}, defaultConfig, config

    @loadAreasFromJSON conf

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_area_styler = hgInstance.areaStyler
    @_now = @_timeline.getNowDate()

    @_timeline.onNowChanged @, (date) ->
      @_now = date
      for area in @_areas
        area.setDate date

    hgInstance.categoryFilter?.onFilterChanged @,(categoryFilter) =>
      @_currentCategoryFilter = categoryFilter
      @_filterActiveAreas()

  # ============================================================================
  loadAreasFromJSON: (config) ->

    for path in config.areaJSONPaths
      $.getJSON path, (countries) =>
        for country in countries.features

          execute_async = (c) =>
            setTimeout () =>
              newArea = new HG.Area c, @_area_styler

              newArea.onShow @, (area) =>
                @notifyAll "onShowArea", area

              newArea.onHide @, (area) =>
                @notifyAll "onHideArea", area

              @_areas.push newArea

              newArea.setDate @_now
            , 0

          execute_async country

  # ============================================================================
  filterActiveAreas:()->

    activeAreas = @getActiveAreas
    for area in activeAreas
      active = false
      for category in area.getCategories() #TODO
        if category in @_currentCategoryFilter
          active = true
      if active
        @notifyAll "onShowArea", area #???
      else
        @notifyAll "onHideArea", area # ???

  # ============================================================================
  filterArea:()->
    for category in area.getCategories() #TODO
      if category in @_currentCategoryFilter
        return true
    return false




  # ============================================================================
  getActiveAreas:()->
    newArray = []
    for a in @_areas
      if a._active
        newArray.push a
    return newArray

  
  # ============================================================================
  getAllAreas:()->
    return @_areas



  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################


