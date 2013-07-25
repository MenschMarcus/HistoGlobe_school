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


  # ============================================================================
  onHiventsChanged: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      unless @_hiventsChanged
        @_onHiventsChangedCallbacks.push callbackFunc
      else
        callbackFunc @_hiventHandles

  # ============================================================================
  setTimeFilter: (timeFilter) ->
    @_currentTimeFilter = timeFilter
    @_filterHivents();

  # ============================================================================
  setSpaceFilter: (spaceFilter) ->
    @_currentSpaceFilter = spaceFilter
    @_filterHivents()


  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  _initHivents: (pathToHivents) ->
    $.getJSON(pathToHivents, (hivents) =>
      for h in hivents
        hivent = new HG.Hivent(
          h.name,
          h.category,
          new Date(h.date),
          h.displayDate,
          h.long,
          h.lat,
          h.description,
          h.parties
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

    @_filteredHiventHandles = []

    for handle in @_hiventHandles
      hivent = handle.getHivent()
      isInTime = @_currentTimeFilter == null
      unless isInTime
        isInTime = hivent.date.getTime() >= @_currentTimeFilter.start.getTime() and
                   hivent.date.getTime() <= @_currentTimeFilter.end.getTime()

      isInSpace = @_currentSpaceFilter == null
      unless isInSpace
        isInSpace = hivent.lat >= @_currentSpaceFilter.min.lat and
                    hivent.long >= @_currentSpaceFilter.min.long and
                    hivent.lat <= @_currentSpaceFilter.max.lat and
                    hivent.long <= @_currentSpaceFilter.max.long

      if isInTime and isInSpace
        @_filteredHiventHandles.push(new HG.HiventHandle hivent)

    for callback in @_onHiventsChangedCallbacks
      callback @_filteredHiventHandles

