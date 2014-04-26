window.HG ?= {}

class HG.Title

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      height: 50
      contentClass: ""
      contentConfig: []

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  hgInit: (hgInstance) ->

    @hgInstance = hgInstance
    hgInstance._top_area.style.top = @_config.height + "px"
    hgInstance._onResize()

    @_div               = document.createElement("div")
    @_div.id            = "title"
    @_div.style.height  = @_config.height + "px"

    $("#histoglobe").append @_div

    if @_config.contentClass isnt "" and window["HG"][@_config.contentClass]?
      content = new window["HG"][@_config.contentClass] @_config.contentConfig
      @setContent content
    else
      console.error "Failed to initialize Title module: The content class " +
                     "#{@_config.contentClass} does not exist!"

  # ============================================================================
  setContent: (content) ->
    content.init @hgInstance, @_div
