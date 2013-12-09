#include Hivent.coffee
#include HiventHandle.coffee

window.HG ?= {}

class HG.HiventController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (pathToHivents) ->
    @_initHivents(pathToHivents)
    @_hiventHandles = [];
    @_filteredHiventHandles = [];
    @_hiventsChanged = false;
    @_onHiventsChangedCallbacks = [];

    @_currentTimeFilter = null; # {start: <Date>, end: <Date>}
    @_currentSpaceFilter = null; # { min: {lat: <float>, long: <float>},
                                 #   max: {lat: <float>, long: <float>}}
    @_currentCategoryFilter = null; # [category_a, category_b, ...]


  # ============================================================================
  onHiventsChanged: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      unless @_hiventsChanged
        @_onHiventsChangedCallbacks.push callbackFunc
      else
        callbackFunc @_filteredHiventHandles

  # ============================================================================
  setTimeFilter: (timeFilter) ->
    @_currentTimeFilter = timeFilter
    @_filterHivents();

  # ============================================================================
  setSpaceFilter: (spaceFilter) ->
    @_currentSpaceFilter = spaceFilter
    @_filterHivents()

  # ============================================================================
  setCategoryFilter: (categoryFilter) ->
    @_currentCategoryFilter = categoryFilter
    @_filterHivents()

  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  _initHivents: (pathToHivents) ->
    $.getJSON(pathToHivents, (hivents) =>
      for h in hivents
        hivent = new HG.Hivent(
          h.name,
          h.startYear,
          h.startMonth,
          h.startDay,
          h.endYear,
          h.endMonth,
          h.endDay,
          h.displayDate,
          h.long,
          h.lat,
          h.category,
          h.content,
        )

        @_hiventHandles.push(new HG.HiventHandle hivent)

      @_hiventsChanged = true

      @_filterHivents();

    )

  ############################# MAIN FUNCTIONS #################################

  # ============================================================================
  _filterHivents: ->

    for handle in @_filteredHiventHandles
      handle.destroyAll()
      handle = null

    @_filteredHiventHandles = []

    for handle in @_hiventHandles
      hivent = handle.getHivent()
      isVisible = true

      if isVisible and @_currentCategoryFilter?
        isVisible = hivent.category in @_currentCategoryFilter

      if isVisible and @_currentTimeFilter?
        isVisible = not (hivent.startDate.getTime() > @_currentTimeFilter.end.getTime()) and
                    not (hivent.endDate.getTime() < @_currentTimeFilter.start.getTime())

      if isVisible and @_currentSpaceFilter?
        isVisible = hivent.lat >= @_currentSpaceFilter.min.lat and
                    hivent.long >= @_currentSpaceFilter.min.long and
                    hivent.lat <= @_currentSpaceFilter.max.lat and
                    hivent.long <= @_currentSpaceFilter.max.long

      if isVisible
        @_filteredHiventHandles.push(new HG.HiventHandle hivent)


    for callback in @_onHiventsChangedCallbacks
      callback @_filteredHiventHandles

