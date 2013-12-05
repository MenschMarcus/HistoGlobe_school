#include Extendable.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarkerTimeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################


  # ============================================================================
  constructor: (timeline, hiventHandle, parent, posX, posY) ->

    HG.mixin @, HG.HiventMarker
    HG.HiventMarker.call @, hiventHandle, parent

    @_timeline = timeline

    time = hiventHandle.getHivent().startDate.getTime()
    LAST_X_COORDS[time] ?= 0
    @_position = { x: posX + LAST_X_COORDS[time] - HIVENT_MARKER_TIMELINE_RADIUS, y: Math.floor $(parent.parentNode).innerHeight() * 0.65 }
    LAST_X_COORDS[time] += HIVENT_MARKER_TIMELINE_RADIUS * 1.5

    @_classDefault     = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_default"
    @_classHighlighted = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_highlighted"

    @_div = document.createElement "div"
    @_div.setAttribute "class", @_classDefault

    @_div.style.left = @_position.x + "px"
    @_div.style.top = @_position.y + "px"

    @_div.style.zIndex = 5

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
      @_div.setAttribute "class", @_classHighlighted

    @getHiventHandle().onUnMark @, (mousePos) =>
      @_div.setAttribute "class", @_classDefault

    @getHiventHandle().onLink @, (mousePos) =>
      @_div.setAttribute "class", @_classHighlighted

    @getHiventHandle().onUnLink @, (mousePos) =>
      @_div.setAttribute "class", @_classDefault

    @getHiventHandle().onDestruction @, @_destroy
    @getHiventHandle().onHide @, @_destroy

    @enableShowName()
    @_timeline.addListener @

  # ============================================================================
  nowChanged: (date) ->

  # ============================================================================
  periodChanged: (dateA, dateB) ->
    posX = @_timeline.dateToPos @_hiventHandle.getHivent().startDate
    @setPosition posX

  # ============================================================================
  categoryChanged: (c) ->

  # ============================================================================
  getPosition: ->
    return @_position

  # ============================================================================
  setPosition: (posX) =>
    @_position.x = posX #+ LAST_X_COORDS[@getHiventHandle().getHivent().startDate.getTime()]
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
    LAST_X_COORDS[@getHiventHandle().getHivent().startDate.getTime()] = 0
    @getHiventHandle().unMarkAll()
    @getHiventHandle().unLinkAll()
    @_div.parentNode.removeChild @_div
    @_hiventHandle.removeListener "onHide", @
    @_hiventHandle.removeListener "onDestruction", @
    @_destroyMarker()
    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  HIVENT_MARKER_TIMELINE_RADIUS = 9

  LAST_X_COORDS = {}
