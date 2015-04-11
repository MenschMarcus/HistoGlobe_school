window.HG ?= {}

class HG.Imprint

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    defaultConfig =
      linkText: ""

    @_config = $.extend {}, defaultConfig, config

    # create imprint link
    @_link = document.createElement "div"
    @_link.innerHTML = @_config.linkText
    @_link.id = "imprint-link"

    $(@_link).click () =>
      @showBox()

    # create imprint
    @_imprintBox = document.createElement "div"
    @_imprintBox.id = "imprint-box"

    @_imprintBox.innerHTML = " HORST <br/> HORST <br/> HORST <br/> HORST <br/> HORST <br/>"

    $(@_imprintBox).click () =>
      @hideBox()

    $(@_imprintBox).fadeOut 0


  # ============================================================================
  hgInit: (hgInstance) ->
    @_hgInstance = hgInstance

    parentDiv = hgInstance.getContainer()
    parentDiv.appendChild @_link
    parentDiv.appendChild @_imprintBox


  # ============================================================================
  showBox:() ->
    $(@_imprintBox).fadeIn()

  # ============================================================================
  hideBox:() ->
    $(@_imprintBox).fadeOut()

