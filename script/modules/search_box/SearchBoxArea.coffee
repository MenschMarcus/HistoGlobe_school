window.HG ?= {}

class HG.SearchBoxArea

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  hgInit: (hgInstance) ->

    @_hgInstance = hgInstance
    @_hgInstance.search_box_area = @

    @_container = document.createElement "div"
    @_container.className = "search-box-area"
    @_hgInstance._top_area.appendChild @_container

    @_hgInstance.onTopAreaSlide @, (t) =>
      if @_hgInstance.isInMobileMode()
        @_container.style.left = "#{t*0.5}px"
      else
        @_container.style.left = "0px"

  # ============================================================================
  addButton: (config) ->
    @_addButton config

  addSearchBox: (config) ->
    @_addSearchBox config

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addButton: (config) ->
    defaultConfig =
      icon: "fa-search"
      tooltip:  "Demnächst verfügbar"
      callback: ()-> console.log "Not implmented"

    config = $.extend {}, defaultConfig, config

    button = document.createElement "div"
    button.className = "search-box-button"
    $(button).tooltip {title: config.tooltip, placement: "right", container:"body"}

    icon = document.createElement "i"
    icon.className = "fa " + config.icon
    button.appendChild icon

    @_container.appendChild button

    return button

  # ============================================================================
  _addSearchBox: (config) ->
    defaultConfig =
      callback: ()-> console.log "Not implmented"

    config = $.extend {}, defaultConfig, config

    box = document.createElement "div"
    box.className = "search-box"
    $(box).tooltip {title: config.tooltip, placement: "right", container:"body"}

    form = document.createElement "form"
    form.className = "search-form"
    box.appendChild form

    input = document.createElement "input"
    input.className = "search-input"
    form.appendChild input


    @_container.appendChild box

    return box