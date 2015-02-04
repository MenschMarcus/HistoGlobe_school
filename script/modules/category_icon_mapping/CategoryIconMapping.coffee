window.HG ?= {}

class HG.CategoryIconMapping

  # TODO: Find a better way of dealing with categories and items...
  # - hierarchical categories
  # - default icons

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
    return Object.keys @_config

  # ============================================================================
  getIcons: (category) ->
    icon
    if @_config.hasOwnProperty category
      icon = @_config[category]
    else
      icon = @_config.default
    return icon
