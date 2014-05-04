window.HG ?= {}

class HG.HiventInfoAtTag

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      defaultHash: ""

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.hiventInfoAtTag = @

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onHashChanged"

    hgInstance.onAllModulesLoaded @, () =>
      @_presenter       = hgInstance.hiventPresenter
      @_timeline        = hgInstance.timeline
      @_categoryFilter  = hgInstance.categoryFilter

      $(window).on 'hashchange', @_gotoHash

      @_gotoHash()

  # ============================================================================
  _gotoHash: () =>

      hash = window.location.hash.substring window.location.hash.indexOf("#") + 1

      if hash is "" and @_config.defaultHash isnt ""
        window.location.hash = @_config.defaultHash
        return

      hash = hash.split('&')

      for h in hash
        target = h.split('=')

        if target.length is 2
          switch target[0]
            when "event"
              if @_presenter?
                @_presenter.present target[1]
            when "time"
              date = @_timeline.stringToDate target[1]
              @_timeline.moveToDate date, 0.5
            when "categories"
              categories = target[1].split '+'
              @_categoryFilter?.setCategory categories
            else
              @notifyAll "onHashChanged", target[0], target[1]



