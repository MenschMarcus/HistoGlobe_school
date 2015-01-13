window.HG ?= {}

class HG.Logo

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   --------------------------------------------------------------------------
  constructor: () ->
    defaultConfig =
      icon:     "fa-search"

    @_config = $.extend {}, defaultConfig

  hgInit: (hgInstance) ->

    hgInstance.logo = @

    if hgInstance.search_box_area?
      logo =
        icon:       @_config.icon
        callback: ()-> console.log "Not implmented"

      hgInstance.search_box_area.addLogo logo

    else
      console.error "Failed to add logo: SearchBoxArea module not found!"