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
  addSearchSymbol: (config) ->
    @_addSearchSymbol config

  addSearchButton: (config) ->
    @_addSearchButton config

  addSearchBox: (config) ->
    @_addSearchBox config

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addSearchSymbol: (config) ->
    defaultConfig =
      icon: "fa-search"
      #tooltip:  "Demnächst verfügbar"
      callback: ()-> console.log "Not implmented"

    config = $.extend {}, defaultConfig, config

    symbol = document.createElement "div"
    symbol.className = "search-symbol"
    #$(symbol).tooltip {title: config.tooltip, placement: "right", container:"body"}

    icon = document.createElement "i"
    icon.className = "fa " + config.icon
    symbol.appendChild icon

    @_container.appendChild symbol

    return symbol

  # ============================================================================
  _addSearchButton: (config) ->
    defaultConfig =
      #tooltip:  "Demnächst verfügbar"
      callback: ()-> console.log "Not implmented"

    config = $.extend {}, defaultConfig, config

    button = document.createElement "input"
    button.type = "submit" 
    button.value = "Suche"
    button.className = "search-button"
    
    #$(button).tooltip {title: config.tooltip, placement: "right", container:"body"}

    $(button).click () ->
      search_results = document.createElement "div"
      search_results.className = "search-results"
      search_results.innerHTML = "<span>Ich bin ein Suchergebnis.</span>"
      button.appendChild search_results

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
    input.method = "get"
    input.action = "http://www.google.com"
    input.className = "search-input"
    form.appendChild input

    @_container.appendChild box

    return box