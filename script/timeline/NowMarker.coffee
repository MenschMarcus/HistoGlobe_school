window.HG ?= {}

class HG.NowMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (mainDiv) ->
    @_mainDiv = mainDiv

    # determine and set position of div
    @_mainDiv.left = (window.innerWidth / 2) - (@_mainDiv.offsetWidth / 2)
    @_mainDiv.style.left = @_mainDiv.left + "px"

    # output to test vars
    console.log "NowMarker: Parameter:"
    console.log "   div width: " + @_mainDiv.offsetWidth
