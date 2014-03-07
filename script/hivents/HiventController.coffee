#include Hivent.coffee
#include HiventHandle.coffee
#include HiventDatabaseInterface.coffee

window.HG ?= {}

class HG.HiventController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_hiventHandles = [];
    @_hiventsLoaded = false;
    @_onHiventAddedCallbacks = [];

    @_currentTimeFilter = null; # {start: <Date>, end: <Date>}
    @_currentSpaceFilter = null; # { min: {lat: <float>, long: <float>},
                                 #   max: {lat: <float>, long: <float>}}
    @_currentCategoryFilter = null; # [category_a, category_b, ...]

    defaultConfig =
      hiventJSONPaths: undefined
      multimediaJSONPaths: undefined
      hiventDSVPaths: undefined
      multimediaDSVPaths: undefined
      hiventServerName: undefined
      hiventDatabaseName: undefined
      hiventTableName: undefined
      multimediaServerName: undefined
      multimediaDatabaseName: undefined
      multimediaTableName: undefined

    conf = $.extend {}, defaultConfig, config

    if conf.hiventJSONPaths?
      @loadHiventsFromJSON conf
    else if conf.hiventConfig?.dsvPaths?
      @loadHiventsFromDSV conf
    else if conf.hiventServerName?
      @loadHiventsFromDatabase conf
    else
      console.error "Unable to load Hivents: No JSON path, DSV path or database specified!"


  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventController = @

    hgInstance.timeline.onIntervalChanged @, (timeFilter) =>
      @setTimeFilter timeFilter

  # ============================================================================
  onHiventAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onHiventAddedCallbacks.push callbackFunc

      if @_hiventsLoaded
        callbackFunc handle for handle in @_hiventHandles

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
  loadHiventsFromDatabase: (config) ->
    defaultConfig =
      hiventServerName: ""
      hiventDatabaseName: ""
      hiventTableName: ""
      multimediaServerName: ""
      multimediaDatabaseName: ""
      multimediaTableName: ""

    config = $.extend {}, defaultConfig, config

    dbInterface = new HG.HiventDatabaseInterface(config.hiventServerName, config.hiventDatabaseName)
    dbInterface.getHivents {
      tableName: config.hiventTableName,
      upperLimit: 100,
      success:
        (data) =>
          builder = new HG.HiventBuilder config
          rows = data.split "\n"
          for row in rows
            builder.constructHiventFromDBString row, (hivent) =>
              if hivent
                handle = new HG.HiventHandle hivent
                @_hiventHandles.push handle
                callback handle for callback in @_onHiventAddedCallbacks
                @_filterHivents()

          @_hiventsLoaded = true
    }

  # ============================================================================
  loadHiventsFromJSON: (config) ->
    defaultConfig =
      hiventJSONPaths: []
      multimediaJSONPaths: []

    config = $.extend {}, defaultConfig, config

    for hiventJSONPath in config.hiventJSONPaths
      $.getJSON(hiventJSONPath, (hivents) =>
        builder = new HG.HiventBuilder config
        for h in hivents
          builder.constructHiventFromJSON h, (hivent) =>
            if hivent
              handle = new HG.HiventHandle hivent
              @_hiventHandles.push handle
              callback handle for callback in @_onHiventAddedCallbacks
              @_filterHivents()

        @_hiventsLoaded = true
      )

  # ============================================================================
  loadHiventsFromDSV: (config) ->
    defaultConfig =
      hiventConfig:
        dsvPaths: []
        delimiter: "|"
        ignoredLines: [] # line indices starting at 1
        indexMappings: [
          hiventID          : 0
          hiventName        : 1
          hiventDescription : 2
          hiventStartDate   : 3
          hiventEndDate     : 4
          hiventDisplayDate : 5
          hiventLocation    : 6
          hiventLat         : 7
          hiventLong        : 8
          hiventCategory    : 9
          hiventMultimedia  : 10
        ]
      multimediaConfig:
        dsvPaths: []
        rootDirs: []
        delimiter: "|"
        ignoredLines: [] # line indices starting at 1
        indexMappings: [
          multimediaID          : 0
          multimediaType        : 1
          multimediaDescription : 2
          multimediaLink        : 3
        ]


    config = $.extend {}, defaultConfig, config
    config.hiventConfig = $.extend {}, defaultConfig.hiventConfig, config.hiventConfig
    config.multimediaConfig = $.extend {}, defaultConfig.multimediaConfig, config.multimediaConfig

    parse_config =
      delimiter: config.delimiter
      header: false

    pathIndex = 0
    for dsvPath in config.hiventConfig.dsvPaths
      $.get dsvPath,
        (data) =>
          parse_result = $.parse data, parse_config
          builder = new HG.HiventBuilder config
          for result, i in parse_result.results
            unless i+1 in config.hiventConfig.ignoredLines
              builder.constructHiventFromArray result, pathIndex, (hivent) =>
                if hivent
                  handle = new HG.HiventHandle hivent
                  @_hiventHandles.push handle
                  callback handle for callback in @_onHiventAddedCallbacks
                  @_filterHivents()
          pathIndex++

          @_hiventsLoaded = true




  # ============================================================================
  showVisibleHivents: ->
    for handle in @_hiventHandles
      hivent = handle.getHivent()
      isVisible = true

      if isVisible and @_currentCategoryFilter?
        isVisible = (hivent.category is "default") or (hivent.category in @_currentCategoryFilter)

      if isVisible and @_currentTimeFilter?
        isVisible = not (hivent.startDate.getTime() > @_currentTimeFilter.end.getTime()) and
                    not (hivent.endDate.getTime() < @_currentTimeFilter.start.getTime())

      '''if isVisible and @_currentSpaceFilter?
        isVisible = hivent.lat >= @_currentSpaceFilter.min.lat and
                    hivent.long >= @_currentSpaceFilter.min.long and
                    hivent.lat <= @_currentSpaceFilter.max.lat and
                    hivent.long <= @_currentSpaceFilter.max.long'''
      if isVisible
        handle.hideAll()
        handle.showAll()


  ############################# MAIN FUNCTIONS #################################

  # ============================================================================
  _filterHivents: ->

    for handle in @_hiventHandles
      hivent = handle.getHivent()
      isVisible = true

      if isVisible and @_currentCategoryFilter?
        isVisible = (hivent.category is "default") or (hivent.category in @_currentCategoryFilter)

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
        if @_currentTimeFilter?
          new_age = Math.min(1, (hivent.endDate.getTime() - @_currentTimeFilter.start.getTime()) / (@_currentTimeFilter.end.getTime() - @_currentTimeFilter.start.getTime()))
          if new_age isnt handle._age
            handle.setAge new_age

      else if handle._visible
        handle.hideAll()
