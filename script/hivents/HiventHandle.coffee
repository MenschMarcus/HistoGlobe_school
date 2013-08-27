#include Hivent.coffee
#include Mixin.coffee
#include CallbackContainer.coffee

window.HG ?= {}

class HG.HiventHandle

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hivent) ->

    @_hivent = hivent

    @_activated = false
    @_marked = false
    @_linked = false
    @_focussed = false

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onActive"
    @addCallback "onInActive"
    @addCallback "onMark"
    @addCallback "onUnMark"
    @addCallback "onLink"
    @addCallback "onUnLink"
    @addCallback "onFocus"
    @addCallback "onUnFocus"
    @addCallback "onDestruction"

  # ============================================================================
  getHivent: ->
    @_hivent

  # ============================================================================
  activeAll: (mousePixelPosition) ->
    @_activated = true
    ACTIVE_HIVENTS.push(@)
    @notifyAll "onActive", mousePixelPosition

  # ============================================================================
  active: (obj, mousePixelPosition) ->
    @_activated = true
    ACTIVE_HIVENTS.push @
    @notify "onActive", obj, mousePixelPosition

  # ============================================================================
  inActiveAll: (mousePixelPosition) ->
    @_activated = false
    index = $.inArray(@, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]

    @notifyAll "onInActive", mousePixelPosition

  # ============================================================================
  inActive: (obj, mousePixelPosition) ->
    @_activated = false
    index = $.inArray(@, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]

    @notify "onInActive", obj, mousePixelPosition

  # ============================================================================
  toggleActiveAll: (mousePixelPosition) ->
    @_activated = not @_activated
    if @_activated
      @activeAll mousePixelPosition
    else
      @inActiveAll mousePixelPosition

  # ============================================================================
  toggleActive: (obj, mousePixelPosition) ->
    @_activated = not @_activated
    if @_activated
      @active obj, mousePixelPosition
    else
      @inActive obj, mousePixelPosition

  # ============================================================================
  markAll: (mousePixelPosition) ->
    unless @_marked
      @_marked = true
      @notifyAll "onMark", mousePixelPosition

  # ============================================================================
  mark: (obj, mousePixelPosition) ->
    unless @_marked
      @_marked = true
      @notify "onMark", obj, mousePixelPosition

  # ============================================================================
  unMarkAll: (mousePixelPosition) ->
    if @_marked
      @_marked = false
      @notifyAll "onUnMark", mousePixelPosition

  # ============================================================================
  unMark: (obj, mousePixelPosition) ->
    if @_marked
      @_marked = false
      @notify "onUnMark", obj, mousePixelPosition

  # ============================================================================
  linkAll: (mousePixelPosition) ->
    unless @_linked
      @_linked = true
      @notifyAll "onLink", mousePixelPosition

  # ============================================================================
  link: (obj, mousePixelPosition) ->
    unless @_linked
      @_linked = true
      @notify "onLink", obj, mousePixelPosition

  # ============================================================================
  unLinkAll: (mousePixelPosition) ->
    if @_linked
      @_linked = false
      @notifyAll "onUnLink", mousePixelPosition

  # ============================================================================
  unLink: (obj, mousePixelPosition) ->
    if @_linked
      @_linked = false
      @notify "onUnLink", obj, mousePixelPosition

  # ============================================================================
  focusAll: (mousePixelPosition) ->
    @_focussed = true

    @notifyAll "onFocus", mousePixelPosition

  # ============================================================================
  focus: (obj, mousePixelPosition) ->
    @_focussed = true
    @notify "onFocus", obj, mousePixelPosition

  # ============================================================================
  unFocusAll: (mousePixelPosition) ->
    @_focussed = false

    @notifyAll "onUnFocus", mousePixelPosition

  # ============================================================================
  unFocus: (obj, mousePixelPosition) ->
    @_focussed = false
    @notify "onUnFocus", obj, mousePixelPosition

  # ============================================================================
  destroyAll: ->
    @notifyAll "onDestruction", mousePixelPosition
    @_destroy()

  # ============================================================================
  destroy: (obj) ->
    @notify "onDestruction", obj, mousePixelPosition

    @_destroy()

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _destroy: ->
    @_onActiveCallbacks = []
    @_onInActiveCallbacks = []
    @_onMarkCallbacks = []
    @_onUnMarkCallbacks = []
    @_onLinkCallbacks = []
    @_onUnLinkCallbacks = []
    @_onUnFocusCallbacks = []
    @_onFocusCallbacks = []
    @_onUnFocusCallbacks = []

    @_onDestructionCallbacks = []

    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################
  ACTIVE_HIVENTS = []

  @DEACTIVATE_ALL_HIVENTS: ->

    for hivent in ACTIVE_HIVENTS
      hivent?.inActiveAll {x:0, y:0}

    ACTIVE_HIVENTS = []