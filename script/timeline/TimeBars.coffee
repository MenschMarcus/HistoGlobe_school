window.HG ?= {}

class HG.TimeBars

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      title: "TimeBars"
      elements: []

    @_config = $.extend {}, defaultConfig, config

    #@_categoryFilter =null
    @_currentCategoryFilter = [] # [category_a, category_b, ...]

    @_activeTimeBars = []

    @_timeline = {}

  # ============================================================================
  hgInit: (hgInstance, parentDiv) ->

    @_timeline = hgInstance.timeline

    hgInstance.categoryFilter?.onFilterChanged @,(categoryFilter) =>
      @_currentCategoryFilter = categoryFilter
      @_filterTimeBars()

    #@_categoryFilter = hgInstance.categoryFilter if hgInstance.categoryFilter

  # ----------------------------------------------------------------------------
  _filterTimeBars: ->
    @_activeTimeBars = []
    if @_currentCategoryFilter?
      if @_currentCategoryFilter.length > 0

        for element in @_config.elements
          if @_isArray(element.categories)
            for category in element.categories
              for currentCategory in @_currentCategoryFilter
                if category == currentCategory
                  temp = [element.startDate, element.endDate, category]
                  @_activeTimeBars.push temp
          else
            category = element.categories
            for currentCategory in @_currentCategoryFilter
              if category == currentCategory
                temp = [element.startDate, element.endDate, category]
                @_activeTimeBars.push temp

        @_timeline.updateTimeBars(@_activeTimeBars)

  # ============================================================================
  _isArray:(value) ->
    (Object.prototype.toString.call value) is '[object Array]'
    