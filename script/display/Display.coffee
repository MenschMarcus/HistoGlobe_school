window.HG ?= {}

class HG.Display

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################
  constructor: (container) ->
    HG.Display.CONTAINER ?= container


  focus: (hivent) ->
    @setCenter
      x: hivent.long
      y: hivent.lat

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  @Z_INDEX = 0
  @CONTAINER = null
