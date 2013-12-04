window.HG ?= {}

class HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (start_hivent, end_hivent) ->

    @_start_hivent = start_hivent
    @_end_hivent   = end_hivent

  # interpolates between positions
  # implemented in derived classes
  # ============================================================================
  getPosition: (date) ->

