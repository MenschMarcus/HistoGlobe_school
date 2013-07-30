#include Hivent.coffee

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

    HG.addCallback @, "onActive"
    HG.addCallback @, "onInActive"
    HG.addCallback @, "onMark"
    HG.addCallback @, "onUnMark"
    HG.addCallback @, "onLink"
    HG.addCallback @, "onUnLink"
    HG.addCallback @, "onFocus"
    HG.addCallback @, "onUnFocus"
    HG.addCallback @, "onDestruction"

  # ============================================================================
  getHivent: ->
    @_hivent

  # ============================================================================
  activeAll: (mousePixelPosition) ->
    @_activated = true
    ACTIVE_HIVENTS.push(@)
    HG.notifyAll @, "onActive", mousePixelPosition

  # ============================================================================
  active: (obj, mousePixelPosition) ->
    @_activated = true
    ACTIVE_HIVENTS.push @
    HG.notify @, "onActive", obj, mousePixelPosition

  # ============================================================================
  inActiveAll: (mousePixelPosition) ->
    @_activated = false
    index = $.inArray(@, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]

    HG.notifyAll @, "onInActive", mousePixelPosition

  # ============================================================================
  inActive: (obj, mousePixelPosition) ->
    @_activated = false
    index = $.inArray(@, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]

    HG.notify @, "onInActive", obj, mousePixelPosition

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
      HG.notifyAll @, "onMark", mousePixelPosition

  # ============================================================================
  mark: (obj, mousePixelPosition) ->
    unless @_marked
      @_marked = true
      HG.notify @, "onMark", obj, mousePixelPosition

  # ============================================================================
  unMarkAll: (mousePixelPosition) ->
    if @_marked
      @_marked = false
      HG.notifyAll @, "onUnMark", mousePixelPosition

  # ============================================================================
  unMark: (obj, mousePixelPosition) ->
    if @_marked
      @_marked = false
      HG.notify @, "onUnMark", obj, mousePixelPosition

  # ============================================================================
  linkAll: (mousePixelPosition) ->
    unless @_linked
      @_linked = true
      HG.notifyAll @, "onLink", mousePixelPosition

  # ============================================================================
  link: (obj, mousePixelPosition) ->
    unless @_linked
      @_linked = true
      HG.notify @, "onLink", obj, mousePixelPosition

  # ============================================================================
  unLinkAll: (mousePixelPosition) ->
    if @_linked
      @_linked = false
      HG.notifyAll @, "onUnLink", mousePixelPosition

  # ============================================================================
  unLink: (obj, mousePixelPosition) ->
    if @_linked
      @_linked = false
      HG.notify @, "onUnLink", obj, mousePixelPosition

  # ============================================================================
  focusAll: (mousePixelPosition) ->
    @_focussed = true

    HG.notifyAll @, "onFocus", mousePixelPosition

  # ============================================================================
  focus: (obj, mousePixelPosition) ->
    @_focussed = true
    HG.notify @, "onFocus", obj, mousePixelPosition

  # ============================================================================
  unFocusAll: (mousePixelPosition) ->
    @_focussed = false

    HG.notifyAll @, "onUnFocus", mousePixelPosition

  # ============================================================================
  unFocus: (obj, mousePixelPosition) ->
    @_focussed = false
    HG.notify @, "onUnFocus", obj, mousePixelPosition

  # ============================================================================
  destroyAll: ->
    HG.notifyAll @, "onDestruction", mousePixelPosition
    @_destroy()

  # ============================================================================
  destroy: (obj) ->
    HG.notify @, "onDestruction", obj, mousePixelPosition

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
