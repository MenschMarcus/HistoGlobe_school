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

    @_categoryFilter = null
    @_currentCategoryFilter = null # [category_a, category_b, ...]

    defaultConfig =
      areaJSONPaths: undefined,

    conf = $.extend {}, defaultConfig, config

    # init all areas
    @_loadAreasFromJSON conf

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_areaStyler = hgInstance.areaStyler
    @_now = @_timeline.getNowDate()

    # main activity: what happens if now date changes?
    @_timeline.onNowChanged @, (date) ->
      oldDate = @_now
      newDate = date

      oldAreas = @getActiveAreas()   # old countries of last time point
      newAreas = [] # new countries of current time point

      console.log oldAreas

      # problem: active state of areas

      addAreas = []
      remAreas = []

      for area in @_areas

        # active status
        wasActive = area.isActive()
        # console.log wasActive

        area.setDate newDate

      @_now = date

    # category handling
    hgInstance.categoryFilter?.onFilterChanged @,(categoryFilter) =>
      @_currentCategoryFilter = categoryFilter
      @_filterActiveAreas()

    @_categoryFilter = hgInstance.categoryFilter if hgInstance.categoryFilter


  # ============================================================================
  getAllAreas:()->   @_areas

  # ============================================================================
  getActiveAreas:()->
    newArray = []
    for a in @_areas
      if a._active
        newArray.push a
    newArray

  # # ============================================================================
  # filterArea:()->
  #   for category in area.getCategories() #TODO
  #     if category in @_currentCategoryFilter
  #       true
  #   false



  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _loadAreasFromJSON: (config) ->

    # parse each geojson file
    for file in config.areaJSONPaths
      $.getJSON file, (countries) =>
        numCountriesToLoad = countries.features.length  # counter
        for country in countries.features

          # parse file asynchronously
          executeAsync = (country) =>
            setTimeout () =>

              # convert data to HG area
              newArea = new HG.Area country, @_areaStyler
              newArea.setDate @_now

              # attach event handlers to area
              newArea.onShow @, (area) =>
                @notifyAll "onShowArea", area
                area.isVisible = true

              newArea.onHide @, (area) =>
                @notifyAll "onHideArea", area
                area.isVisible = false

              @_areas.push newArea

              # counter handling
              numCountriesToLoad--
              if numCountriesToLoad is 0
                @_currentCategoryFilter = @_categoryFilter.getCurrentFilter()
                @_filterActiveAreas()

            , 0

          executeAsync country

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
