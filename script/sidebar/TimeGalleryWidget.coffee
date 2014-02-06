window.HG ?= {}

class HG.TimeGalleryWidget extends HG.GalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    HG.GalleryWidget.call @, config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @_timeline = hgInstance.timeline
    @_timeline.onNowChanged @, @_nowChanged

    @_changeDates = {}

    @onSlideChanged @, (index) =>
      @_timeline.scrollToDate @_changeDates[index]

  # ============================================================================
  addDivSlide: (date, div) ->
    @_changeDates[@getSlideCount()] = date
    super div

  # ============================================================================
  addHTMLSlide: (date, html) ->
    @_changeDates[@getSlideCount()] = date
    super html

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
