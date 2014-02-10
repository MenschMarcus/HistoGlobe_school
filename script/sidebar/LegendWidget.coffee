window.HG ?= {}

class HG.LegendWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      icon: ""
      name: ""
      elements: []

    @_config = $.extend {}, defaultConfig, config

    @_hiventController = null

    @_init()
    HG.Widget.call @

    for element in @_config.elements
      if element.type is "categoryWithColor"
        @addCategoryWithColor element
      else if element.type is "categoryWithIcon"
        @addCategoryWithIcon element
      else
        @addSpacer()

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @setName @_config.name
    @setIcon @_config.icon

    @setContent @_mainDiv

    @_hiventController = hgInstance.hiventController

    unless @_hiventController
      console.error "Unable to filter hivents: HiventController module not detected in HistoGlobe instance!"


  # ============================================================================
  addCategoryWithIcon: (config) ->
    defaultConfig =
      category: ""
      icon: ""
      name: ""
      filterable: false

    config = $.extend {}, defaultConfig, config

    row = document.createElement "div"
    row.className = "legend-row"
    @_mainDiv.appendChild row

    cellIcon = document.createElement "span"
    cellIcon.className = "legend-icon"
    cellIcon.style.backgroundImage = "url('#{config.icon}')"
    row.appendChild cellIcon

    if config.filterable
      @_addCheckbox(row, config.category)
      @_categoryFilter.push config.category

    cellName = document.createElement "span"
    cellName.innerHTML = config.name
    cellName.className = "legend-text"
    row.appendChild cellName

  # ============================================================================
  addCategoryWithColor: (config) ->
    defaultConfig =
      category: ""
      color: ""
      name: ""
      filterable: false

    config = $.extend {}, defaultConfig, config

    row = document.createElement "div"
    row.className = "legend-row"
    @_mainDiv.appendChild row

    cellColor = document.createElement "span"
    cellColor.style.backgroundColor = config.color
    cellColor.className = "legend-color"
    row.appendChild cellColor

    if config.filterable
      @_addCheckbox(row, config.category)
      @_categoryFilter.push config.category

    cellName = document.createElement "span"
    cellName.innerHTML = config.name
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
    @_mainDiv.className = "legend-widget"

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

      @_hiventController?.setCategoryFilter @_categoryFilter
