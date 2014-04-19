window.HG ?= {}

class HG.WidgetController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    @_categoryFilter =null
    @_currentCategoryFilter = [] # [category_a, category_b, ...]

    @_widgets = []

    @_config = config


  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.widgetController = @

    hgInstance.categoryFilter?.onFilterChanged @,(categoryFilter) =>
      @_currentCategoryFilter = categoryFilter
      @_filterWidgets()

    @_categoryFilter = hgInstance.categoryFilter if hgInstance.categoryFilter

    @_loadWidgetsFromConfig(@_config,hgInstance)
  
  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _loadWidgetsFromConfig:(config,hgInstance) ->


    load_module = (moduleName, moduleConfig) =>
        if window["HG"][moduleName]?
          newMod = new window["HG"][moduleName] moduleConfig
          newMod.hgInit hgInstance

          @_widgets.push newMod

        else
          console.error "The module #{moduleName} is not part of the HG namespace!"

    for widget in config
        load_module widget.type, widget

    if @_categoryFilter
      @_currentCategoryFilter = @_categoryFilter.getCurrentFilter()
      #@_filterWidgets()


  # ============================================================================
  _filterWidgets:() ->

    if @_categoryFilter

        widgets = @_widgets.slice();
        widgets.shift()

        for widget in widgets
            match = false
            for category in widget._config.categories
                if category in @_currentCategoryFilter
                    widget.show() if widget instanceof HG.Widget # not all widgets are inherited from hg.widget now!!!
                    match =true
                    break
            widget.hide() if widget instanceof HG.Widget and not match # not all widgets are inherited from hg.widget now!!!
