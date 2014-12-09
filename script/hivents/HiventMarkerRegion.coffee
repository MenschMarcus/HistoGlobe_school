window.HG ?= {}


class HG.HiventRegion extends HG.HiventMarker
	constructor: (hiventHandle, display, map) ->
    VISIBLE_REGIONS.push @

    #Call HiventMarker Constructor
    HG.HiventMarker.call @, hiventHandle, map.getPanes()["popupPane"]

    VISIBLE_REGIONS.push @
    @hivent=hiventHandle.getHivent()

    @_locationName = hivent.locactionName

    @_map = map

    @_region=region

    @_region= new  L.polygon @hivent.region

    @_region.myHiventMarkerRegion = @

    @_position = new L.Point 0,0
    @_updatePosition()

  	#Event Listeners
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

    @getHiventHandle().onAgeChanged @, (age) =>
      @_marker.setOpacity age

    @getHiventHandle().onDestruction @, @_destroy
    @getHiventHandle().onVisibleFuture @, @_destroy
    @getHiventHandle().onInvisible @, @_destroy

    @addCallback "onMarkerDestruction"

  # ============================================================================
  getPosition: ->
    {
      lat: @hivent.lat[0]
      long: @_long.long[0]
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
    @getHiventHandle().mark @, @_position
    @getHiventHandle().linkAll @_position

  # ============================================================================
  _onMouseOut: (e) =>
    @getHiventHandle().unMark @, @_position
    @getHiventHandle().unLinkAll @_position

  # ============================================================================
  _onClick: (e) =>
    @getHiventHandle().toggleActive @, @getDisplayPosition()

  # ============================================================================
  _updatePosition: =>
    @_position = @_map.latLngToLayerPoint @_marker.getLatLng()
    @notifyAll "onPositionChanged", @getDisplayPosition()

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


	VISIBLE_REGIONS=[]