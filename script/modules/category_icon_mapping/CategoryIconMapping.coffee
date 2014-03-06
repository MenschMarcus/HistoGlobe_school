window.HG ?= {}

class HG.CategoryIconMapping

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      default:
        default: "data/hivent_icons/icon_default.png"
        highlighted: "data/hivent_icons/icon_default_highlight.png"

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.categoryIconMapping = @

  # ============================================================================
  getCategories: () ->
    return Object.keys(@_config)

  # ============================================================================
  getIcons: (category) ->
    if @_config.hasOwnProperty category
      return @_config[category]
    return @_config.default
