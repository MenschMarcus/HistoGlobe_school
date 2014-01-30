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

  # ============================================================================
  hgInit: (hgInstance) ->
    @_timeline = hgInstance.timeline
    @_hiventController = hgInstance.hiventController

    if @_hiventController
      @_hiventController.onHiventAdded (handle) =>
        hiventMarkerDate = @_timeline.nowMarkerBox.stringToDate handle.getHivent().displayDate
        marker = new HG.HiventMarkerTimeline @_timeline, handle, @_timeline.getCanvas(), @_timeline.dateToPosition(hiventMarkerDate)
        @_hiventMarkers.push marker

      @_timeline.onNowChanged @, @_updateHiventMarkerPositions
      @_timeline.onIntervalChanged @, @_updateHiventMarkerPositions
    else
      console.error "Unable to show hivents on Timeline: HiventController module not detected in HistoGlobe instance!"

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  _updateHiventMarkerPositions: ->
    for i in  [0...(@_hiventMarkers.length)]
      hiventMarkerDate = @_timeline.nowMarkerBox.stringToDate(@_hiventMarkers[i].getHiventHandle()._hivent.displayDate)
      @_hiventMarkers[i].setPosition(@_timeline.dateToPosition(hiventMarkerDate))

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

