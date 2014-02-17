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

    @_config = $.extend {}, defaultConfig, config

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onSlideChanged"

    @_id = ++LAST_GALLERY_ID

    HG.Widget.call @

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    content = document.createElement "div"
    content.className = "gallery-widget"

    gallery_container = document.createElement "div"
    gallery_container.id = "gallery-widget-#{@_id}"
    gallery_container.className = "gallery-widget-slider"
    gallery_container.style.width = "#{@_config.width}px"

    @_gallery = document.createElement "div"
    @_gallery.className = "swiper-wrapper swiper-no-swiping"

    @_left_arrow = document.createElement "i"
    @_left_arrow.className = "arrow arrow-left  fa fa-chevron-left"

    left_shadow = document.createElement "div"
    left_shadow.className = "shadow shadow-left"

    @_right_arrow = document.createElement "i"
    @_right_arrow.className = "arrow arrow-right fa fa-chevron-right"

    right_shadow = document.createElement "div"
    right_shadow.className = "shadow shadow-right"

    pagination = document.createElement "div"
    pagination.id = "gallery-widget-pagination-#{@_id}"
    pagination.className = "gallery-pagination"

    pagination_container = document.createElement "div"
    pagination_container.className = "pagination-container"
    pagination_container.appendChild pagination

    content.appendChild left_shadow
    content.appendChild right_shadow
    content.appendChild @_left_arrow
    content.appendChild @_right_arrow
    content.appendChild pagination_container
    content.appendChild gallery_container
    gallery_container.appendChild @_gallery

    @setName @_config.name
    @setIcon @_config.icon
    @setContent content

    @_swiper = new Swiper "#gallery-widget-#{@_id}",
      grabCursor: true
      paginationClickable: true
      pagination: "#gallery-widget-pagination-#{@_id}"
      longSwipesRatio: 0.2
      calculateHeight: true
      onSlideChangeEnd: @_onSlideEnd
      # onSlideReset: @_onSlideEnd


    $(@_left_arrow).click () =>
      @_swiper.swipePrev()

    $(@_right_arrow).click () =>
      @_swiper.swipeNext()

    # for some reason needed...
    window.setTimeout () =>
      @_swiper.reInit()
      @_updateArrows()
    , 1000

  # ============================================================================
  addDivSlide: (div) ->
    slide = document.createElement "div"
    slide.className = "swiper-slide"
    slide.appendChild div

    @_addSlide slide

  # ============================================================================
  addHTMLSlide: (html) ->
    slide = document.createElement "div"
    slide.className = "swiper-slide"
    slide.innerHTML = html

    @_addSlide slide

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
  _addSlide: (slide) ->
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
      $(@_left_arrow).addClass("hidden")
      $(@_right_arrow).removeClass("hidden")
    else if slide is @getSlideCount() - 1
      $(@_right_arrow).addClass("hidden")
      $(@_left_arrow).removeClass("hidden")
    else
      $(@_left_arrow).removeClass("hidden")
      $(@_right_arrow).removeClass("hidden")

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  LAST_GALLERY_ID = 0
