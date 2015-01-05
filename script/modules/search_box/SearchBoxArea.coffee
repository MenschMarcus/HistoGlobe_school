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
    @_search_opt_event = false
    @_search_opt_place = false
    @_search_opt_person = false
    @_search_opt_year = false
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

    $(input).click () =>
      box.appendChild options
      options.appendChild selection

    # Options =====================================================================
    options = document.createElement "div"
    options.id = "options"
    options.innerHTML = '<span class="msg">Was möchtest du finden?</span>'

    selection = document.createElement "form"
    selection.className = "selection"
    selection.innerHTML = '<input type="checkbox" name="search_option" value="Ereignisse"/>Ereignisse
    					             <input type="checkbox" name="search_option" value="Orte"/>Orte
    					             <input type="checkbox" name="search_option" value="Personen"/>Personen
                 		       <input type="checkbox" name="search_option" value="Jahr"/>Jahr'

    # Button ======================================================================
    button = document.createElement "input"
    button.type = "submit" 
    button.value = "Suche"
    button.id = "search-button"
    
    @_container.appendChild button

    # Results =====================================================================

    $(button).click () =>
      @_input_text = document.getElementById("search-input").value

      options_input = document.getElementsByName("search_option")
      if options_input? 
        @_search_opt_event = options_input[0].checked
        @_search_opt_place = options_input[1].checked
        @_search_opt_person = options_input[2].checked
        @_search_opt_year = options_input[3].checked
        console.log options_input

      if !@_search_results?
        @_search_results = document.createElement "div"
        @_search_results.className = "search-results"

      result_list = []
      if @_hgInstance.hiventController._hiventHandles
        for hivent in @_hgInstance.hiventController._hiventHandles
          console.log hivent
          if hivent._hivent.startYear <= @_input_text && hivent._hivent.endYear >= @_input_text
            result_list.push hivent._hivent

          for location in hivent._hivent.locationName
          	if location == @_input_text
              result_list.push hivent._hivent

          if hivent._hivent.description.indexOf(@_input_text) > -1
          	result_list.push hivent._hivent

          if hivent._hivent.name.indexOf(@_input_text) > -1
          	result_list.push hivent._hivent

      console.log result_list

      search_output = ''
      for result in result_list 
      	search_output = search_output + '<span>' + result.name + 
      	' ' + result.startYear + '</span></br>'

      @_search_results.innerHTML  = search_output

      form.appendChild @_search_results

    @_container.appendChild box

    return box

    #=============================================================================