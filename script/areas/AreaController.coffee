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
      areaJSONPaths: undefined

    conf = $.extend {}, defaultConfig, config

    @loadAreasFromJSON conf

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_indicator = hgInstance.areaIndicator
    @_now = @_timeline.getNowDate()

    @_timeline.onNowChanged @, (date) ->
      @_now = date
      for area in @_areas
        # execute_async = (area) =>
        #   setTimeout () => area.setDate date, 0
        # execute_async(area)

        area.setDate date

  # ============================================================================
  loadAreasFromJSON: (config) ->

    for path in config.areaJSONPaths
      $.getJSON path, (countries) =>
        for country in countries.features

          execute_async = (c) =>
            setTimeout () =>
              newArea = new HG.Area c, @_indicator

              newArea.onShow @, (area) =>
                @notifyAll "onShowArea", area

              newArea.onHide @, (area) =>
                @notifyAll "onHideArea", area

              @_areas.push newArea

              newArea.setDate @_now
            , 0

          execute_async country

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################


