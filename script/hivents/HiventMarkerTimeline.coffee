#include Extendable.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarkerTimeline extends HG.HiventMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################


  # ============================================================================
  constructor: (timeline, hiventHandle, parent, posX) ->

    HG.HiventMarker.call @, hiventHandle, parent

    @_timeline = timeline

    time = hiventHandle.getHivent().startDate.getTime()

    spacing = 10
    Y_OFFSETS[time] ?= 0
    @_xOffset = Y_OFFSETS[time]
    @_position = { x: posX, y: HGConfig.timeline_height.val - HGConfig.hivent_marker_timeline_height.val - @_xOffset*spacing - HGConfig.border_width.val }
    Y_OFFSETS[time] += 1

    @_classDefault     = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_default"
    @_classHighlighted = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_highlighted"

    @_div = document.createElement "div"
    @_div.setAttribute "class", @_classDefault

    @_div.style.left = @_position.x + "px"
    @_div.style.top = @_position.y + "px"

    #@_div.style.zIndex = 5

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
    @getHiventHandle().onInvisible @, @_destroy

  # ============================================================================
  nowChanged: ->
    posX = @_timeline.dateToPosition @_hiventHandle.getHivent().startDate
    @setPosition posX

  # ============================================================================
  periodChanged: (dateA, dateB) ->
    posX = @_timeline.dateToPosition @_hiventHandle.getHivent().startDate
    @setPosition posX

  # ============================================================================
  categoryChanged: (c) ->

  # ============================================================================
  getPosition: ->
    return @_position

  # ============================================================================
  setPosition: (posX) =>
    @_position.x = posX# + @_xOffset * HIVENT_MARKER_TIMELINE_RADIUS * 1.5
    @_div.style.left = @_position.x + "px"


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _setDivPos: (pos) ->
    @_div.style.left = pos.x + "px"
    @_div.style.top = pos.y + "px"

  # ============================================================================
  _destroy: =>
    Y_OFFSETS[@getHiventHandle().getHivent().startDate.getTime()] -= 1
    @getHiventHandle().unMarkAll()
    @getHiventHandle().unLinkAll()
    @_div.parentNode.removeChild @_div

    @_hiventHandle.removeListener "onMark", @
    @_hiventHandle.removeListener "onUnMark", @
    @_hiventHandle.removeListener "onLink", @
    @_hiventHandle.removeListener "onUnLink", @
    @_hiventHandle.removeListener "onInvisible", @
    @_hiventHandle.removeListener "onDestruction", @

    super()

    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  HIVENT_MARKER_TIMELINE_RADIUS = 9

  Y_OFFSETS = {}
