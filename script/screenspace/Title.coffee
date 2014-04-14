window.HG ?= {}

class HG.Title

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      name: ""

    @_config = $.extend {}, defaultConfig, config

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    HG.Widget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    #super hgInstance

    @_timeline = hgInstance.timeline
    @_timeline.onNowChanged @, @_nowChanged

    @_div           = document.createElement("div")
    @_div.id        = "title_container"
    @_div.className = "title_container"
    @_div.innerHTML = @_config.name

    $("body").append @_div