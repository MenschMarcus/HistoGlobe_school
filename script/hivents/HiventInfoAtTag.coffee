window.HG ?= {}

class HG.HiventInfoAtTag

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    @_hiventID = window.location.hash.substring window.location.hash.indexOf("#") + 1

    @_timeline = null
    @_hiventInfoPopovers = null

    @_alreadyShown = false

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.onAllModulesLoaded @, () =>
      hgInstance.hiventInfoAtTag = @

      @_timeline = hgInstance.timeline
      @_hiventController = hgInstance.hiventController
      @_hiventInfoPopovers = hgInstance.hiventInfoPopovers

      if @_hiventInfoPopovers? and @_hiventController?
        @_hiventController.onHiventAdded (handle) =>
          if handle.getHivent().id is @_hiventID
            @_timeline.moveToDate handle.getHivent().startDate, 0.5

        @_hiventInfoPopovers.onPopoverAdded (marker) =>
          unless @_alreadyShown
            handle = marker.getHiventHandle()
            hivent = handle.getHivent()
            if hivent.id is @_hiventID

              handle.focusAll()
              handle.toggleActive marker, marker.getDisplayPosition()
              @_alreadyShown = true


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

