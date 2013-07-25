#include Extendable.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarkerTimeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################


  # ============================================================================
  constructor: (hivent, parent, posX, posY) ->

    HG.mixin @, HG.HiventMarker
    HG.HiventMarker.call this, hivent, parent

    HIVENT_MARKER_TIMELINE_COUNT++

    @_position = { x: posX, y: Math.floor $(parent.parentNode).innerHeight() * 0.85 }

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
      @getHiventHandle().mark this, pos
      @getHiventHandle().linkAll pos

    @_div.onmouseout = (e) =>
      pos = {
        x : @_position.x + HIVENT_MARKER_TIMELINE_RADIUS,
        y : @_position.y + 0.6 * HIVENT_MARKER_TIMELINE_RADIUS
      }
      @getHiventHandle().unMark this, pos
      @getHiventHandle().unLinkAll pos

    @_div.onclick = (e) =>
      pos = {
        x : @_position.x + HIVENT_MARKER_TIMELINE_RADIUS,
        y : @_position.y + 0.6 * HIVENT_MARKER_TIMELINE_RADIUS
      }
      @getHiventHandle().focusAll pos

    @getHiventHandle().onMark this, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_HIGHLIGHT_COLOR

    @getHiventHandle().onUnMark this, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_DEFAULT_COLOR

    @getHiventHandle().onLink this, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_HIGHLIGHT_COLOR

    @getHiventHandle().onUnLink this, (mousePos) =>
      @_div.style.backgroundColor = HIVENT_DEFAULT_COLOR

    @getHiventHandle().onDestruction this, @_destroy

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
    $(@_div).remove()
    delete this

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  HIVENT_MARKER_TIMELINE_RADIUS = 4
  HIVENT_MARKER_TIMELINE_COUNT = 0
  HIVENT_DEFAULT_COLOR   = "#253563"
  HIVENT_HIGHLIGHT_COLOR = "#ff8800"
