window.HG ?= {}

class HG.PathController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (timeline, hiventController) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @_initMembers()

    timeline.addListener @

  # ============================================================================
  nowChanged: (date) ->
    @_now = date
    for path in @_paths
      path.setDate date

  # ============================================================================
  periodChanged: (dateA, dateB) ->

  # ============================================================================
  categoryChanged: (c) ->


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initMembers: ->
    @_paths = []
    @_now = new Date(2000, 1, 1)

    @_loadJson "data/paths/path_collection.json"

  # ============================================================================
  _loadJson: (file) ->
    $.getJSON file, (paths) =>
      for path in paths
        if path.type is "arcPath"
          newPath = new HG.ArcPath2D()
          @_paths.push newPath

          newPath.setDate @_now

