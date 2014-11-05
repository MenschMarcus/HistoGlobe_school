
#include Extendable.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarkerTimeline extends HG.HiventMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (timeline, hiventHandle, parent, posX, rowPosition=0) ->
    HG.HiventMarker.call @, hiventHandle, parent

    @_timeline = timeline

    time = hiventHandle.getHivent().startDate.getTime()

    Y_OFFSETS[time] ?= 0
    @_yOffset = Y_OFFSETS[time]
    @_position =
      x: posX,
      y: HGConfig.timeline_height.val -
         HGConfig.hivent_marker_timeline_height.val -
         @_yOffset*HGConfig.hivent_marker_timeline_spacing.val -
         HGConfig.border_width.val -
         HGConfig.hivent_marker_timeline_margin_bottom.val -
         rowPosition

    @rowPosition = rowPosition

    Y_OFFSETS[time] += 1

    @_classDefault     = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_default"
    @_classHighlighted = "hivent_marker_timeline_#{hiventHandle.getHivent().category}_highlighted"

    @_div = document.createElement "div"
    @_div.setAttribute "class", @_classDefault

    @_div.style.left = @_position.x + "px"
    @_div.style.top = @_position.y + "px"

    # new
    '''if hiventHandle.getHivent().startDate.getTime() isnt hiventHandle.getHivent().endDate.getTime()
      xDiff = @_timeline.dateToPosition(hiventHandle.getHivent().endDate) - @_timeline.dateToPosition(hiventHandle.getHivent().startDate)
      @_div.style.width = xDiff + "px"
      @_div.style.background = "rgba(255, 0, 0, 1)"'''

    parent.appendChild @_div

    @_div.onmouseover = (e) =>
      @getHiventHandle().mark @, @_position
      @getHiventHandle().linkAll @_position

    @_div.onmouseout = (e) =>
      @getHiventHandle().unMark @, @_position
      @getHiventHandle().unLinkAll @_position

    @_div.onclick = (e) =>
      e.preventDefault()
      @_timeline.moveToDate @getHiventHandle().getHivent().startDate, 0.5
      @getHiventHandle().focusAll @_position
      # @getHiventHandle().active @, @_position
      @getHiventHandle().activeAll @_position

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
  categoryChanged: (c) ->

  # ============================================================================
  getPosition: ->
    return @_position

  # ============================================================================
  setPosition: (posX) =>
    @_position.x = posX
    @_div.style.left = @_position.x + "px"

  # ============================================================================
  getDiv: ->
    return @_div


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _setDivPos: (pos) ->
    @_div.style.left = pos.x + "px"
    @_div.style.top = pos.y + "px"

  # ============================================================================
  _destroy: =>
    # @notifyAll "onMarkerDestruction"

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

  Y_OFFSETS = {}
