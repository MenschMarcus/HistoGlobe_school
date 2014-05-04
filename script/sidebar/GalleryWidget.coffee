window.HG ?= {}

class HG.GalleryWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      icon: ""
      name: ""
      interactive : true
      showPagination : true

    @_config = $.extend {}, defaultConfig, config

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onSlideChanged"

    @_id = ++LAST_GALLERY_ID

    HG.Widget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @_galleryContent = document.createElement "div"
    @_galleryContent.className = "gallery-widget"

    galleryContainer = document.createElement "div"
    galleryContainer.id = "gallery-widget-#{@_id}"
    galleryContainer.className = "gallery-widget-slider"
    galleryContainer.style.width = "#{@_config.width}px"

    @_gallery = document.createElement "div"
    @_gallery.className = "swiper-wrapper swiper-no-swiping"

    leftShadow = document.createElement "div"
    leftShadow.className = "shadow shadow-left"

    rightShadow = document.createElement "div"
    rightShadow.className = "shadow shadow-right"

    @_galleryContent.appendChild leftShadow
    @_galleryContent.appendChild rightShadow

    @_galleryContent.appendChild galleryContainer
    galleryContainer.appendChild @_gallery

    if @_config.showPagination
      @_leftArrow = document.createElement "i"
      @_leftArrow.className = "arrow arrow-left  fa fa-chevron-circle-left"

      @_rightArrow = document.createElement "i"
      @_rightArrow.className = "arrow arrow-right fa fa-chevron-circle-right"

      pagination = document.createElement "span"
      pagination.id = "gallery-widget-pagination-#{@_id}"
      pagination.className = "gallery-pagination"

      paginationContainer = document.createElement "span"
      paginationContainer.className = "pagination-container"
      paginationContainer.appendChild pagination

      @_galleryContent.appendChild @_leftArrow
      @_galleryContent.appendChild @_rightArrow
      @_galleryContent.appendChild paginationContainer


    @setName @_config.name
    @setIcon @_config.icon
    @setContent @_galleryContent

    pagination_div = undefined

    if @_config.showPagination
      pagination_div = "#gallery-widget-pagination-#{@_id}"

    @_swiper = new Swiper "#gallery-widget-#{@_id}",
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
        @_swiper.swipePrev()

      $(@_rightArrow).click () =>
        @_swiper.swipeNext()

    # for some reason needed...
    window.setTimeout () =>
      @_swiper.reInit()
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
    @_swiper.slides.length

  # ============================================================================
  getActiveSlide: () ->
    @_swiper.activeIndex

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addSlide: (slide, clickCallback=undefined) ->
    slide.hgClickCallback = clickCallback
    @_gallery.appendChild slide
    @_swiper.reInit()

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
    @_swiper.activeSlide().hgClickCallback?()

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  LAST_GALLERY_ID = 0
