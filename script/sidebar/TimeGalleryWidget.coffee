window.HG ?= {}

class HG.TimeGalleryWidget extends HG.GalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      htmlSlides : []
      divSlides : []

    @_config = $.extend {}, defaultConfig, config

    HG.GalleryWidget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @_timeline = hgInstance.timeline
    @_timeline.onNowChanged @, @_nowChanged

    @_changeDates = {}

    @onSlideChanged @, (index) =>
      @_timeline.scrollToDate @_changeDates[index]

    for slide in @_config.htmlSlides
      @addHTMLSlide slide

    for slide in @_config.divSlides
      @addDivSlide slide

  # ============================================================================
  addDivSlide: (config) ->
    defaultConfig =
      date : undefined
      div : undefined

    config = $.extend {}, defaultConfig, config

    date = config.date.split "."
    @_changeDates[@getSlideCount()] = new Date date[2], date[1] - 1, date[0]
    super config.div

  # ============================================================================
  addHTMLSlide: (config) ->
    defaultConfig =
      date : undefined
      html : undefined

    config = $.extend {}, defaultConfig, config
    date = config.date.split "."
    @_changeDates[@getSlideCount()] = new Date date[2], date[1] - 1, date[0]
    super config.html

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _nowChanged: (now) =>
    target = 0
    for index, date of @_changeDates
      if date > now
        break;
      else
        target = index

    @_swiper.swipeTo(target, 500, false)
