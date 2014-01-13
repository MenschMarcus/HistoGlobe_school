window.HG ?= {}

class HG.Legend

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, hiventController) ->

    @_container = container
    @_hiventController = hiventController

    @_init()

  # ============================================================================
  addCategoryWithIcon: (category, icon, name, filterable) ->
    row = document.createElement "div"
    row.className = "legend-row"
    @_mainDiv.appendChild row

    cellIcon = document.createElement "span"
    cellIcon.className = "legend-icon"
    cellIcon.style.backgroundImage = "url('#{icon}')"
    row.appendChild cellIcon

    if filterable
      @_addCheckbox(row, category)
      @_categoryFilter.push category

    cellName = document.createElement "span"
    cellName.innerHTML = name
    cellName.className = "legend-text"
    row.appendChild cellName

  # ============================================================================
  addCategoryWithColor: (category, color, name, filterable) ->
    row = document.createElement "div"
    row.className = "legend-row"
    @_mainDiv.appendChild row

    cellColor = document.createElement "span"
    cellColor.style.backgroundColor = color
    cellColor.className = "legend-color"
    row.appendChild cellColor

    if filterable
      @_addCheckbox(row, category)
      @_categoryFilter.push category

    cellName = document.createElement "span"
    cellName.innerHTML = name
    cellName.className = "legend-text"
    row.appendChild cellName

  # ============================================================================
  addSpacer: () ->
    row = document.createElement "div"
    row.className = "legend-row legend-spacer"
    @_mainDiv.appendChild row

  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  _init: () ->
    @_mainDiv = document.createElement "div"
    @_mainDiv.id = "legend"
    @_mainDiv.className = "menu legend"

    @_container.appendChild @_mainDiv

    @_categoryFilter = []

  ############################# MAIN FUNCTIONS #################################

  # ============================================================================
  _addCheckbox: (container, category) ->
    cellCheckParent = document.createElement "span"
    cellCheck = document.createElement "input"
    cellCheck.type = "checkbox"
    cellCheck.checked = true
    container.appendChild cellCheckParent
    cellCheckParent.appendChild cellCheck

    $(cellCheck).change () =>
      if cellCheck.checked
        @_categoryFilter.push category
      else
        @_categoryFilter = @_categoryFilter.filter (item) -> item isnt category

      @_hiventController.setCategoryFilter @_categoryFilter
