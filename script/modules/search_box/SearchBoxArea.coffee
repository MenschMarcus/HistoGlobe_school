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

  _addSearchSymbol: () ->

    symbol = document.createElement "div"
    symbol.className = "search-symbol"
    symbol.innerHTML = '<img class = "search-symbol-logo" src = "data/png/logo-normal-farbe.png">';
    
    @_container.appendChild symbol

    return symbol

  # ============================================================================

  _addSearchBox: () ->

    box = document.createElement "div"
    box.className = "search-box"

    form = document.createElement "form"
    form.className = "search-form"
    box.appendChild form

    # Input =======================================================================
    input = document.createElement "input"
    input.type = "text"
    input.placeholder = "Suchbegriff eingeben"
    input.id = "search-input"
    form.appendChild input

    options = document.createElement "div"
    options.className = "options"
    options.innerHTML = '<span class="msg">Was möchtest du finden?</span>';

    selection = document.createElement "form"
    selection.className = "selection"
    selection.innerHTML = '<input type="radio" name="Option1" value="Ereignisse">Ereignisse';
    selection.innerHTML = '<input type="radio" name="Option2" value="Orte">Orte';
    selection.innerHTML = '<input type="radio" name="Option3" value="Personen">Personen';

    $(input).click () ->
      box.appendChild options
      options.appendChild selection

    # Button ======================================================================
    button = document.createElement "input"
    button.type = "submit" 
    button.value = "Suche"
    button.id = "search-button"
    
    @_container.appendChild button

    $(button).click () ->
      input_text = document.getElementById("search-input").value
      search_results = document.createElement "div"
      search_results.className = "search-results"
      # search_results.textContent = "Ich bin ein Suchergebnis."
      # form.appendChild search_results

      if @_search_results?
        #@_search_results.textContent = "Ich bin ein anderes Suchergebnis."
        @_search_results.textContent = "Suchergebnis für: " + input_text
        form.appendChild @_search_results
      else
        @_search_results = document.createElement "div"
        @_search_results.className = "search-results"
        #@_search_results.textContent = "Ich bin ein Suchergebnis."
        @_search_results.textContent = "Suchergebnis für: " + input_text
        form.appendChild @_search_results

    @_container.appendChild box

    return box

    #=============================================================================