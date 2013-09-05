#include HiventHandle.coffee

window.HG ?= {}

class HG.HiventMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, parent) ->

    @_hiventHandle = hiventHandle
    @_hiventHandle.onDestruction @, @_destroyMarker
    @_hiventInfo = document.createElement("div")
    @_hiventInfo.class = "btn"
    @_hiventInfo.id = "@_hiventInfo_" + HIVENT_INFO_COUNT
    @_hiventInfo.style.position = "absolute"
    @_hiventInfo.style.left = "0px"
    @_hiventInfo.style.top = "0px"
    @_hiventInfo.style.visibility = "hidden"
    @_hiventInfo.style.pointerEvents = "none"

    if parent
      parent.appendChild @_hiventInfo

    hivent = @_hiventHandle.getHivent()

    $(@_hiventInfo).tooltip {title: hivent.name, placement: "top"}

    @_popover = null

    HIVENT_INFO_COUNT++

  # ============================================================================
  getHiventHandle: ->
    @_hiventHandle

  # ============================================================================
  showHiventName: (displayPosition) =>
    @_hiventInfo.style.left = displayPosition.x + "px"
    @_hiventInfo.style.top = displayPosition.y + "px"
    $(@_hiventInfo).tooltip "show"

  # ============================================================================
  hideHiventName: (displayPosition) =>
    $(@_hiventInfo).tooltip "hide"

  # ============================================================================
  showHiventInfo: (displayPosition) =>
    @_popover ?= new HG.HiventInfoPopover(@_hiventHandle.getHivent(), new HG.Vector(0, 0), document.getElementsByTagName("body")[0])
    @_hiventInfo.style.left = displayPosition.x + "px"
    @_hiventInfo.style.top = displayPosition.y + "px"
    @_updatePopoverAnchor displayPosition
    @_popover.positionWindowAtAnchor()
    @_popover.show()
    $(@_hiventInfo).tooltip "hide"

  # ============================================================================
  hideHiventInfo: (displayPosition) =>
    @_popover?.hide()

  # ============================================================================
  enableShowName: ->
    @_hiventHandle.onMark(@, @showHiventName)
    @_hiventHandle.onUnMark(@, @hideHiventName)

  # ============================================================================
  enableShowInfo: ->
    @_hiventHandle.onActive(@, @showHiventInfo)
    @_hiventHandle.onInActive(@, @hideHiventInfo)


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _updatePopoverAnchor: (position)->
    @_popover?.setAnchor new HG.Vector(position.x, position.y)

  # ============================================================================
  _destroyMarker: =>
    # delete @_hiventHandle
    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  HIVENT_INFO_COUNT = 0
