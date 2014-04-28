window.HG ?= {}

class HG.SDWTitle

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      title: "Title"
      elements: []

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  init: (hgInstance, parentDiv) ->

    @_categoryFilter = hgInstance.categoryFilter

    @_text_div               = document.createElement("div")
    @_text_div.className     = "title-text"
    @_text_div.innerHTML     = @_config.title
    parentDiv.appendChild @_text_div

    @_select_div               = document.createElement("div")
    @_select_div.className     = "title-select"
    parentDiv.appendChild @_select_div

    $(@_select_div).tooltip {title: "Wählen Sie ein Projekt der sdw, um mehr darüber zu erfahren!", placement: "bottom", container:"body"}


    select = document.createElement "select"
    @_select_div.appendChild select

    @_allCategories = []

    for element in @_config.elements
      @_addElement element, select

    $(select).select2()
    $(select).on "change", (e) =>
      @_categoryFilter?.exclusiveFilter(e.val.split(","),@_allCategories)
      console.log e.name

    @_categoryFilter?.filter(@_config.elements[0].categories)

  # ============================================================================
  _addElement: (element, parent) ->
    if element.type is "category"
      option = document.createElement "option"
      option.value = element.categories
      option.name = element.startDate + "," + element.endDate
      option.innerHTML = element.name
      parent.appendChild option
      for c in element.categories
        @_allCategories.push c
    else
      group = document.createElement "optgroup"
      group.label = element.name
      parent.appendChild group

      for e in element.elements
        @_addElement e, group








