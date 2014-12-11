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
    @_search_opt_event = true
    @_search_opt_place = false
    @_search_opt_person = false
    @_search_opt_jear = false

    @_input_text = null

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

    $(input).click () ->
      box.appendChild options
      options.appendChild selection

      console.log @_hgInstance

      #if @_hgInstance.hiventController
        #console.log @_hgInstance.hiventController
        #@_hiventController=@_hgInstance.hiventController
        #hivents=@_hiventController._hiventHandles
        #console.log hivents
        #for hivent in hivents
        #  console.log hivent.id

#    $(input).release () ->
#      rm_opt = document.getElementById("options");
#      elem.parentNode.removeChild(rm_opt);

    # Options =====================================================================
    options = document.createElement "div"
    options.id = "options"
    options.innerHTML = '<span class="msg">Was möchtest du finden?</span>';

    selection = document.createElement "form"
    selection.className = "selection"
    selection.innerHTML = '<input type="checkbox" name="search_option" value="Ereignisse" checked/>Ereignisse
    					   <input type="checkbox" name="search_option" value="Orte"/>Orte
    					   <input type="checkbox" name="search_option" value="Personen"/>Personen
                 <input type="checkbox" name="search_option" value="Jahr"/>Jahr';

    # Button ======================================================================
    button = document.createElement "input"
    button.type = "submit" 
    button.value = "Suche"
    button.id = "search-button"
    
    @_container.appendChild button

    $(button).click () ->
      @_input_text = document.getElementById("search-input").value

      options_input = document.getElementsByName("search_option")
      @_search_opt_event = options_input[0].checked
      @_search_opt_place = options_input[1].checked
      @_search_opt_person = options_input[2].checked
      @_search_opt_jear = options_input[3].checked

      if !@_search_results?
        @_search_results = document.createElement "div"
        @_search_results.className = "search-results"       

      @_search_results.innerHTML  = '<span class="search-result"> Suchergebnis für: '+ 
        @_input_text + '<br><span class="result" data-type="person">Ich bin Heinrich</span><br>
        <span class="result" data-type="person">Ich bin Rudolf</span><br>
        <span class="result" data-type="person">Ich bin Wilhelm</span><br>
        <span class="result" data-type="place">Ich bin Berlin</span><br>
        <span class="result" data-type="place">Ich bin Weimar</span><br>
        <span class="result" data-type="event">Ich bin Unternehmen Wintergewitter</span><br>
        <span class="result" data-type="event">Ich bin Operation Feldmaus</span><br>
        <span class="result" data-type="event">Ich bin Unternehmen Barbarossa</span><br>
        <span class="result" data-type="event">Und die Search Optionen sind: '+
        @_search_opt_event + ' ' + @_search_opt_place + ' ' + @_search_opt_person + ' ' +
        @_search_opt_jear + '</span>';

      form.appendChild @_search_results
    @_container.appendChild box

    return box

    #=============================================================================