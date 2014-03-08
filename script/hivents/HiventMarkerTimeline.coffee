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

    X_OFFSETS[time] ?= 0
    @_xOffset = X_OFFSETS[time]
    #@_position = { x: posX + @_xOffset * HIVENT_MARKER_TIMELINE_RADIUS * 1.5 - HIVENT_MARKER_TIMELINE_RADIUS, y: Math.floor $(parent.parentNode).innerHeight() * 0.65 }
    @_position = { x: posX, y: @_xOffset*10 }
    # @_position = { x: posX, y: Math.floor(Math.random()*(HGConfig.timeline_height.val - HGConfig.hivent_marker_timeline_width.val)+0) }
    X_OFFSETS[time] += 1

    @_classDefault     = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_default"
    @_classHighlighted = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_highlighted"

    @_div = document.createElement "div"
    @_div.setAttribute "class", @_classDefault

    @_div.style.left = @_position.x + "px"
    @_div.style.top = @_position.y + "px"

    parent.appendChild @_div

    @_div.onmouseover = (e) =>
      @getHiventHandle().mark @, @_position
      @getHiventHandle().linkAll @_position

    @_div.onmouseout = (e) =>
      @getHiventHandle().unMark @, @_position
      @getHiventHandle().unLinkAll @_position

    @_div.onclick = (e) =>
      e.preventDefault()
      @_timeline.moveToDate @getHiventHandle().getHivent().startDate, 0.5, () =>
        setTimeout () =>
          @getHiventHandle().focusAll @_position
        ,
        500

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
    X_OFFSETS[@getHiventHandle().getHivent().startDate.getTime()] -= 1
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

  X_OFFSETS = {}
