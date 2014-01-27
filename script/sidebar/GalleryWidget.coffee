window.HG ?= {}

class HG.GalleryWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, icon, name) ->

    HG.Widget.call @, container

    @setName name
    @setIcon icon

    content = document.createElement "div"
    content.className = "galleryWidget"

    gallery_container = document.createElement "div"
    gallery_container.className = "swiper-container"

    @_gallery = document.createElement "div"
    @_gallery.className = "swiper-wrapper"

    content.appendChild gallery_container
    gallery_container.appendChild @_gallery

    @setContent content

    @_swiper = new Swiper '.swiper-container'

  addDivSlide: (div) ->
    slide = document.createElement "div"
    slide.className = "swiper-slide"
    slide.appendChild div

    @_gallery.appendChild slide
    @_swiper.reInit()

  addImageSlide: (url) ->
    image = document.createElement "img"
    image.src = url

    @addDivSlide image
