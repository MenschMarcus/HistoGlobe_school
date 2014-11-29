window.HG ?= {}

class HG.SearchSymbol

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   --------------------------------------------------------------------------
  constructor: () ->
    defaultConfig =
      icon:     "fa-search"
      #tooltip:  "Suchleiste - Demnächst verfügbar"

    @_config = $.extend {}, defaultConfig

  hgInit: (hgInstance) ->

    hgInstance.search_symbol = @

    if hgInstance.search_box_area?
      search_symbol =
        #tooltip:    @_config.tooltip
        icon:       @_config.icon
        callback: ()-> console.log "Not implmented"

      hgInstance.search_box_area.addSearchSymbol search_symbol

    else
      console.error "Failed to add search symbol: SearchBoxArea module not found!"