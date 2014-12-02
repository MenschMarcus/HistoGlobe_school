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
    @_search_results = null

    @_hgInstance.onTopAreaSlide @, (t) =>
      if @_hgInstance.isInMobileMode()
        @_container.style.left = "#{t*0.5}px"
      else
        @_container.style.left = "0px"

  # ============================================================================

  addSearchSymbol: (config) ->
    @_addSearchSymbol config

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

    # Button ======================================================================
    button = document.createElement "input"
    button.type = "submit" 
    button.value = "Suche"
    button.className = "search-button"
    
    @_container.appendChild button

    $(button).click () ->
      search_results = document.createElement "div"
      search_results.className = "search-results"
      search_results.textContent = "Ich bin ein Suchergebnis."
      form.appendChild search_results

      if @_search_results?
        @_search_results.textContent = "Ich bin ein anderes Suchergebnis."
        form.appendChild @_search_results
      else
        @_search_results = document.createElement "div"
        @_search_results.className = "search-results"
        @_search_results.textContent = "Ich bin ein Suchergebnis."
        form.appendChild @_search_results

    @_container.appendChild box

    return box