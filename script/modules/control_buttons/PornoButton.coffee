window.HG ?= {}

class HG.PornoButton

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      icon:     'fa-globe',
      url:      'http://youporn.com',
      tooltip:  'Hier nicht drauf klicken!'

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.porno_button = @

    # helpYOffset = 175

    # if hgInstance.help?
    #   hgInstance.help.addHelp
    #     image :   "config/common/help/help01.png"
    #     anchorX : "left"
    #     anchorY : "top"
    #     offsetX:  30
    #     offsetY:  helpYOffset
    #     width:    "70%"

    if hgInstance.control_button_area?
      porno_button =
        icon:       @_config.icon
        tooltip:    @_config.tooltip
        callback: () =>
          window.open @_config.url

      hgInstance.control_button_area.addButton porno_button

    else
      console.error "Failed to add porno button: ControlButtons module not found!"



