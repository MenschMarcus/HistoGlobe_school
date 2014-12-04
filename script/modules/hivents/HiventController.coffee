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

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onHiventAdded"

    @_hiventHandles = []
    @_handlesNeedSorting = false

    @_currentTimeFilter = null # {start: <Date>, end: <Date>}
    @_currentSpaceFilter = null # { min: {lat: <float>, long: <float>},
                                 #   max: {lat: <float>, long: <float>}}
    @_currentCategoryFilter = null # [category_a, category_b, ...]
    @_categoryFilter = null

    defaultConfig =
      dsvConfigs: undefined
      numHiventsInView: 10

    @_config = $.extend {}, defaultConfig, config


  # ============================================================================
  hgInit: (hgInstance) ->
    @_hgInstance = hgInstance

    @_hgInstance.hiventController = @

    @_hgInstance.timeline.onIntervalChanged @, (timeFilter) =>
      @setTimeFilter timeFilter

    @_hgInstance.categoryFilter?.onFilterChanged @,(categoryFilter) =>
      @_currentCategoryFilter = categoryFilter
      @_filterHivents()
    @_hgInstance.categoryFilter?.onPrefixFilterChanged @,(categoryFilter) =>
      @_currentCategoryFilter = categoryFilter
      @_filterHivents()

    @_categoryFilter = hgInstance.categoryFilter if hgInstance.categoryFilter

    # @loadHiventsFromJSON()
    @loadHiventsFromDSV()
    # @loadHiventsFromDatabase()

  # ============================================================================
  getHivents: (object, callbackFunc) ->
    if object? and callbackFunc?
      @onHiventAdded object, callbackFunc

      for handle in @_hiventHandles
        @notify "onHiventAdded", object, handle

    @_hiventHandles

  # ============================================================================
  setTimeFilter: (timeFilter) ->
    @_currentTimeFilter = timeFilter
    @_filterHivents();

  # ============================================================================
  setSpaceFilter: (spaceFilter) ->
    @_currentSpaceFilter = spaceFilter
    @_filterHivents()

  '''# ============================================================================
  setCategoryFilter: (categoryFilter) ->
    @_currentCategoryFilter = categoryFilter
    @_filterHivents()'''

  # ============================================================================
  getHiventHandleById: (hiventId) ->
    for handle in @_hiventHandles
      if handle.getHivent().id is hiventId
        return handle
    console.log "A Hivent with the id \"#{hiventId}\" does not exist!"
    return null

  # ============================================================================
  getHiventHandleByIndex: (handleIndex) ->
    return @_hiventHandles[handleIndex]

  # ============================================================================

  getNextHiventHandle: (now, ignoredIds=[]) ->
    result = null
    distance = -1
    handles = @_hiventHandles
    handles= handles.concat(@_hgInstance.hiventGalleryWidget.getHiventHandles()) if @_hgInstance.hiventGalleryWidget

    for handle in handles
      if handle._state isnt 0 and not (handle.getHivent().id in ignoredIds)
        diff = handle.getHivent().startDate.getTime() - now.getTime()
        if (distance is -1 or diff < distance) and diff >= 0
          distance = diff
          result = handle
    return result

  # ============================================================================
  getPreviousHiventHandle: (now, ignoredIds=[]) ->
    result = null
    distance = -1
    handles = @_hiventHandles
    handles= handles.concat(@_hgInstance.hiventGalleryWidget.getHiventHandles()) if @_hgInstance.hiventGalleryWidget

    for handle in handles
      if handle._state isnt 0 and not (handle.getHivent().id in ignoredIds)
        diff = now.getTime() - handle.getHivent().startDate.getTime()
        if (distance is -1 or diff < distance) and diff >= 0
          distance = diff
          result = handle
    return result

  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  # loadHiventsFromDatabase: (config) ->
  #   defaultConfig =
  #     hiventServerName: ""
  #     hiventDatabaseName: ""
  #     hiventTableName: ""
  #     multimediaServerName: ""
  #     multimediaDatabaseName: ""
  #     multimediaTableName: ""

  #   config = $.extend {}, defaultConfig, config

  #   dbInterface = new HG.HiventDatabaseInterface(config.hiventServerName, config.hiventDatabaseName)
  #   dbInterface.getHivents {
  #     tableName: config.hiventTableName,
  #     upperLimit: 100,
  #     success:
  #       (data) =>
  #         builder = new HG.HiventBuilder config
  #         rows = data.split "\n"
  #         for row in rows
  #           builder.constructHiventFromDBString row, (hivent) =>
  #             if hivent
  #               handle = new HG.HiventHandle hivent
  #               @_hiventHandles.push handle
  #               callback handle for callback in @_onHiventAddedCallbacks
  #               @_filterHivents()

  #   }

  # ============================================================================
  # loadHiventsFromJSON: (config) ->
  #   defaultConfig =
  #     hiventJSONPaths: []
  #     multimediaJSONPaths: []

  #   config = $.extend {}, defaultConfig, config

  #   for hiventJSONPath in config.hiventJSONPaths
  #     $.getJSON(hiventJSONPath, (hivents) =>
  #       builder = new HG.HiventBuilder config
  #       for h in hivents
  #         builder.constructHiventFromJSON h, (hivent) =>
  #           if hivent
  #             handle = new HG.HiventHandle hivent
  #             @_hiventHandles.push handle
  #             callback handle for callback in @_onHiventAddedCallbacks
  #             @_filterHivents()

  #     )

  # ============================================================================
  loadHiventsFromDSV: () ->
    if @_config.dsvConfigs?
      for dsvConfig in @_config.dsvConfigs
        defaultConfig =
          path: ""
          delimiter: "|"
          ignoredLines: [] # line indices starting at 1
          indexMapping:
            id          : 0
            name        : 1
            description : 2
            startDate   : 3
            endDate     : 4
            displayDate : 5
            location    : 6
            lat         : 7
            long        : 8
            category    : 9
            multimedia  : 10
            # TODO: add link and region

        dsvConfig = $.extend {}, defaultConfig, dsvConfig

        parse_config =
          delimiter: dsvConfig.delimiter
          header: false

        buildHivent = (config) =>
          $.get config.path,
            (data) =>
              parse_result = $.parse data, parse_config
              builder = new HG.HiventBuilder config, @_hgInstance.multimediaController
              for result, i in parse_result.results
                unless i+1 in config.ignoredLines
                  builder.constructHiventFromArray result, (hivent) =>
                    if hivent
                      handle = new HG.HiventHandle hivent
                      @_hiventHandles.push handle
                      @notifyAll "onHiventAdded", handle
                      @_handlesNeedSorting = true
              @_filterHivents() # if in doubt, indent

        buildHivent dsvConfig

        @_currentCategoryFilter = @_categoryFilter.getCurrentFilter()


  # ============================================================================
  showVisibleHivents: ->
    for handle in @_hiventHandles

      state = handle._state

      if state isnt 0
        handle.setState 0
        handle.setState state


  ############################# MAIN FUNCTIONS #################################

  # ============================================================================
  _filterHivents: ->
    if @_handlesNeedSorting
      @_hiventHandles.sort (a, b) =>
        if a? and b?
          unless a.getHivent().startDate.getTime() is b.getHivent().startDate.getTime()
            return a.getHivent().startDate.getTime() - b.getHivent().startDate.getTime()
          else
            if a.getHivent().id > b.getHivent().id
              return 1
            else if a.getHivent().id < b.getHivent().id
              return -1
        return 0

    for handle, i in @_hiventHandles
      if @_handlesNeedSorting
        handle.sortingIndex = i
      hivent = handle.getHivent()

      state = 1
      # 0 --> invisible
      # 1 --> visiblePast
      # 2 --> visibleFuture

      if @_currentCategoryFilter?
        unless (@_currentCategoryFilter.length is 0) or (hivent.category is "default") or (hivent.category in @_currentCategoryFilter)
          state = 0

      if state isnt 0 and @_currentTimeFilter?
        # start date in visible future
        if hivent.startDate.getTime() > @_currentTimeFilter.now.getTime() and hivent.startDate.getTime() < @_currentTimeFilter.end.getTime()
          state = 2
        # completely  outside
        else if hivent.startDate.getTime() > @_currentTimeFilter.end.getTime() or hivent.endDate.getTime() < @_currentTimeFilter.start.getTime()
          state = 0

      if state isnt 0 and @_currentSpaceFilter?
        unless hivent.lat >= @_currentSpaceFilter.min.lat and
               hivent.long >= @_currentSpaceFilter.min.long and
               hivent.lat <= @_currentSpaceFilter.max.lat and
               hivent.long <= @_currentSpaceFilter.max.long
          state = 0

      handle._tmp_state = state

      if state isnt 0
        if @_currentTimeFilter?
          # half of timeline:
          #new_age = Math.min(1, (hivent.endDate.getTime() - @_currentTimeFilter.start.getTime()) / (@_currentTimeFilter.now.getTime() - @_currentTimeFilter.start.getTime()))
          # quarter of timeline:
          new_age = Math.min(1, ((hivent.endDate.getTime() - @_currentTimeFilter.start.getTime()) / (0.5*(@_currentTimeFilter.now.getTime() - @_currentTimeFilter.start.getTime())))-1)
          if new_age isnt handle._age
            handle.setAge new_age

    # importance filter: assign each hivent an importance score
    impScores = []
    for handle, i in @_hiventHandles

      # only for active hivents
      if handle._tmp_state > 0
        hivent = handle.getHivent()

        # 1) distance to now date
        nowTime = @_currentTimeFilter.now.getFullYear()
        hiventTime = (hivent.endDate.getFullYear() + hivent.startDate.getFullYear()) / 2
        nowDist = Math.abs(hiventTime - nowTime)

        # 2) importance category
        imp = hivent.isImp + 1

        # set importance and add in array
        impScore = nowDist * imp

        impScores.push
          handle: handle
          score:  impScore

    # sort hivents by score
    impScores.sort (a,b) =>
      return a.score - b.score

    # set hivents with highest X imp scores to visible, the other to invisible
    for score, i in impScores
      # get current visible state
      state = score.handle._tmp_state

      # if hivent is not one of the most X important ones, set it to invisible
      if i >= @_config.numHiventsInView
        state = 0
      # else: take the given state

      # finally set the visible state and tell everyone
      score.handle.setState state



    @_handlesNeedSorting = false
