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

    @_categoryFilter =null
    @_currentCategoryFilter = null # [category_a, category_b, ...]

    defaultConfig =
      areaJSONPaths: undefined,

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

    @_categoryFilter = hgInstance.categoryFilter if hgInstance.categoryFilter

  # ============================================================================
  loadAreasFromJSON: (config) ->

    for path in config.areaJSONPaths
      $.getJSON path, (countries) =>
        countries_to_load = countries.features.length
        for country in countries.features

          execute_async = (c) =>
            setTimeout () =>
              newArea = new HG.Area c, @_area_styler

              newArea.onShow @, (area) =>
                @notifyAll "onShowArea", area
                area.isVisible = true

              newArea.onHide @, (area) =>
                @notifyAll "onHideArea", area
                area.isVisible = false

              @_areas.push newArea

              newArea.setDate @_now

              countries_to_load--
              if countries_to_load is 0
                @_currentCategoryFilter = @_categoryFilter.getCurrentFilter()
                @_filterActiveAreas()

            , 0

          execute_async country

  # ============================================================================
  _filterActiveAreas:()->

    #console.log "filter areas",@_currentCategoryFilter

    activeAreas = @getActiveAreas()
    for area in activeAreas
      active = true
      if area.getCategories()?
        for category in area.getCategories()
          unless category in @_currentCategoryFilter
            active = false
          else
            active = true
            break
      if active
        @notifyAll "onShowArea", area if not area.isVisible
        area.isVisible = true
        area.setDate @_now
      else
        @notifyAll "onHideArea", area
        area.isVisible = false

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
