window.HG ?= {}

class HG.Path

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (coordinates, dates) ->

    unless coordinates.length == dates.length
      console.error "Cannot construct path: Amounts of coordinates and dates do not match!"
      return

    @_coordinates = coordinates
    @_dates = dates

  # interpolates between positions
  # implemented in derived classes
  # ============================================================================
  getPosition: (date) ->

