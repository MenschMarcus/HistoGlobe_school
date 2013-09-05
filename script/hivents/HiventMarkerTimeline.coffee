#include Extendable.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarkerTimeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################


  # ============================================================================
  constructor: (hiventHandle, parent, posX, posY) ->

    HG.mixin @, HG.HiventMarker
    HG.HiventMarker.call @, hiventHandle, parent

    HIVENT_MARKER_TIMELINE_COUNT++

    time = hiventHandle.getHivent().date.getTime()
    LAST_Y_COORDS[time] ?= 0
    @_position = { x: posX, y: Math.floor $(parent.parentNode).innerHeight() * 0.85 - LAST_Y_COORDS[time]}
    LAST_Y_COORDS[time] += 2 * HIVENT_MARKER_TIMELINE_RADIUS

    @_div = document.createElement "div"
    @_div.id = "hiventMarkerTimeline_" + HIVENT_MARKER_TIMELINE_COUNT
    @_div.style.position = "absolute"
    @_div.style.width  = 2 * HIVENT_MARKER_TIMELINE_RADIUS + "px"
    @_div.style.height = 2 * HIVENT_MARKER_TIMELINE_RADIUS + "px"
    @_div.style.borderRadius = HIVENT_MARKER_TIMELINE_RADIUS + "px"
    @_div.style.backgroundColor = HIVENT_DEFAULT_COLOR

    @_div.style.left = @_position.x + "px"
    @_div.style.top = @_position.y + "px"

    parent.appendChild @_div

    @_div.onmouseover = (e) =>
      pos = {
        x : @_position.x + HIVENT_MARKER_TIMELINE_RADIUS,
        y : @_position.y + 0.6 * HIVENT_MARKER_TIMELINE_RADIUS
      }
      @getHiventHandle().mark @, pos
      @getHiventHandle().linkAll pos

    @_div.onmouseout = (e) =>
      pos = {
        x : @_position.x + HIVENT_MARKER_TIMELINE_RADIUS,
        y : @_position.y + 0.6 * HIVENT_MARKER_TIMELINE_RADIUS
      }
      @getHiventHandle().unMark @, pos
      @getHiventHandle().unLinkAll pos

    @_div.onclick = (e) =>
      pos = {
        x : @_position.x + HIVENT_MARKER_TIMELINE_RADIUS,
        y : @_position.y + 0.6 * HIVENT_MARKER_TIMELINE_RADIUS
      }
      @getHiventHandle().focusAll pos

    @getHiventHandle().onMark @, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_HIGHLIGHT_COLOR

    @getHiventHandle().onUnMark @, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_DEFAULT_COLOR

    @getHiventHandle().onLink @, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_HIGHLIGHT_COLOR

    @getHiventHandle().onUnLink @, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_DEFAULT_COLOR

    @getHiventHandle().onDestruction @, @_destroy

    @enableShowName()

  # ============================================================================
  getPosition: ->
    return @_position

  # ============================================================================
  setPosition: (posX) ->
    @_position.x = posX
    @_div.style.left = @_position.x + "px"

  # ============================================================================
  hide: ->
    @_div.style.display = "none"

  # ============================================================================
  show: ->
    @_div.style.display = "block"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _setDivPos: (pos) ->
    @_div.style.left = pos.x + "px"
    @_div.style.top = pos.y + "px"

  # ============================================================================
  _destroy: =>
    LAST_Y_COORDS[@getHiventHandle().getHivent().date.getTime()] = 0
    $(@_div).remove()
    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  HIVENT_MARKER_TIMELINE_RADIUS = 4
  HIVENT_MARKER_TIMELINE_COUNT = 0
  HIVENT_DEFAULT_COLOR   = "#253563"
  HIVENT_HIGHLIGHT_COLOR = "#ff8800"

  LAST_Y_COORDS = {}
