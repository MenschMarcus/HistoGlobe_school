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
    @_ignoredNames = []
    @_currentDate = null
    @_currentHivent = null

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.onAllModulesLoaded @, () =>

      @_timeline = hgInstance.timeline
      @_nowMarker = hgInstance.timeline.getNowMarker()
      @_hiventController = hgInstance.hiventController
      @_categoryFilter = hgInstance.categoryFilter

      @_currentDate = @_timeline.getNowDate()
      @_timeline.onNowChanged @, (date) =>
        @_currentDate = date
      # @_timeline.onIntervalChanged @, () =>
      #   @_ignoredNames = []

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
    nextHivent = @_hiventController.getNextHiventHandle @_currentDate, @_ignoredNames
    nextFound = false

    while not nextFound and nextHivent?
      @_currentHivent = nextHivent unless @_currentHivent?

      hivent = nextHivent.getHivent()
      unless hivent.id in @_hiventNames and hivent.category in @_categoryFilter.getCurrentFilter()
        nextHivent = @_hiventController.getNextHiventHandle hivent.startDate, @_ignoredNames

      else
        nextFound = true
        if hivent.startDate.getTime() is @_currentHivent.getHivent().startDate.getTime()
          @_ignoredNames.push hivent.id
        else
          @_ignoredNames = []

    unless nextFound
      for name in @_hiventNames
        check = @_hiventController.getHiventHandleById name
        if check.getHivent().category in @_categoryFilter.getCurrentFilter()
          nextHivent = check
          nextFound = true
          @_ignoredNames = []
          break

    if nextFound
      @_currentDate = nextHivent.getHivent().startDate
      @_currentHivent = nextHivent
      @_ignoredNames.push @_currentHivent.getHivent().id
      @_timeline.moveToDate @_currentHivent.getHivent().startDate, @_config.transitionTime,
        () =>
          @_currentHivent.activeAll()
          @_currentHivent.focusAll()


  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

