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

    @_onActiveCallbacks = []
    @_onInActiveCallbacks = []
    @_onMarkCallbacks = []
    @_onUnMarkCallbacks = []
    @_onLinkCallbacks = []
    @_onUnLinkCallbacks = []
    @_onUnFocusCallbacks = []
    @_onFocusCallbacks = []
    @_onDestructionCallbacks = []

  # ============================================================================
  getHivent: ->
    @_hivent

  # ============================================================================
  activeAll: (mousePixelPosition) ->
    @_activated = true
    ACTIVE_HIVENTS.push(this)
    for i in [0...@_onActiveCallbacks.length]
      for j in [0...@_onActiveCallbacks[i][1].length]
        @_onActiveCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  active: (obj, mousePixelPosition) ->
    @_activated = true
    ACTIVE_HIVENTS.push this
    for i in [0...@_onActiveCallbacks.length]
      if @_onActiveCallbacks[i][0] == obj
        for j in [0...@_onActiveCallbacks[i][1].length]
          @_onActiveCallbacks[i][1][j] mousePixelPosition
        break

  # ============================================================================
  inActiveAll: (mousePixelPosition) ->
    @_activated = false
    index = $.inArray(this, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]

    for i in [0...@_onInActiveCallbacks.length]
      for j in [0...@_onInActiveCallbacks[i][1].length]
        @_onInActiveCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  inActive: (obj, mousePixelPosition) ->
    @_activated = false
    index = $.inArray(this, ACTIVE_HIVENTS)
    if index >= 0 then delete ACTIVE_HIVENTS[index]

    for i in [0...@_onInActiveCallbacks.length]
      if @_onInActiveCallbacks[i][0] == obj
        for j in [0...@_onInActiveCallbacks[i][1].length]
          @_onInActiveCallbacks[i][1][j] mousePixelPosition
        break

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
      for i in [0...@_onMarkCallbacks.length]
        for j in [0...@_onMarkCallbacks[i][1].length]
          @_onMarkCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  mark: (obj, mousePixelPosition) ->
    unless @_marked
      @_marked = true
      for i in [0...@_onMarkCallbacks.length]
        if @_onMarkCallbacks[i][0] == obj
          for j in [0...@_onMarkCallbacks[i][1].length]
            @_onMarkCallbacks[i][1][j] mousePixelPosition
          break

  # ============================================================================
  unMarkAll: (mousePixelPosition) ->
    if @_marked
      @_marked = false
      for i in [0...@_onUnMarkCallbacks.length]
        for j in [0...@_onUnMarkCallbacks[i][1].length]
          @_onUnMarkCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  unMark: (obj, mousePixelPosition) ->
    if @_marked
      @_marked = false
      for i in [0...@_onUnMarkCallbacks.length]
        if @_onUnMarkCallbacks[i][0] == obj
          for j in [0...@_onUnMarkCallbacks[i][1].length]
            @_onUnMarkCallbacks[i][1][j] mousePixelPosition
          break

  # ============================================================================
  linkAll: (mousePixelPosition) ->
    unless @_linked
      @_linked = true
      for i in [0...@_onLinkCallbacks.length]
        for j in [0...@_onLinkCallbacks[i][1].length]
          @_onLinkCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  link: (obj, mousePixelPosition) ->
    unless @_linked
      @_linked = true
      for i in [0...@_onLinkCallbacks.length]
        if @_onLinkCallbacks[i][0] == obj
          for j in [0...@_onLinkCallbacks[i][1].length]
            @_onLinkCallbacks[i][1][j] mousePixelPosition
          break

  # ============================================================================
  unLinkAll: (mousePixelPosition) ->
    if @_linked
      @_linked = false
      for i in [0...@_onUnLinkCallbacks.length]
        for j in [0...@_onUnLinkCallbacks[i][1].length]
          @_onUnLinkCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  unLink: (obj, mousePixelPosition) ->
    if @_linked
      @_linked = false
      for i in [0...@_onUnLinkCallbacks.length]
        if @_onUnLinkCallbacks[i][0] == obj
          for j in [0...@_onUnLinkCallbacks[i][1].length]
            @_onUnLinkCallbacks[i][1][j] mousePixelPosition
          break

  # ============================================================================
  focusAll: (mousePixelPosition) ->
    @_focussed = true

    for i in [0...@_onFocusCallbacks.length]
      for j in [0...@_onFocusCallbacks[i][1].length]
        @_onFocusCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  focus: (obj, mousePixelPosition) ->
    @_focussed = true
    for i in [0...@_onFocusCallbacks.length]
      if @_onFocusCallbacks[i][0] == obj
        for j in [0...@_onFocusCallbacks[i][1].length]
          @_onFocusCallbacks[i][1][j] mousePixelPosition
      break

  # ============================================================================
  unFocusAll: (mousePixelPosition) ->
    @_focussed = false

    for i in [0...@_onUnFocusCallbacks.length]
      for j in [0...@_onUnFocusCallbacks[i][1].length]
       @_onUnFocusCallbacks[i][1][j] mousePixelPosition

  # ============================================================================
  unFocus: (obj, mousePixelPosition) ->
    @_focussed = false
    for i in [0...@_onUnFocusCallbacks.length]
      if @_onUnFocusCallbacks[i][0] == obj
        for j in [0...@_onUnFocusCallbacks[i][1].length]
          @_onUnFocusCallbacks[i][1][j] mousePixelPosition
      break

  # ============================================================================
  destroyAll: ->
    for i in [0...@_onDestructionCallbacks.length]
      for j in [0...@_onDestructionCallbacks[i][1].length]
        @_onDestructionCallbacks[i][1][j]()
    @_destroy()

  # ============================================================================
  destroy: (obj) ->
    for i in [0...@_onDestructionCallbacks.length]
      if @_onDestructionCallbacks[i][0] == obj
        for j in [0...@_onDestructionCallbacks[i][1].length]
          @_onDestructionCallbacks[i][1][j]()
        break

    @_destroy()

  # ============================================================================
  onActive: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onActiveCallbacks.length]
        if @_onActiveCallbacks[i][0] == obj
          @_onActiveCallbacks[i][1].push callbackFunc
          return

      @_onActiveCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onInActive: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onInActiveCallbacks.length]
        if @_onInActiveCallbacks[i][0] == obj
          @_onInActiveCallbacks[i][1].push callbackFunc
          return

      @_onInActiveCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onMark: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onMarkCallbacks.length]
        if @_onMarkCallbacks[i][0] == obj
          @_onMarkCallbacks[i][1].push callbackFunc
          return

      @_onMarkCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onUnMark: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onUnMarkCallbacks.length]
        if @_onUnMarkCallbacks[i][0] == obj
          @_onUnMarkCallbacks[i][1].push callbackFunc
          return

      @_onUnMarkCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onLink: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onLinkCallbacks.length]
        if @_onLinkCallbacks[i][0] == obj
          @_onLinkCallbacks[i][1].push callbackFunc
          return
      @_onLinkCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onUnLink: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onUnLinkCallbacks.length]
        if @_onUnLinkCallbacks[i][0] == obj
          @_onUnLinkCallbacks[i][1].push callbackFunc
          return

      @_onUnLinkCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onFocus: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onFocusCallbacks.length]
        if @_onFocusCallbacks[i][0] == obj
          @_onFocusCallbacks[i][1].push callbackFunc
          return

      @_onFocusCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onUnFocus: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onUnFocusCallbacks.length]
        if @_onUnFocusCallbacks[i][0] == obj
          @_onUnFocusCallbacks[i][1].push callbackFunc
          return

      @_onUnFocusCallbacks.push [obj, [callbackFunc]]

  # ============================================================================
  onDestruction: (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...@_onDestructionCallbacks.length]
        if @_onDestructionCallbacks[i][0] == obj
          @_onDestructionCallbacks[i][1].push callbackFunc
          return

      @_onDestructionCallbacks.push [obj, [callbackFunc]]

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

    delete this
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################
  ACTIVE_HIVENTS = []

  @DEACTIVATE_ALL_HIVENTS: ->

    for hivent in ACTIVE_HIVENTS
      hivent?.inActiveAll {x:0, y:0}

    ACTIVE_HIVENTS = []
