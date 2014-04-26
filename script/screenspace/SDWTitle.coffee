window.HG ?= {}

class HG.SDWTitle

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      elements: []

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  init: (hgInstance, parentDiv) ->

    @_categoryFilter = hgInstance.categoryFilter

    @_div               = document.createElement("div")
    @_div.className     = "title_container"
    @_div.innerHTML     = "huhu"

    @_allCategories = []

    parentDiv.appendChild @_div

    select = document.createElement "select"
    select.className = "legend-select"
    @_div.appendChild select

    for element in @_config.elements
      @_addElement element, select

    $(select).select2()
    $(select).on "change", (e) =>
      @_categoryFilter?.exclusiveFilter(e.val,@_allCategories)

    @_categoryFilter?.filter(@_config.elements[0].category)

  # ============================================================================
  _addElement: (element, parent) ->
    if element.type is "category"
      option = document.createElement "option"
      option.value = element.category
      option.innerHTML = element.name
      parent.appendChild option
      @_allCategories.push element.category
    else
      group = document.createElement "optgroup"
      group.label = element.name
      parent.appendChild group

      for e in element.elements
        @_addElement e, group








