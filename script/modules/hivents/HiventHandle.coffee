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
    @_age = 0.0

    @_state = 0
    # 0 --> invisible
    # 1 --> visiblePast
    # 2 --> visibleFuture

    @sortingIndex = -1

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
    @addCallback "onAgeChanged"

    @addCallback "onVisiblePast"
    @addCallback "onVisibleFuture"
    @addCallback "onInvisible"

  # ============================================================================
  getHivent: ->
    @_hivent

  # ============================================================================
  activeAll: (mousePixelPosition) ->
    @_activated = true
    ACTIVE_HIVENTS.push(@)
    if @regionMarker?
      @regionMarker.makeVisible()
    @notifyAll "onActive", mousePixelPosition, @

  # ============================================================================
  active: (obj, mousePixelPosition) ->    
    @_activated = true
    ACTIVE_HIVENTS.push @
    if @regionMarker?
      @regionMarker.makeVisible()
    @notify "onActive", obj, mousePixelPosition, @

  # ============================================================================
  inActiveAll: (mousePixelPosition) ->
    @_activated = false
    index = $.inArray(@, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]
    if @regionMarker?
      @regionMarker.makeInvisible()
    @notifyAll "onInActive", mousePixelPosition, @

  # ============================================================================
  inActive: (obj, mousePixelPosition) ->
    @_activated = false
    index = $.inArray(@, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]
    if @regionMarker?
      @regionMarker.makeInvisible()
    @notify "onInActive", obj, mousePixelPosition, @

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
    window.hgInstance.hivent_list_module.hoverElement(@_hivent.id)
    unless @_linked
      @_linked = true
      @notifyAll "onLink", mousePixelPosition

  # ============================================================================
  link: (obj, mousePixelPosition) ->    
    window.hgInstance.hivent_list_module.hoverElement(@_hivent.id)
    unless @_linked
      @_linked = true
      @notify "onLink", obj, mousePixelPosition

  # ============================================================================
  unLinkAll: (mousePixelPosition) ->
    window.hgInstance.hivent_list_module.dehoverElement(@_hivent.id)
    if @_linked
      @_linked = false
      @notifyAll "onUnLink", mousePixelPosition

  # ============================================================================
  unLink: (obj, mousePixelPosition) ->
    window.hgInstance.hivent_list_module.dehoverElement(@_hivent.id)
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
    @notifyAll "onDestruction"
    @_destroy()

  # ============================================================================
  destroy: (obj) ->
    @notify "onDestruction", obj
    @_destroy()

  # # ============================================================================
  # show: (obj) ->
  #   @_visible = true
  #   @notify "onShow", obj, @

  # # ============================================================================
  # showAll: () ->
  #   @_visible = true
  #   @notifyAll "onShow", @

  # # ============================================================================
  # hide: (obj) ->
  #   @_visible = false
  #   @notify "onHide", obj, @

  # # ============================================================================
  # hideAll: () ->
  #   @_visible = false
  #   @notifyAll "onHide", @

  # ============================================================================
  setState: (state) ->
    if @_state isnt state

      if state is 0
        @notifyAll "onInvisible", @, @_state
      else if state is 1
        @notifyAll "onVisiblePast", @, @_state
      else if state is 2
        @notifyAll "onVisibleFuture", @, @_state
      else
        console.warn "Failed to set HiventHandle state: invalid state #{state}!"

      @_state = state

  # ============================================================================
  setAge: (age) ->
    if @_age isnt age
      @_age = age
      @notifyAll "onAgeChanged", age, @

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

  @DEACTIVATE_ALL_OTHER_HIVENTS: (handle)->

    for hivent in ACTIVE_HIVENTS
      unless hivent is handle
        hivent?.inActiveAll {x:0, y:0}

    ACTIVE_HIVENTS = $.grep ACTIVE_HIVENTS, (value) ->
      return value == handle
