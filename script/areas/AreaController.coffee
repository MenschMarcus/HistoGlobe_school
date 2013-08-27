window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (timeline) ->
    @_initMembers()

    timeline.addListener this

  # ============================================================================
  getLayer: () ->
    @_layer

  # ============================================================================
  onAreaChanged: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onAreaChangedCallbacks.push callbackFunc

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
    @_onAreaChangedCallbacks = [];
    @_layer = new HG.AreaLayer()

    @_layer.onLoaded (layer) =>
      for callback in @_onAreaChangedCallbacks
        callback layer
