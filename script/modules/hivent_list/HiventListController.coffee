window.HG ?= {}

class HG.HiventListController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   --------------------------------------------------------------------------
  constructor: () ->
    defaultConfig =
      tooltip:  "HiventList Test"

    @_config = $.extend {}, defaultConfig

  hgInit: (hgInstance) ->

    hgInstance.hivent_list_controller = @

    if hgInstance.hivent_list_module?
      hivent_list_controller =
        callback: ()-> console.log "Not implmented"

      hgInstance.hivent_list_module.addHiventList hivent_list_controller

    else
      console.error "Failed to add HiventList Controller: HiventList module not found!"