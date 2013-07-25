#include HiventHandle.coffee

window.HG ?= {}

class HG.HiventMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, parent) ->

    @_hiventHandle = hiventHandle
    @_hiventHandle.onDestruction this, @_destroy
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

    hiventContent = "<p align=\"right\">" + hivent.displayDate + "</p>" + hivent.description

    $(@_hiventInfo).popover {title: hivent.name, placement: "top", html: "true", content: hiventContent}

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
    @_hiventInfo.style.left = displayPosition.x + "px"
    @_hiventInfo.style.top = displayPosition.y + "px"
    $(@_hiventInfo).popover "show"
    $(@_hiventInfo).tooltip "hide"

  # ============================================================================
  hideHiventInfo: (displayPosition) =>
    $(@_hiventInfo).popover "hide"

  # ============================================================================
  enableShowName: ->
    @_hiventHandle.onMark(this, @showHiventName)
    @_hiventHandle.onUnMark(this, @hideHiventName)

  # ============================================================================
  enableShowInfo: ->
    @_hiventHandle.onActive(this, @showHiventInfo)
    @_hiventHandle.onInActive(this, @hideHiventInfo)


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _destroy: =>
    delete this
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  HIVENT_INFO_COUNT = 0
