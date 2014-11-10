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

    helpYOffset = 170
    if hgInstance.sdwTitle?
      helpYOffset = 270

    if hgInstance.help?
      hgInstance.help.addHelp
        image : "config/common/help/help06.png"
        anchorX : "left"
        anchorY : "top"
        offsetX: 30
        offsetY: helpYOffset
        width: "70%"

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