#include Mixin.coffee
#include HiventMarker.coffee

window.HG ?= {}

class HG.HiventMarker2D extends HG.HiventMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, lat, long, display, map, markerGroup, locationName, hgInstance) ->

    #Call Hivent Marker Constructor
    HG.HiventMarker.call @, hiventHandle, map.getPanes()["popupPane"]

    #List of Markers
    VISIBLE_MARKERS_2D.push @

    @_hgInstance = hgInstance
    @_mode = hgInstance.abTest.config.hiventMarkerMode

    @locationName = locationName

    @_display = display
    @_map = map

    @_lat = lat
    @_long = long

    #Private Name and Location because constant use
    @_markerLabelLocation=hiventHandle.getHivent().locationName

    @_markerLabelEventName=hiventHandle.getHivent().name


    html="<div class=\"markerLabel\">#{@_markerLabelLocation}</div>"
    iconAnchor=[15,45]
    icon_default    = new L.DivIcon {className: "hivent_marker_2D_#{hiventHandle.getHivent().category}_default", iconSize: [34, 50] ,iconAnchor:iconAnchor,html:html}
    icon_higlighted = new L.DivIcon {className: "hivent_marker_2D_#{hiventHandle.getHivent().category}_highlighted", iconSize: [34, 50], iconAnchor:iconAnchor, html:html}
    @_marker = new L.Marker [@_lat, @_long], {icon: icon_default}


    @_marker.myHiventMarker2D = @

    @_markerGroup = markerGroup

    @_markerGroup.addLayer @_marker
    @_markerGroup.on "clusterclick", (cluster) =>
      window.setTimeout (() =>
        for marker in cluster.layer.getAllChildMarkers()
          marker.myHiventMarker2D._updatePosition()), 100

    @_position = new L.Point 0,0
    @_updatePosition()

    #Event Listeners
    @_marker.on "mouseover", @_onMouseOver
    @_marker.on "mouseout", @_onMouseOut
    @_marker.on "click", @_onClick
    @_map.on "zoomend", @_updatePosition
    @_map.on "dragend", @_updateMarker

    @_map.on "dragend", @_updatePosition
    @_map.on "viewreset", @_updatePosition
    @_map.on "zoomend", @_updateMarker
    @getHiventHandle().onFocus(@, (mousePos) =>
      if @_display.isRunning()
        @_display.focus @getHiventHandle().getHivent()
    )

    @getHiventHandle().onActive(@, (mousePos) =>
      console.log "active"
      @_marker.setIcon icon_higlighted
      @_map.on "drag", @_updatePosition
    )

    @getHiventHandle().onInActive(@, (mousePos) =>
      console.log "inactive"
      @_marker.setIcon icon_default
      @_map.off "drag", @_updatePosition
    )

    @getHiventHandle().onLink(@, (mousePos) =>
      
      @_marker.setIcon icon_higlighted
    )

    @getHiventHandle().onUnLink(@, (mousePos) =>
      @_marker.setIcon icon_default
    )

    @getHiventHandle().onAgeChanged @, (age) =>
      #no more Opacity
      #@_marker.setOpacity age
      0

    @getHiventHandle().onDestruction @, @_destroy
    @getHiventHandle().onVisibleFuture @, @_destroy
    @getHiventHandle().onInvisible @, @_destroy

    @addCallback "onMarkerDestruction"

  # ============================================================================
  getPosition: ->
    {
      lat: @_lat
      long: @_long
    }

  # ============================================================================
  getDisplayPosition: ->
    #console.log  $(@_map._container).offset()
    #console.log @_map.layerPointToContainerPoint(new L.Point @_position.x, @_position.y )
    pos = @_map.layerPointToContainerPoint(new L.Point @_position.x, @_position.y )
  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _onMouseOver: (e) =>
    #@_hiventHandle.regionMarker.highlight()

    @getHiventHandle().mark @, @_position
    @getHiventHandle().linkAll @_position
    @_updateMarker()

  # ============================================================================
  _onMouseOut: (e) =>
    #@_hiventHandle.regionMarker.unHiglight()
    @getHiventHandle().unMark @, @_position
    @getHiventHandle().unLinkAll @_position
    @_updateMarker()

  # ============================================================================
  # _onClick: (e) =>
    # default behavior
    # @getHiventHandle().toggleActive @, @getDisplayPosition()

    # marker: center horizontally and ~ 2/3 vertically; hivent box above marker
    # @getHiventHandle().focusAll @, @_position
    # @getHiventHandle().activeAll @, @_position
    # @_updatePosition()

  # AB Test ====================================================================
  _onClick: (e, config) =>
    if @_mode is "A"
      # default behavior
      @getHiventHandle().toggleActive @, @getDisplayPosition()

    if @_mode is "B"
      # marker: center horizontally and ~ 2/3 vertically; hivent box above marker
      @getHiventHandle().toggleActive @, @getDisplayPosition()
      @getHiventHandle().focusAll @, @_position
      @getHiventHandle().activeAll @, @_position
      @_updatePosition()

  # ============================================================================
  _updatePosition: =>
    @_position = @_map.latLngToLayerPoint @_marker.getLatLng()
    @notifyAll "onPositionChanged", @getDisplayPosition()

  _updateMarker: =>
    #should be a way to specify behaviour over config/abtest
    #if window.hgConfig.ABTest.regionLabels=="B"
    #disabled for better performance
    #marcus you told me to write this function
    if false
      if @_marker._icon?
        if @_map.getZoom()>3
          @_marker._icon.innerHTML="<div class=\"markerLabel\">#{@_markerLabelLocation}</div>"
        else
          @_marker._icon.innerHTML="<div class=\"markerLabel\">#{@_markerLabelEventName}</div>"
    0
   # ============================================================================
  _destroy: =>

    @notifyAll "onMarkerDestruction"

    @getHiventHandle().inActiveAll()
    @_marker.off "mouseover", @_onMouseOver
    @_marker.off "mouseout", @_onMouseOut
    @_marker.off "click", @_onClick
    @_map.off "zoomend", @_updatePosition
    @_map.off "dragend", @_updatePosition
    @_map.off "drag", @_updatePosition
    @_map.off "viewreset", @_updatePosition
    @_markerGroup.removeLayer @_marker

    @_hiventHandle.removeListener "onFocus", @
    @_hiventHandle.removeListener "onActive", @
    @_hiventHandle.removeListener "onInActive", @
    @_hiventHandle.removeListener "onLink", @
    @_hiventHandle.removeListener "onUnLink", @
    @_hiventHandle.removeListener "onInvisible", @
    @_hiventHandle.removeListener "onVisibleFuture", @
    @_hiventHandle.removeListener "onDestruction", @

    super()
    delete @

    return

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  VISIBLE_MARKERS_2D = []
