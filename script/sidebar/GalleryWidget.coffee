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
      height: 300

    @_config = $.extend {}, defaultConfig, config

    HG.Widget.call @


  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    content = document.createElement "div"
    content.className = "galleryWidget"

    gallery_container = document.createElement "div"
    gallery_container.className = "gallery-widget-slider"
    gallery_container.style.width = "#{@_config.width}px"

    @_gallery = document.createElement "div"
    @_gallery.className = "swiper-wrapper swiper-no-swiping"

    left = document.createElement "div"
    left.className = "arrow arrow-left"

    right = document.createElement "div"
    right.className = "arrow arrow-right"

    pagination = document.createElement "div"
    pagination.className = "pagination"

    content.appendChild left
    content.appendChild right
    content.appendChild pagination
    content.appendChild gallery_container
    gallery_container.appendChild @_gallery

    @setName @_config.name
    @setIcon @_config.icon
    @setContent content

    @_swiper = new Swiper ".gallery-widget-slider",
      grabCursor: true
      paginationClickable: true
      pagination: ".pagination"
      longSwipesRatio: 0.2

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
