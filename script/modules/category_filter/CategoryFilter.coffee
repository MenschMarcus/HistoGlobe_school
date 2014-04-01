window.HG ?= {}

class HG.CategoryFilter

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onFilterChanged"

    @_categoryFilter = []


  # ============================================================================
  hgInit: (hgInstance) ->
    #super hgInstance ????

    hgInstance.categoryFilter = @



  # ============================================================================
  getCurrentFilter:() ->
    return @_categoryFilter


  # ============================================================================
  exclusiveFilter: (element,outOfThese) ->
    for candidate in outOfThese
        if element is candidate.category
          @_categoryFilter.push element
          console.log "pushed0: ",element
        else
          @_categoryFilter = @_categoryFilter.filter (item) -> item isnt candidate.category

      console.log element, @_categoryFilter

      @notifyAll "onFilterChanged", @_categoryFilter

  # ============================================================================
  filter: (category) ->
    @_categoryFilter.push category
    console.log "pushed1: ",category


  # ============================================================================
  checkFilter: (domElement,category) ->

    $(domElement).toggleClass "active"

    if $(domElement).hasClass("active")
      @_categoryFilter.push category
      console.log "pushed2: ",category
    else
      @_categoryFilter = @_categoryFilter.filter (item) -> item isnt category

    console.log "filtered: ", @_categoryFilter

    @notifyAll "onFilterChanged", @_categoryFilter


  # ============================================================================
  make_filterable:(domElement,config,className) ->

    if config.filterable
      #domElement.className = "legend-row legend-row-filterable active"
      domElement.className = domElement.className + " " + domElement.className + "-filterable active"
      @_categoryFilter.push config.category
      console.log "pushed3: ",config.category
    else
      #domElement.className = "legend-row legend-row-non-filterable"
      domElement.className = domElement.className + " " + domElement.className + "-non-filterable"

