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
    @_currentHivent = -1
    @_needsSorting = true

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.onAllModulesLoaded @, () =>

      @_timeline = hgInstance.timeline
      @_nowMarker = hgInstance.timeline.getNowMarker()
      @_hiventController = hgInstance.hiventController
      @_categoryFilter = hgInstance.categoryFilter

      if @_hiventNames.length is 0
        @_hiventController.onHiventAdded (handle) =>
          id = handle.getHivent().id
          unless id in @_hiventNames
            push = false
            if @_config.hiventPrefixes?
              for prefix in @_config.hiventPrefixes
                if id.indexOf(prefix) is 0
                  push = true
                  break
            else push = true

            if push
              @_hiventNames.push id
              @_needsSorting = true

      @_nowMarker.animationCallback = @_jumpToNextHivent


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _jumpToNextHivent: =>
    if @_needsSorting
      @_needsSorting = false
      @_hiventNames.sort (a, b) =>
        hiventA = @_hiventController.getHiventHandleById a
        hiventB = @_hiventController.getHiventHandleById b
        if hiventA? and hiventB?
          return hiventA.getHivent().startDate.getTime() - hiventB.getHivent().startDate.getTime()
        return 0

    old = @_currentHivent
    if old is -1
      old = @_hiventNames.length - 1
    @_currentHivent = (@_currentHivent + 1) % @_hiventNames.length
    nextHivent = @_hiventController.getHiventHandleById @_hiventNames[@_currentHivent]
    nextFound = false

    while (not nextFound) and (@_currentHivent isnt old)
      unless nextHivent.getHivent().category in @_categoryFilter.getCurrentFilter()
        @_currentHivent = (@_currentHivent + 1) % @_hiventNames.length
        nextHivent = @_hiventController.getHiventHandleById @_hiventNames[@_currentHivent]

      else nextFound = true

    if nextFound
      @_timeline.moveToDate nextHivent.getHivent().startDate, @_config.transitionTime,
        () =>
          nextHivent.activeAll()
          nextHivent.focusAll()


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

