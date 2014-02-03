window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShowArea"
    @addCallback "onHideArea"

    @_areas = []
    @_timeline = null
    @_now = null

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_now = @_timeline.getNowDate()

    @_timeline.onNowChanged @, (date) ->
      @_now = date
      for area in @_areas
        area.setDate date

  # ============================================================================
  loadAreasFromJSON: (config) ->
    defaultConfig =
      path: undefined

    config = $.extend {}, defaultConfig, config

    $.getJSON config.path, (countries) =>
      for country in countries.features
        newArea = new HG.Area country

        newArea.onShow @, (area) =>
          @notifyAll "onShowArea", area

        newArea.onHide @, (area) =>
          @notifyAll "onHideArea", area

        @_areas.push newArea

        newArea.setDate @_now

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################


