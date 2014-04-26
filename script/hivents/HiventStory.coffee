window.HG ?= {}

class HG.HiventStory

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      hivents: []
      hiventPrefixes: undefined
      transitionTime: 0

    @_config = $.extend {}, defaultConfig, config

    @_timeline = null
    @_nowMarker = null
    @_hiventController = null
    @_categoryFilter = null
    @_hiventNames = @_config.hivents
    @_currentHivent = 0

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.onAllModulesLoaded @, () =>

      @_timeline = hgInstance.timeline
      @_nowMarker = hgInstance.timeline.getNowMarker()
      @_hiventController = hgInstance.hiventController
      @_categoryFilter = hgInstance.categoryFilter

      if @_hiventNames.length is 0
        @_hiventController.onHiventAdded (handle) =>
          push = false
          id = handle.getHivent().id
          if @_config.hiventPrefixes?
            for prefix in @_config.hiventPrefixes
              if id.indexOf(prefix) is 0
                push = true
                break
          else push = true

          if push
            @_hiventNames.push id

      @_nowMarker.animationCallback = @_jumpToNextHivent


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _jumpToNextHivent: =>
    offset = 0
    while not @_hiventNames[@_currentHivent] in @_categoryFilter.getCurrentFilter() and
          (@_currentHivent + offset) % @_hiventNames.length isnt @_currentHivent - 1
      offset++

    nextHivent = @_hiventController.getHiventHandleById @_hiventNames[@_currentHivent + offset]
    @_timeline.moveToDate nextHivent.getHivent().startDate, @_config.transitionTime,
      () =>
        nextHivent.activeAll()
    @_currentHivent = (@_currentHivent + offset + 1) % @_hiventNames.length


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

