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

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventInfoAtTag = @

    @_timeline = hgInstance.timeline
    @_hiventInfoPopovers = hgInstance.hiventInfoPopovers

    if @_hiventInfoPopovers
      @_hiventInfoPopovers.onPopoverAdded (marker) =>
        handle = marker.getHiventHandle()
        hivent = handle.getHivent()
        if hivent.id is @_hiventID

          handle.focusAll()
          handle.toggleActive marker, marker.getDisplayPosition()
          @_timeline.scrollToDate marker.getHiventHandle().getHivent().startDate


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

