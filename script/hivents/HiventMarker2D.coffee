#include Mixin.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarker2D

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, display, map, markerGroup) ->


    HG.mixin @, HG.HiventMarker
    HG.HiventMarker.call @, hiventHandle, map.getPanes()["popupPane"]

    VISIBLE_MARKERS_2D.push @

    @_display = display
    @_map = map

    # icon_default    = new HG.HiventIcon2D("icon_eu.png")
    # icon_higlighted = new HG.HiventIcon2D("icon_eu_highlighted.png")

    icon_default    = new L.DivIcon {className: "hivent_marker_2D_#{hiventHandle.getHivent().category}_default", iconSize: null}
    icon_higlighted = new L.DivIcon {className: "hivent_marker_2D_#{hiventHandle.getHivent().category}_highlighted", iconSize: null}
    @_marker = new L.Marker [hiventHandle.getHivent().lat, hiventHandle.getHivent().long], {icon: icon_default}
    @_markerGroup = markerGroup

    @_markerGroup.addLayer @_marker

    @_position = new L.Point 0,0
    @_updatePosition()

    @_marker.on "mouseover", @_onMouseOver
    @_marker.on "mouseout", @_onMouseOut
    @_marker.on "click", @_onClick
    @_map.on "zoomend", @_updatePosition
    @_map.on "dragend", @_updatePosition
    @_map.on "viewreset", @_updatePosition

    @getHiventHandle().onFocus(@, (mousePos) =>
      if @_display.isRunning()
        @_display.focus @getHiventHandle().getHivent()
    )

    @getHiventHandle().onActive(@, (mousePos) =>
      @_map.on "drag", @_updatePosition
    )

    @getHiventHandle().onInActive(@, (mousePos) =>
      @_map.off "drag", @_updatePosition
    )

    @getHiventHandle().onLink(@, (mousePos) =>
      @_marker.setIcon icon_higlighted
    )

    @getHiventHandle().onUnLink(@, (mousePos) =>
      @_marker.setIcon icon_default
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
    @_position = @_map.latLngToLayerPoint @_marker.getLatLng()
    @_updatePopoverAnchor @_getDisplayPosition()


  # ============================================================================
  _getDisplayPosition: ->
    pos =  @_map.layerPointToContainerPoint(new L.Point @_position.x, @_position.y - HIVENT_MARKER_2D_RADIUS )
    offset = $(@_map.getContainer()).offset()
    pos.x += offset.left
    pos.y += offset.top + HIVENT_MARKER_2D_RADIUS
    pos

  # ============================================================================
  _destroy: =>
    @getHiventHandle().inActiveAll()
    @_marker.off "mouseover", @_onMouseOver
    @_marker.off "mouseout", @_onMouseOut
    @_marker.off "click", @_onClick
    @_map.off "zoomend", @_updatePosition
    @_map.off "dragend", @_updatePosition
    @_map.off "drag", @_updatePosition
    @_map.off "viewreset", @_updatePosition
    @_markerGroup.removeLayer @_marker
    delete @_map
    delete @_markerGroup
    delete @
    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  VISIBLE_MARKERS_2D = []
  HIVENT_MARKER_2D_RADIUS = 10
