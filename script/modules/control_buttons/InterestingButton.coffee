window.HG ?= {}

class HG.InterestingButton

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (config) ->
    defaultConfig =
      url:      "http://www.trendhure.com",
      tooltip:  "Pause gefällig?"
      icon:     "fa-globe"

    @_config = $.extend {}, defaultConfig, config

  hgInit: (hgInstance) ->

    hgInstance.interesting_buton = @

    if hgInstance.control_button_area?
      interesting_buton =
        tooltip:    @_config.tooltip
        icon:       @_config.icon
        #icon: "fa-external-link"
        callback: () =>
          window.open @_config.url

      hgInstance.control_button_area.addButton interesting_buton

    else
      console.error "Failed to add interesting button: ControlButtons module not found!"