window.HG ?= {}

class HG.PathController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (timeline, hiventController, map) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @_timeline = timeline
    @_hiventController = hiventController

    ##UGLY! PathController shouldn't know about map
    @_map = map

    @_initMembers()

    @_timeline.addListener @


  # ============================================================================
  nowChanged: (date) ->
    @_now = date
    @_filterPaths()
    for path in @_paths
      path.setDate date


  # ============================================================================
  periodChanged: (dateA, dateB) ->

  # ============================================================================
  categoryChanged: (c) ->

  # ============================================================================
  setCategoryFilter: (categoryFilter) ->
    @_currentCategoryFilter = categoryFilter
    @_filterPaths()

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initMembers: ->
    @_paths = []
    @_now = @_timeline.getNow()
    @_currentCategoryFilter = null

    @_hiventController.onHiventsLoaded @_loadJson

  # ============================================================================
  _loadJson: () =>
    $.getJSON "data/path_collection.json", (paths) =>
      for path in paths
        startHiventHandle = @_hiventController.getHiventHandleById path.startHivent
        endHiventHandle = @_hiventController.getHiventHandleById path.endHivent

        startHivent = startHiventHandle.getHivent()
        endHivent = endHiventHandle.getHivent()

        unless startHivent.endDate.getTime() is endHivent.startDate.getTime()

          newPath = null
          if path.type is "ARC_PATH"
            newPath = new HG.ArcPath2D startHiventHandle, endHiventHandle, path.category, @_map, "#000000", path.movingMarker, path.startMarker, path.endMarker, 0.2
          else if  path.type is "LINEAR_PATH"
            newPath = new HG.LinearPath2D startHiventHandle, endHiventHandle, path.category, @_map, "#000000"
          else
            console.error "Undefined path type \"#{path.type}\"!"

          if newPath?
            @_paths.push newPath

            newPath.setDate @_now

      @_filterPaths()

  # ============================================================================
  _filterPaths: ->
    for path in @_paths
      isVisible = true

      if isVisible and @_currentCategoryFilter?
        isVisible = path.category in @_currentCategoryFilter

      if isVisible and @_now?
        isVisible = path._startHiventHandle.getHivent().startDate < @_now

      if isVisible
        path.show(@_now)
      else if path.isVisible()
        path.hide()

