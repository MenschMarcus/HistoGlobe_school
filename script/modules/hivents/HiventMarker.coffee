#include HiventHandle.coffee

window.HG ?= {}

class HG.HiventMarker
 
  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, parentDiv) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onPositionChanged"
    @addCallback "onDestruction"

    @parentDiv = parentDiv

    @_hiventHandle = hiventHandle

  hgInit: (hgInstance) ->
    @_hgInstance = hgInstance

  # ============================================================================
  getHiventHandle: ->
    @_hiventHandle

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _destroy: =>
    @notifyAll "onDestruction"
    @_hiventHandle.inActiveAll()

