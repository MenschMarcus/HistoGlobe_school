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

  addLogo: (config) ->
    @_addLogo config

  addSearchBox: (config) ->
    @_addSearchBox config

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addLogo: () ->

    logo = document.createElement "div"
    logo.className = "logo"
    logo.innerHTML = '<img class = "hg-logo" src = "data/png/logo-normal-farbe.png">';
    @_container.appendChild logo

    return logo

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
    input.autocomplete = "off"
    form.appendChild input

    # Clear Icon ==================================================================
    clear = document.createElement "div"
    clear.className = "clear"
    clear.innerHTML = '<span>x</span>' #'<i class="fa fa-times"></i>'
    form.appendChild clear
    $(clear).hide()

    # Search Icon =================================================================
    icon = document.createElement "div"
    icon.className = "search-icon"
    icon.innerHTML = '<i class="fa fa-search"></i>'    
    box.appendChild icon

    # add options if input is clicked
    # $(input).click () =>
    #   box.appendChild options
    #   options.appendChild selection

    # remove options if input is not clicked
    # $(document).click (e) ->
    #   if $(e.target).closest(input).length is 0
    #     options.removeChild selection
    #     box.removeChild options

    # Options =====================================================================
    # options = document.createElement "div"
    # options.id = "options"
    # options.innerHTML = '<span class="msg">Was möchtest du finden?</span>'

    # selection = document.createElement "form"
    # selection.className = "selection"
    # selection.innerHTML = '<input type="checkbox" name="search_option" value="Ereignisse"/>Ereignisse
    #                        <input type="checkbox" name="search_option" value="Orte"/>Orte
    #                        <input type="checkbox" name="search_option" value="Personen"/>Personen
    #                        <input type="checkbox" name="search_option" value="Jahr"/>Jahr'

    # Results =====================================================================
    $(input).keyup () =>
      @_input_text = document.getElementById("search-input").value
      @_input_text = @_input_text.toLowerCase()
      #options_input = document.getElementsByName("search_option")

      # if options_input? 
      #   @_search_opt_event = options_input[0].checked
      #   @_search_opt_place = options_input[1].checked
      #   @_search_opt_person = options_input[2].checked
      #   @_search_opt_year = options_input[3].checked

      if !@_search_results?
        @_search_results = document.createElement "div"
        @_search_results.id = "search-results"

      #if @_hgInstance.categoryFilter._categoryFilter[0] == hivent._hivent.category
      curr_category = @_hgInstance.categoryFilter._categoryFilter[0]

      result_list = []
      epoch_result_list = []

      found_in_location = false
      if @_hgInstance.hiventController._hiventHandles
        for hivent in @_hgInstance.hiventController._hiventHandles
          if hivent._hivent.startYear <= @_input_text && hivent._hivent.endYear >= @_input_text
            if curr_category == hivent._hivent.category
              epoch_result_list.push hivent._hivent
              continue
            else
              result_list.push hivent._hivent
              continue

          for location in hivent._hivent.locationName
            if location.toLowerCase() == @_input_text
              if curr_category == hivent._hivent.category
                epoch_result_list.push hivent._hivent
                found_in_location = true
                continue
              else
                result_list.push hivent._hivent
                found_in_location = true
                continue

          if found_in_location
            continue

          if hivent._hivent.description.toLowerCase().indexOf(@_input_text) > -1
            if curr_category == hivent._hivent.category
              epoch_result_list.push hivent._hivent
              continue
            else
              result_list.push hivent._hivent
              continue

          if hivent._hivent.name.toLowerCase().indexOf(@_input_text) > -1
            if curr_category == hivent._hivent.category
              epoch_result_list.push hivent._hivent
              continue
            else
              result_list.push hivent._hivent
              continue


      epoch_search_output = ''
      for epoch_result in epoch_result_list

        yearString = ''
        if epoch_result.startYear == epoch_result.endYear
          yearString = epoch_result.startYear
        else
          yearString = epoch_result.startYear + ' bis ' + epoch_result.endYear


        epoch_search_output = epoch_search_output + '<li><a href="#event=' + epoch_result.id + '">' + 
        epoch_result.name + '  -' + yearString + '</a></li>'

      search_output = ''
      for result in result_list

        yearString = ''
        if result.startYear == result.endYear
          yearString = result.startYear
        else
          yearString = result.startYear + ' bis ' + result.endYear

        search_output = search_output + '<li><a href="#event=' + result.id + '">' + 
        result.name + '  -' + yearString  + '</a></li>'

      search_result_with_categ_einteilung = ''
      #console.log epoch_search_output
      if epoch_search_output.length > 0
        search_result_with_categ_einteilung = '<span>Suchergebnisse im aktueller Epoche: </span></br><ul>' +
        epoch_search_output + '</ul>'

      if epoch_search_output.length > 0 &&  search_output.length > 0
        search_result_with_categ_einteilung = search_result_with_categ_einteilung + '<br>'

      if search_output.length > 0
        search_result_with_categ_einteilung = search_result_with_categ_einteilung + 
        '<span>Suchergebnisse in anderen Epochen: </span></br><ul>' + search_output + '</ul>'

      @_search_results.innerHTML = search_result_with_categ_einteilung

      form.appendChild @_search_results

    #=============================================================================
      if @_input_text?
        #form.appendChild clear # add clear icon
        $(clear).show()
      else
        #form.removeChild clear # remove clear icon
        $(clear).hide()

      # remove results if input string is empty
      if @_input_text < 1
        form.removeChild @_search_results
        #form.removeChild clear
        $(clear).hide()

      $(clear).click () =>
        #form.removeChild clear
        $(clear).hide()
        document.getElementById("search-input").value = "" #Clear input text
        form.removeChild @_search_results
    
    #=============================================================================
    # Arrow Key Navigation V1 ====================================================
     
      # a = $('.search-box a')

      # $(window).keyup (e) ->
      #   if e.which is 40 # User pressed "down" arrow
      #     if aSelected
      #       aSelected.removeClass('itemhover')
      #       next = aSelected.next()
      #       if next.length > 0
      #         aSelected = next().addClass('itemhover')
      #       else
      #         aSelected = a.eq(0).addClass('itemhover')

      #     else
      #       aSelected = a.eq(0).addClass('itemhover')

      #   else if e.which is 38 # User pressed "up" arrow
      #     if aSelected
      #       aSelected.removeClass('itemhover')
      #       next = aSelected.prev()
      #       if next.length > 0
      #         aSelected = next().addClass('itemhover')
      #       else
      #         aSelected = a.last().addClass('itemhover')

      #     else
      #       aSelected = a.last().addClass('itemhover')

      # Arrow Key Navigation V2 ====================================================
      # currentSelection = 0
      # currentUrl = ''
      # #item = 0

      # if $("#search-results a")?
      #   $(input).keyup (e) =>

      #     switch(e.keyCode)
      #       # User pressed "up" arrow
      #       when 38 then navigate "up"
      #       # User pressed "down" arrow
      #       when 40 then navigate "down"
      #       # User pressed "enter"
      #       when 13
      #         if currentUrl isnt ''
      #           window.location = currentUrl

      # Add data to let the hover know which index they have
      #console.log $(result_list).size()
      #for item in $("#search-results a").size()
      # for item in result_list
      #   console.log "Bäm"
      #   $("#search-results a").eq(item).data("number", item)

      # Simulate the "hover" effect with the mouse
      # $("#search-results a").hover ->
      #   currentSelection = $(this).data(hivent.id)
      #   #console.log currentSelection
      #   setSelected(currentSelection)
      # , ->
      #   $("#search-results a").removeClass "itemhover"
      #   currentUrl = ''

    #=============================================================================
    # navigate = (direction) ->
    #   # Check if any of the menu items is selected
    #   if $("#search-results a .itemhover").length == 0
    #     currentSelection = -1  

    #   if direction is "up" and currentSelection >= 1
    #     currentSelection = currentSelection-1

    #   else if direction is "down" and currentSelection < $("#search-results a").length
    #     ++currentSelection

    #   setSelected(currentSelection)

    #=============================================================================
    # setSelected = (list_item) ->
    #   $("#search-results a").removeClass "itemhover"
    #   $("#search-results a").eq(list_item).addClass "itemhover"
    #   currentUrl = $("#search-results a").eq(list_item).attr("href")

    #=============================================================================
    #=============================================================================
    # Search if Enter key is pressed
    $(input).keyup (e) =>
      if e.which is 13  #Enter key pressed
        e.preventDefault()
        $(input).keyup()   #Trigger search key up event

    @_container.appendChild box

    return box

    #=============================================================================