window.HG ?= {}

class HG.HiventTooltips

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    @_hiventsOnTimeline = null
    @_hiventsOnMap = null

  # ============================================================================
  hgInit: (hgInstance) ->
    @_hiventsOnTimeline = hgInstance.hiventsOnTimeline
    @_hiventsOnMap = hgInstance.hiventsOnMap

    if @_hiventsOnTimeline
      @_hiventsOnTimeline.onMarkerAdded (marker) =>
        if marker.parentDiv
          @_addTooltip marker

    if @_hiventsOnMap
      @_hiventsOnMap.onMarkerAdded (marker) =>
        if marker.parentDiv
          @_addTooltip marker

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################
  _addTooltip: (marker) =>
    hiventInfo = document.createElement("div")
    hiventInfo.class = "btn btn-default"
    hiventInfo.style.position = "absolute"
    hiventInfo.style.left = "0px"
    hiventInfo.style.top = "0px"
    hiventInfo.style.visibility = "hidden"
    hiventInfo.style.pointerEvents = "none"

    marker.parentDiv.appendChild hiventInfo

    handle = marker.getHiventHandle()
    hivent = handle.getHivent()
    $(hiventInfo).tooltip {title: "#{hivent.displayDate}<br />#{hivent.name}", html:true, placement: "top", container:"body"}

    showTooltip = (displayPosition) =>
      hiventInfo.style.left = displayPosition.x + "px"
      hiventInfo.style.top = displayPosition.y + 5 + "px"
      $(hiventInfo).tooltip "show"

    hideTooltip = (displayPosition) =>
      $(hiventInfo).tooltip "hide"

    handle.onMark marker, showTooltip
    handle.onUnMark marker, hideTooltip
    handle.onActive marker, hideTooltip
    marker.onDestruction @, () =>
      hiventInfo.parentNode.removeChild hiventInfo

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

