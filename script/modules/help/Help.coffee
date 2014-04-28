window.HG ?= {}

class HG.Help

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      elements: []

    @_config = $.extend {}, defaultConfig, config

    @_div = document.createElement "div"
    @_div.className = "help-overlay"

    $(@_div).click () =>
      @hide()

    $("#histoglobe").append @_div

    for e in @_config.elements
      @_addHelp e


  # ============================================================================
  hgInit: (hgInstance) ->
    @_hgInstance = hgInstance
    @_hgInstance.help = @

    if hgInstance.control_button_area?
      help =
        icon: "fa-question"
        tooltip: "Hilfe einblenden"
        callback: () =>
          unless @_hgInstance._collapsed
            @_hgInstance._collapse()
          @show()

      hgInstance.control_button_area.addButton help

  # ============================================================================
  show:() ->
    $(@_div).addClass "visible"

  # ============================================================================
  hide:() ->
    $(@_div).removeClass "visible"

  # ============================================================================
  toggle:() ->
    $(@_div).toggleClass "visible"

  # ============================================================================
  _addHelp:(element) ->
    image = document.createElement "img"
    image.className = "help-image"
    image.src = element.image
    @_div.appendChild image

    $(image).load () =>
      # console.log $(image).width()
      $(image).css {"max-width": image.naturalWidth + "px"}
      $(image).css {"width": element.width}

    if element.anchorX is "left"
      $(image).css {"left":element.offsetX + "px"}
    else if element.anchorX is "right"
      $(image).css {"right":element.offsetX + "px"}
    else if element.anchorX is "center"
      $(image).css {"left": element.offsetX + "px", "right": 0, "margin-right": "auto", "margin-left": "auto"}

    if element.anchorY is "top"
      $(image).css {"top":element.offsetY + "px"}
    else if element.anchorY is "bottom"
      $(image).css {"bottom":element.offsetY + "px"}
    else if element.anchorY is "center"
      $(image).css {"top": element.offsetY + "px", "bottom": 0, "margin-bottom": "auto", "margin-top": "auto"}















