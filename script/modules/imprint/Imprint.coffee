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
    @_imprintOverlay = document.createElement "div"
    @_imprintOverlay.id = "imprint-overlay"

    @_imprintBox = document.createElement "div"
    @_imprintBox.id = "imprint-box"
    @_imprintBox.innerHTML = " HORST <br/> HORST <br/> HORST <br/> HORST <br/> HORST <br/>"

    @_imprintOverlay.appendChild @_imprintBox

    $(@_imprintOverlay).click () =>
      @hideBox()

    $(@_imprintOverlay).fadeOut 0


  # ============================================================================
  hgInit: (hgInstance) ->
    @_hgInstance = hgInstance

    parentDiv = hgInstance.getContainer()
    parentDiv.appendChild @_link
    parentDiv.appendChild @_imprintOverlay


  # ============================================================================
  showBox:() ->
    $(@_imprintOverlay).fadeIn()

  # ============================================================================
  hideBox:() ->
    $(@_imprintBox).fadeOut()

