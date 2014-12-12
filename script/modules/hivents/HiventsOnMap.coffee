window.HG ?= {}

class HG.HiventsOnMap

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_map = null
    @_hiventController = null
    @_hiventMarkers = []

    @_onMarkerAddedCallbacks = []
    @_markersLoaded = false
    @_dragStart = new HG.Vector 0, 0

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventsOnMap = @

    if hgInstance.categoryIconMapping
      for category in hgInstance.categoryIconMapping.getCategories()
        icons = hgInstance.categoryIconMapping.getIcons(category)
        for element of icons
          HG.createCSSSelector ".hivent_marker_2D_#{category}_#{element}",
          "width: #{HGConfig.hivent_marker_2D_width.val}px !important;
           height: #{HGConfig.hivent_marker_2D_height.val}px !important;
           margin-top: -#{HGConfig.hivent_marker_2D_height.val/2}px;
           margin-left: -#{HGConfig.hivent_marker_2D_width.val/2}px;
           position: absolute !important;
           background-image: url(#{icons[element]}) !important;
           background-size: cover !important;"
        HG.createCSSSelector ".hivent_marker_2D_stack .#{category}",
        "width: #{HGConfig.hivent_marker_2D_width.val}px !important;
         height: #{HGConfig.hivent_marker_2D_height.val}px !important;
         margin-top: 0px;
         margin-left: 5px;
         position: absolute !important;
         background-image: url(#{icons.default}) !important;
         background-size: cover !important;"

    @_map = hgInstance.map._map
    @_hiventController = hgInstance.hiventController

    if @_hiventController
      @_markerGroup = new L.MarkerClusterGroup
        showCoverageOnHover: false
        maxClusterRadius: HGConfig.hivent_marker_2D_width.val
        spiderfyDistanceMultiplier: 1.5
        iconCreateFunction: (cluster) =>
          depth = 0
          html = ""

          for marker in cluster.getAllChildMarkers()
            category = marker.myHiventMarker2D.getHiventHandle().getHivent().category
            html += "<div class='#{category}'>"
            if ++depth is 3
              break
          for i in [0..depth]
            html += "</div>"

          new L.DivIcon {className: "hivent_marker_2D_stack", iconAnchor: [HGConfig.hivent_marker_2D_width.val*0.5 + 5*0.5*depth, HGConfig.hivent_marker_2D_height.val*0.5], html: html}


      @_hiventController.getHivents @, (handle) =>
        @_markersLoaded = @_hiventController._hiventsLoaded

        handle.onVisiblePast @, (self) =>
          if self.getHivent().lat? and self.getHivent().long?
            unless self.getHivent().lat.length is self.getHivent().long.length
              console.error "Unable to add HiventMarker2D: Numbers of lat and long for Hivent #{self.getHivent()} do not match!"
              return

            # hacky... why is locationName.length always 0?
            locations = self.getHivent().locationName[0].split(',')

            for i in [0...self.getHivent().lat.length]
              marker = new HG.HiventMarker2D self, self.getHivent().lat[i], self.getHivent().long[i],  hgInstance.map, @_map, @_markerGroup, locations[i]

              @_hiventMarkers.push marker

              callback marker for callback in @_onMarkerAddedCallbacks

              marker.onDestruction @,() =>
                index = $.inArray(marker, @_hiventMarkers)
                @_hiventMarkers.splice index, 1  if index >= 0

          #HiventRegion NEW
          @region=self.getHivent().region
          if @region? and Array.isArray(@region) and @region.length>0
            region = new HG.HiventMarkerRegion self, hgInstance.map, @_map

            @_hiventMarkers.push region
            callback marker for callback in @_onMarkerAddedCallbacks
            region.onDestruction @,() =>
                index = $.inArray(region, @_hiventMarkers)
                @_hiventMarkers.splice index, 1  if index >= 0

                
      @_map.getPanes().overlayPane.addEventListener "mousedown", (event) =>
        @_dragStart = new HG.Vector event.clientX, event.clientY

      @_map.getPanes().overlayPane.addEventListener "mouseup", (event) =>
        mousepos = new HG.Vector event.clientX, event.clientY
        distance = mousepos.clone()
        distance.sub @_dragStart
        if distance.length() <= 2
          HG.HiventHandle.DEACTIVATE_ALL_HIVENTS()

      @_map.addLayer @_markerGroup
    else
      console.error "Unable to show hivents on Map: HiventController module not detected in HistoGlobe instance!"

  # ============================================================================
  onMarkerAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onMarkerAddedCallbacks.push callbackFunc

      if @_markersLoaded
        callbackFunc marker for marker in @_hiventMarkers

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

