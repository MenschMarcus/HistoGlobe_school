window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (timeline) ->

    # HG.mixin @, HG.CallbackContainer
    # HG.CallbackContainer.call @

    # @addCallback "onShowArea"
    # @addCallback "onHideArea"

    # @_initMembers()

    # timeline.addListener this

  # ============================================================================
  nowChanged: (date) ->
    @_now = date
    for area in @_areas
      area.setDate date

  # ============================================================================
  periodChanged: (dateA, dateB) ->

  # ============================================================================
  categoryChanged: (c) ->


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initMembers: ->
    @_areas = []
    @_now = new Date(2000, 1, 1)

    @_loadJson "data/areas/countries.json"
    @_loadJson "data/areas/countries_old.json"

  # ============================================================================
  _loadJson: (file) ->
    $.getJSON file, (countries) =>
      for country in countries.features
        newArea = new HG.Area country

        newArea.onShow @, (area) =>
          @notifyAll "onShowArea", area

        newArea.onHide @, (area) =>
          @notifyAll "onHideArea", area

        @_areas.push newArea

        newArea.setDate @_now

