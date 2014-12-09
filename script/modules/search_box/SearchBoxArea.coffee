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

    # Options =====================================================================
    options = document.createElement "div"
    options.className = "options"
    options.innerHTML = '<span class="msg">Was möchtest du finden?</span>';

    selection = document.createElement "form"
    selection.className = "selection"
    selection.innerHTML = '<input checked="true" type="checkbox" id="opt1" name="Option1" value="Ereignisse"/>Ereignisse
    					   <input type="checkbox" id="opt2" name="Option2" value="Orte"/>Orte
    					   <input type="checkbox" id="opt3" name="Option3" value="Personen"/>Personen';

    $(input).click () ->
      box.appendChild options
      options.appendChild selection

    event = document.getElementById("opt1")
    place = document.getElementById("opt2")
    person = document.getElementById("opt3")

    #$(input).blur () ->
      #options.removeChild selection
      #box.removeChild options

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

      if @_search_results?
        @_search_results.innerHTML  = '<span class="search-result"> Suchergebnis für: '+ input_text + '<br>
    								   <span class="result" data-type="person">Ich bin Heinrich</span><br>
    								   <span class="result" data-type="person">Ich bin Rudolf</span><br>
    								   <span class="result" data-type="person">Ich bin Wilhelm</span><br>
    								   <span class="result" data-type="place">Ich bin Berlin</span><br>
    								   <span class="result" data-type="place">Ich bin Weimar</span><br>
    								   <span class="result" data-type="event">Ich bin Unternehmen Wintergewitter</span><br>
    								   <span class="result" data-type="event">Ich bin Operation Feldmaus</span><br>
    								   <span class="result" data-type="event">Ich bin Unternehmen Barbarossa</span>';
        form.appendChild @_search_results
      else
        @_search_results = document.createElement "div"
        @_search_results.className = "search-results"
        @_search_results.innerHTML  = '<span class="search-result"> Suchergebnis für: '+ input_text + '<br>
    								   <span class="result" data-type="person">Ich bin Heinrich</span><br>
    								   <span class="result" data-type="person">Ich bin Rudolf</span><br>
    								   <span class="result" data-type="person">Ich bin Wilhelm</span><br>
    								   <span class="result" data-type="place">Ich bin Berlin</span><br>
    								   <span class="result" data-type="place">Ich bin Weimar</span><br>
    								   <span class="result" data-type="event">Ich bin Unternehmen Wintergewitter</span><br>
    								   <span class="result" data-type="event">Ich bin Operation Feldmaus</span><br>
    								   <span class="result" data-type="event">Ich bin Unternehmen Barbarossa</span>';
        form.appendChild @_search_results

    @_container.appendChild box

    return box

    #=============================================================================