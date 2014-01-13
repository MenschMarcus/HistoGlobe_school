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

    @_hiventController = hiventController

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

    @_loadJson "data/path_collection.json"

  # ============================================================================
  _loadJson: (file) ->
    $.getJSON file, (paths) =>
      for path in paths
        startHiventHandle = @_hiventController.getHiventHandleById path.startHivent
        endHiventHandle = @_hiventController.getHiventHandleById path.endHivent

        newPath = null
        # if path.type is "arcPath"
        #   newPath = new HG.ArcPath2D startHiventHandle, endHiventHandle
        # else if  path.type is  "linearPath"
        #   newPath = new HG.LinearPath2D startHiventHandle, endHiventHandle
        # else
        #   console.error "Undefined path type \"#{path.type}\"!"

        if newPath?
          @_paths.push newPath

          newPath.setDate @_now


