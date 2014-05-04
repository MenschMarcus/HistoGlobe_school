window.HG ?= {}

class HG.Gallery

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      interactive : true
      showPagination : true

    @_config = $.extend {}, defaultConfig, config

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onSlideChanged"

    @_id = ++LAST_GALLERY_ID

    @mainDiv = document.createElement "div"
    @mainDiv.className = "hg-gallery"

    galleryContainer = document.createElement "div"
    galleryContainer.id = "hg-gallery-#{@_id}"
    galleryContainer.className = "hg-gallery-slider"

    @_gallery = document.createElement "div"
    @_gallery.className = "swiper-wrapper swiper-no-swiping"

    leftShadow = document.createElement "div"
    leftShadow.className = "shadow shadow-left"

    rightShadow = document.createElement "div"
    rightShadow.className = "shadow shadow-right"

    @mainDiv.appendChild leftShadow
    @mainDiv.appendChild rightShadow

    @mainDiv.appendChild galleryContainer
    galleryContainer.appendChild @_gallery

    if @_config.showPagination
      @_leftArrow = document.createElement "i"
      @_leftArrow.className = "arrow arrow-left  fa fa-chevron-circle-left"

      @_rightArrow = document.createElement "i"
      @_rightArrow.className = "arrow arrow-right fa fa-chevron-circle-right"

      pagination = document.createElement "span"
      pagination.id = "hg-gallery-pagination-#{@_id}"
      pagination.className = "gallery-pagination"

      paginationContainer = document.createElement "span"
      paginationContainer.className = "pagination-container"
      paginationContainer.appendChild pagination

      @mainDiv.appendChild @_leftArrow
      @mainDiv.appendChild @_rightArrow
      @mainDiv.appendChild paginationContainer


  # ============================================================================
  init: () ->
    pagination_div = undefined

    if @_config.showPagination
      pagination_div = "#hg-gallery-pagination-#{@_id}"

    @swiper = new Swiper "#hg-gallery-#{@_id}",
      grabCursor: true
      paginationClickable: @_config.showPagination
      pagination: pagination_div
      longSwipesRatio: 0.2
      calculateHeight: true
      onSlideChangeEnd: @_onSlideEnd
      onlyExternal: !@_config.interactive
      onSlideClick: @_activateClickCallback
      # onSlideTouch: @_activateClickCallback

    if @_config.showPagination
      $(@_leftArrow).click () =>
        @swiper.swipePrev()

      $(@_rightArrow).click () =>
        @swiper.swipeNext()

    # for some reason needed...
    window.setTimeout () =>
      @swiper.reInit()
      @_updateArrows()
    , 1000

  # ============================================================================
  addDivSlide: (div, clickCallback=undefined) ->
    slide = document.createElement "div"
    slide.className = "swiper-slide"
    slide.appendChild div

    @_addSlide slide, clickCallback

  # ============================================================================
  addHTMLSlide: (html, clickCallback=undefined) ->
    slide = document.createElement "div"
    slide.className = "swiper-slide"
    slide.innerHTML = html

    @_addSlide slide, clickCallback

  # ============================================================================
  getSlideCount: () ->
    @swiper.slides.length

  # ============================================================================
  getActiveSlide: () ->
    @swiper.activeIndex

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addSlide: (slide, clickCallback=undefined) ->
    slide.hgClickCallback = clickCallback
    @_gallery.appendChild slide
    @swiper.reInit()

  # ============================================================================
  _onSlideEnd: () =>
    @_updateArrows()
    @notifyAll "onSlideChanged", @getActiveSlide()

  # ============================================================================
  _updateArrows: () =>
    slide = @getActiveSlide()

    if slide is 0
      $(@_leftArrow).addClass("hidden")
      $(@_rightArrow).removeClass("hidden")
    else if slide is @getSlideCount() - 1
      $(@_rightArrow).addClass("hidden")
      $(@_leftArrow).removeClass("hidden")
    else
      $(@_leftArrow).removeClass("hidden")
      $(@_rightArrow).removeClass("hidden")

  # ============================================================================
  _activateClickCallback: () =>
    @swiper.activeSlide().hgClickCallback?()

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  LAST_GALLERY_ID = 0
