window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShowArea"
    @addCallback "onHideArea"

    @_areas = []
    @_timeline = null
    @_now = null

    defaultConfig =
      areaJSONPaths: undefined,
      areaStylerConfig: undefined

    conf = $.extend {}, defaultConfig, config

    @loadAreasFromJSON conf

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_area_styler = hgInstance.areaStyler
    @_now = @_timeline.getNowDate()

    @_timeline.onNowChanged @, (date) ->
      @_now = date
      for area in @_areas
        area.setDate date

  # ============================================================================
  loadAreasFromJSON: (config) ->

    for path in config.areaJSONPaths
      $.getJSON path, (countries) =>
        for country in countries.features

          execute_async = (c) =>
            setTimeout () =>
              newArea = new HG.Area c, @_area_styler

              newArea.onShow @, (area) =>
                @notifyAll "onShowArea", area

              newArea.onHide @, (area) =>
                @notifyAll "onHideArea", area

              @_areas.push newArea

              newArea.setDate @_now
            , 0

          execute_async country

  # ============================================================================
  getActiveAreas:()->
    newArray = []
    for a in @_areas
      if a._active
        newArray.push a
    return newArray

  
  # ============================================================================
  getAllAreas:()->
    return @_areas



  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################


