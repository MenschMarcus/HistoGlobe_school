#include Hivent.coffee
#include HiventHandle.coffee
#include HiventDatabaseInterface.coffee

window.HG ?= {}

class HG.HiventController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    # @_loadHivents(pathToHivents)
    @_hiventHandles = [];
    @_hiventsLoaded = false;
    @_onHiventAddedCallbacks = [];

    @_currentTimeFilter = null; # {start: <Date>, end: <Date>}
    @_currentSpaceFilter = null; # { min: {lat: <float>, long: <float>},
                                 #   max: {lat: <float>, long: <float>}}
    @_currentCategoryFilter = null; # [category_a, category_b, ...]


  # ============================================================================
  onHiventAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onHiventAddedCallbacks.push callbackFunc

      if @_hiventsLoaded
        callbackFunc @_hiventHandles

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

  getHiventHandleById: (hiventId) ->
    for handle in @_hiventHandles
      if handle.getHivent().id is hiventId
        return handle
    console.log "An Hivent with the id \"#{hiventId}\" does not exist!"
    return null

  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  # config =
  #   hiventServerName: string -- name of the server
  #   hiventDatabaseName: string -- name of the database
  #   hiventTableName: string -- name of the table
  #   multimediaServerName: string -- name of the server
  #   multimediaDatabaseName: string -- name of the database
  #   multimediaTableName: string -- name of the table

  loadHivents: (config) ->
    dbInterface = new HG.HiventDatabaseInterface(config.hiventServerName, config.hiventDatabaseName)
    dbInterface.getHivents {
      tableName: config.hiventTableName,
      upperLimit: 100,
      success:
        (data) =>
          builder = new HG.HiventBuilder(config)
          rows = data.split "\n"
          for row in rows
            builder.constructHiventFromDBString row, (hivent) =>
              handle = new HG.HiventHandle hivent
              @_hiventHandles.push handle
              callback handle for callback in @_onHiventAddedCallbacks
              @_filterHivents();
    }


  ############################# MAIN FUNCTIONS #################################

  # ============================================================================
  _filterHivents: ->

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
        unless handle._visible
          handle.showAll()
      else if handle._visible
        handle.hideAll()
