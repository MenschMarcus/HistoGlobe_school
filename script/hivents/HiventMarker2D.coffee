#include Mixin.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarker2D extends L.Marker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hivent, display, map) ->

    L.Marker.call @, [hivent.getHivent().lat, hivent.getHivent().long]

    HG.mixin @, HG.HiventMarker
    HG.HiventMarker.call @, hivent, map.getPanes()["popupPane"]

    VISIBLE_MARKERS_2D.push @

    @_map = map;

    @addTo @_map

    @_position = new L.Point 0,0
    @_updatePosition()

    @on "mouseover", @_onMouseOver
    @on "mouseout", @_onMouseOut
    @on "click", @_onClick
    @_map.on "zoomend", @_updatePosition
    @_map.on "dragend", @_updatePosition
    @_map.on "viewreset", @_updatePosition
    @_map.on "zoomstart", @hideHiventInfo

    @getHiventHandle().onFocus(@, (mousePos) =>
      if display.isRunning()
        display.focus @getHiventHandle().getHivent()
    )

    @getHiventHandle().onDestruction @, @_destroy

    @enableShowName()
    @enableShowInfo()

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _onMouseOver: (e) =>
    pos = {
            x : @_position.x,
            y : @_position.y - HIVENT_MARKER_2D_RADIUS
          }
    @getHiventHandle().mark @, pos
    @getHiventHandle().linkAll pos

  # ============================================================================
  _onMouseOut: (e) =>
    pos = {
            x : @_position.x,
            y : @_position.y - HIVENT_MARKER_2D_RADIUS
          }
    @getHiventHandle().unMark @, pos
    @getHiventHandle().unLinkAll pos

  # ============================================================================
  _onClick: (e) =>
    pos = {
            x : @_position.x,
            y : @_position.y - HIVENT_MARKER_2D_RADIUS
          }
    @getHiventHandle().toggleActive @, pos

  # ============================================================================
  _updatePosition: =>
      @_position = @_map.latLngToLayerPoint @getLatLng()


  # ============================================================================
  _destroy: =>
    @_map.off "zoomend", @_updatePosition
    @_map.off "dragend", @_updatePosition
    @_map.off "viewreset", @_updatePosition
    @_map.off "zoomstart", @hideHiventInfo
    @_map.removeLayer(@)
    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  VISIBLE_MARKERS_2D = []
  HIVENT_MARKER_2D_RADIUS = 40
