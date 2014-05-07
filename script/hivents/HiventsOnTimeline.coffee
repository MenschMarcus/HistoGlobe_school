window.HG ?= {}

class HG.HiventsOnTimeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    defaultConfig =
      default_row_position: "0px"
      marker_row_positions: []

    @_config = $.extend {}, defaultConfig, config

    @_timeline = null
    @_hiventController = null
    @_hiventMarkers = []

    @_onMarkerAddedCallbacks = []
    @_markersNeedSorting = false
    @_markersLoaded = false

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventsOnTimeline = @

    if hgInstance.categoryIconMapping
      for category in hgInstance.categoryIconMapping.getCategories()
        # position = @_config.default_position
        # for obj in @_config.marker_positions
        #   if obj.category == category
        #     position = obj.position
        icons = hgInstance.categoryIconMapping.getIcons(category)
        for element of icons
          HG.createCSSSelector ".hivent_marker_timeline_#{category}_#{element}",
          "width: #{HGConfig.hivent_marker_timeline_width.val}px !important;
           height: #{HGConfig.hivent_marker_timeline_height.val}px !important;
           cursor:pointer;
           z-index: 2;
           margin-top: 0px;
           margin-left: -#{HGConfig.hivent_marker_timeline_width.val/2}px;
           position: absolute !important;
           background-image: url(#{icons[element]}) !important;
           background-size: cover !important;"

    @_timeline = hgInstance.timeline
    @_hiventController = hgInstance.hiventController

    if @_hiventController
      @_hiventController.getHivents @, (handle) =>
        show = (self, oldState) =>
          if oldState is 0 # invisible
            hiventMarkerDate = self.getHivent().startDate
            rowPosition = @_config.default_row_position
            for obj in @_config.marker_row_positions
              if obj.category is self.getHivent().category
                rowPosition = obj.row_position
                break
            marker = new HG.HiventMarkerTimeline @_timeline, self, @_timeline.getCanvas(), @_timeline.dateToPosition(hiventMarkerDate), parseInt(rowPosition)
            @_hiventMarkers.push marker
            marker.onDestruction @, ()=>
              index = $.inArray(marker, @_hiventMarkers)
              @_hiventMarkers.splice index, 1  if index >= 0

            @_markersLoaded = @_hiventController._hiventsLoaded
            @_sortMarkers()
            callback marker for callback in @_onMarkerAddedCallbacks

        handle.onVisibleFuture @, show
        handle.onVisiblePast @, show

      @_timeline.onNowChanged @, @_updateHiventMarkerPositions
      @_timeline.onIntervalChanged @, @_updateHiventMarkerPositions
    else
      console.error "Unable to show hivents on Timeline: HiventController module not detected in HistoGlobe instance!"

    #new:
    # hgInstance.onAllModulesLoaded @, () =>
    #   @_hiventGallerWidget = hgInstance.hiventGalleryWidget
    #   if @_hiventGallerWidget
    #     @_hiventGallerWidget.onHiventAdded @,(handle) =>

    #       hiventMarkerDate = handle.getHivent().startDate
    #       marker = new HG.HiventMarkerTimeline @_timeline, handle, @_timeline.getCanvas(), @_timeline.dateToPosition(hiventMarkerDate)
    #       callback marker for callback in @_onMarkerAddedCallbacks

    #       '''show = (self, oldState) =>
    #         if oldState is 0 # invisible
    #           hiventMarkerDate = self.getHivent().startDate
    #           marker = new HG.HiventMarkerTimeline @_timeline, self, @_timeline.getCanvas(), @_timeline.dateToPosition(hiventMarkerDate)
    #           @_hiventMarkers.push marker
    #           @_markersLoaded = @_hiventController._hiventsLoaded
    #           callback marker for callback in @_onMarkerAddedCallbacks

    #       handle.onVisibleFuture @, show
    #       handle.onVisiblePast @, show'''

    #     @_timeline.onNowChanged @, @_updateHiventMarkerPositions
    #     @_timeline.onIntervalChanged @, @_updateHiventMarkerPositions


  # ============================================================================
  onMarkerAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onMarkerAddedCallbacks.push callbackFunc

      if @_markersLoaded
        callbackFunc marker for marker in @_hiventMarkers

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _updateHiventMarkerPositions: ->
    minDistance = HGConfig.hivent_marker_timeline_width.val * 0.5

    for marker, i in @_hiventMarkers
      hiventMarkerDate = marker.getHiventHandle().getHivent().startDate
      newPos = @_timeline.dateToPosition(hiventMarkerDate)
      previousMarker = @_hiventMarkers[i-1]

      if previousMarker?
        unless hiventMarkerDate.getTime() is previousMarker.getHiventHandle().getHivent().startDate.getTime()
          if (newPos - minDistance) <= previousMarker.getPosition().x
            newPos = previousMarker.getPosition().x + minDistance

      marker.setPosition(newPos)

  # ============================================================================
  _sortMarkers: ->
    @_hiventMarkers.sort (a, b) =>
      hiventA = a.getHiventHandle()
      hiventB = b.getHiventHandle()
      if hiventA? and hiventB?
        return hiventA.getHivent().startDate.getTime() - hiventB.getHivent().startDate.getTime()
      return 0


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

