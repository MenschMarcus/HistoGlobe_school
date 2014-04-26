window.HG ?= {}

class HG.HiventsOnTimeline

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->

    @_timeline = null
    @_hiventController = null
    @_hiventMarkers = []

    @_onMarkerAddedCallbacks = []
    @_markersLoaded = false

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventsOnTimeline = @

    if hgInstance.categoryIconMapping
      for category in hgInstance.categoryIconMapping.getCategories()
        icons = hgInstance.categoryIconMapping.getIcons(category)
        for element of icons
          HG.createCSSSelector ".hivent_marker_timeline_#{category}_#{element}",
          "width: #{HGConfig.hivent_marker_timeline_width.val}px !important;
           height: #{HGConfig.hivent_marker_timeline_height.val}px !important;
           cursor:pointer;
           margin-top: 0;
           margin-left: -#{HGConfig.hivent_marker_timeline_width.val/2}px;
           position: absolute !important;
           background-image: url(#{icons[element]}) !important;
           background-size: cover !important;"

    @_timeline = hgInstance.timeline
    @_hiventController = hgInstance.hiventController

    if @_hiventController
      @_hiventController.onHiventAdded (handle) =>
        show = (self, oldState) =>
          if oldState is 0 # invisible
            hiventMarkerDate = self.getHivent().startDate
            marker = new HG.HiventMarkerTimeline @_timeline, self, @_timeline.getCanvas(), @_timeline.dateToPosition(hiventMarkerDate)
            @_hiventMarkers.push marker
            @_markersLoaded = @_hiventController._hiventsLoaded
            callback marker for callback in @_onMarkerAddedCallbacks

        handle.onVisibleFuture @, show
        handle.onVisiblePast @, show

      @_timeline.onNowChanged @, @_updateHiventMarkerPositions
      @_timeline.onIntervalChanged @, @_updateHiventMarkerPositions
    else
      console.error "Unable to show hivents on Timeline: HiventController module not detected in HistoGlobe instance!"

    #new:
    hgInstance.onAllModulesLoaded @, () =>
      @_hiventGallerWidget = hgInstance.hiventGalleryWidget
      if @_hiventGallerWidget
        @_hiventGallerWidget.onHiventAdded @,(handle) =>

          hiventMarkerDate = handle.getHivent().startDate
          marker = new HG.HiventMarkerTimeline @_timeline, handle, @_timeline.getCanvas(), @_timeline.dateToPosition(hiventMarkerDate)
          callback marker for callback in @_onMarkerAddedCallbacks

          '''show = (self, oldState) =>
            if oldState is 0 # invisible
              hiventMarkerDate = self.getHivent().startDate
              marker = new HG.HiventMarkerTimeline @_timeline, self, @_timeline.getCanvas(), @_timeline.dateToPosition(hiventMarkerDate)
              @_hiventMarkers.push marker
              @_markersLoaded = @_hiventController._hiventsLoaded
              callback marker for callback in @_onMarkerAddedCallbacks

          handle.onVisibleFuture @, show
          handle.onVisiblePast @, show'''

        @_timeline.onNowChanged @, @_updateHiventMarkerPositions
        @_timeline.onIntervalChanged @, @_updateHiventMarkerPositions


  # ============================================================================
  onMarkerAdded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onMarkerAddedCallbacks.push callbackFunc

      if @_markersLoaded
        callbackFunc marker for marker in @_hiventMarkers

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  _updateHiventMarkerPositions: ->
    for i in  [0...(@_hiventMarkers.length)]
      hiventMarkerDate = @_hiventMarkers[i].getHiventHandle().getHivent().startDate
      @_hiventMarkers[i].setPosition(@_timeline.dateToPosition(hiventMarkerDate))

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

