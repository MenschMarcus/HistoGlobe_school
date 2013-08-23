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

    @_display = display
    @_map = map

    @addTo @_map

    @_position = new L.Point 0,0
    @_updatePosition()

    @on "mouseover", @_onMouseOver
    @on "mouseout", @_onMouseOut
    @on "click", @_onClick
    @_map.on "zoomend", @_updatePosition
    @_map.on "drag", @_updatePosition
    @_map.on "viewreset", @_updatePosition

    @getHiventHandle().onFocus(@, (mousePos) =>
      if @_display.isRunning()
        @_display.focus @getHiventHandle().getHivent()
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
    @getHiventHandle().toggleActive @, @_getDisplayPosition()

  # ============================================================================
  _updatePosition: =>
    @_position = @_map.latLngToLayerPoint @getLatLng()
    @_updatePopoverAnchor @_getDisplayPosition()


  # ============================================================================
  _getDisplayPosition: ->
    pos =  @_map.layerPointToContainerPoint(new L.Point @_position.x, @_position.y - HIVENT_MARKER_2D_RADIUS )
    offset = $(@_map.getContainer()).offset()
    pos.x += offset.left
    pos.y += offset.top + HIVENT_MARKER_2D_RADIUS / 2
    pos

  # ============================================================================
  _destroy: =>
    @_map.off "zoomend", @_updatePosition
    @_map.off "drag", @_updatePosition
    @_map.off "viewreset", @_updatePosition
    @_map.removeLayer(@)
    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  VISIBLE_MARKERS_2D = []
  HIVENT_MARKER_2D_RADIUS = 40
