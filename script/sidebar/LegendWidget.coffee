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

    for column in @_config.columns
      col_div = @addColumn @_config.columns.length

      for group in column.groups
        group_div = @addGroup group.name, col_div

        for element in group.elements
          if element.type is "categoryWithColor"
            @addCategoryWithColor element, group_div
          else if element.type is "categoryWithIcon"
            @addCategoryWithIcon element, group_div
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
  addColumn: (column_count) ->
    col_div = document.createElement "div"
    col_div.className = "legend-column legend-column-#{column_count}"
    @_mainDiv.appendChild col_div
    return col_div

  # ============================================================================
  addCategoryWithIcon: (config, col_div) ->
    defaultConfig =
      category: ""
      icon: ""
      name: ""
      filterable: false

    config = $.extend {}, defaultConfig, config

    row = document.createElement "div"
    col_div.appendChild row

    cellIcon = document.createElement "span"
    cellIcon.className = "legend-icon"
    cellIcon.style.backgroundImage = "url('#{config.icon}')"
    row.appendChild cellIcon

    @_make_filterable row, config

    cellName = document.createElement "span"
    cellName.innerHTML = config.name
    cellName.className = "legend-text"
    row.appendChild cellName

    cellCheck = document.createElement "i"
    cellCheck.className = "fa fa-check legend-check"
    row.appendChild cellCheck

  # ============================================================================
  addCategoryWithColor: (config, col_div) ->
    defaultConfig =
      category: ""
      color: ""
      name: ""
      filterable: false

    config = $.extend {}, defaultConfig, config

    row = document.createElement "div"
    col_div.appendChild row

    cellColor = document.createElement "span"
    cellColor.style.backgroundColor = config.color
    cellColor.className = "legend-color"
    row.appendChild cellColor

    @_make_filterable row, config

    cellName = document.createElement "span"
    cellName.innerHTML = config.name
    cellName.className = "legend-text"
    row.appendChild cellName

    cellCheck = document.createElement "i"
    cellCheck.className = "fa fa-check legend-check"
    row.appendChild cellCheck

  # ============================================================================
  addSpacer: (col_div) ->
    row = document.createElement "div"
    row.className = "legend-row legend-row-spacer"
    col_div.appendChild row

  # ============================================================================
  addGroup: (name, col_div) ->

    group_div = document.createElement "div"
    group_div.className = "legend-group"

    heading = document.createElement "div"
    heading.className = "legend-row legend-row-heading"
    heading.innerHTML = name

    col_div.appendChild group_div
    group_div.appendChild heading

    return group_div


  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  _init: () ->
    @_mainDiv = document.createElement "div"
    @_mainDiv.className = "legend-widget"

    @_categoryFilter = []

  ############################# MAIN FUNCTIONS #################################

  # ============================================================================
  _make_filterable : (row, config) ->

    if config.filterable
      row.className = "legend-row legend-row-filterable active"

      @_categoryFilter.push config.category

      $(row).click () =>
        $(row).toggleClass "active"

        if $(row).hasClass("active")
          @_categoryFilter.push config.category
        else
          @_categoryFilter = @_categoryFilter.filter (item) -> item isnt config.category

        @_hiventController?.setCategoryFilter @_categoryFilter

    else
      row.className = "legend-row legend-row-non-filterable"

