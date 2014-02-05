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

    left = document.createElement "div"
    left.className = "arrow arrow-left"

    left_shadow = document.createElement "div"
    left_shadow.className = "shadow shadow-left"

    right = document.createElement "div"
    right.className = "arrow arrow-right"

    right_shadow = document.createElement "div"
    right_shadow.className = "shadow shadow-right"

    pagination = document.createElement "div"
    pagination.id = "gallery-widget-pagination-#{@_id}"
    pagination.className = "pagination"

    content.appendChild left_shadow
    content.appendChild right_shadow
    content.appendChild left
    content.appendChild right
    content.appendChild pagination
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


    $(left).click () =>
      @_swiper.swipePrev()

    $(right).click () =>
      @_swiper.swipeNext()

  addDivSlide: (div) ->
    slide = document.createElement "div"
    slide.className = "swiper-slide"
    slide.appendChild div

    @_gallery.appendChild slide
    @_swiper.reInit()

  addHTMLSlide: (html) ->
    slide = document.createElement "div"
    slide.className = "swiper-slide"

    content = document.createElement "div"
    content.innerHTML = html
    slide.appendChild content

    @_gallery.appendChild slide
    @_swiper.reInit()

  addImageSlide: (url) ->
    image = document.createElement "img"
    image.src = url

    @addDivSlide image

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  LAST_GALLERY_ID = 0
