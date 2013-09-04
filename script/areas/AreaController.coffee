window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (timeline) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onAreaChanged"

    @_initMembers()
    timeline.addListener this

  # ============================================================================
  getLayer: () ->
    @_layer

  # ============================================================================
  nowChanged: (date) ->
    @_layer.setDate date

  periodChanged: (dateA, dateB) ->

  categoryChanged: (c) ->


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initMembers: ->
    @_layer = new HG.AreaLayer()

    @_layer.onLoaded (layer) =>
      @notifyAll "onAreaChanged", layer
