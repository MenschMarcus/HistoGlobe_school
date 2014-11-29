window.HG ?= {}

class HG.SearchButton

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   --------------------------------------------------------------------------
  constructor: () ->
    defaultConfig =
      #icon:     "fa-search"
      #tooltip:  "Suchleiste - Demnächst verfügbar"
      callback: ()-> console.log "Not implmented"

    @_config = $.extend {}, defaultConfig

  hgInit: (hgInstance) ->

    hgInstance.search_button = @

    if hgInstance.search_box_area?
      search_button =
        #tooltip:    @_config.tooltip
        #icon:       @_config.icon
        callback: ()-> console.log "Not implmented"

      hgInstance.search_box_area.addSearchButton search_button

    else
      console.error "Failed to add search button: SearchBoxArea module not found!"