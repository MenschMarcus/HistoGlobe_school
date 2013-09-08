window.HG ?= {}

class HG.HiventIcon2D extends L.Icon

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (file) ->

    options =
        iconUrl:     'data/hivent_icons/' + file
        # shadowUrl:   'data/hivent_icons/shadow.png'
        iconSize:     [32, 32]
        # shadowSize:   [32, 32]
        iconAnchor:   [16, 16]
        # shadowAnchor: [16, 16]
        # popupAnchor:  [16, 0]


    L.Icon.call @, options
