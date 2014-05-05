window.HG ?= {}

class HG.PictureGalleryWidget extends HG.GalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      pictures : []
      mediaIdsFromDsv :  null
      delimiter: "|"
      indexMapping : null

    @_config = $.extend {}, defaultConfig, config

    HG.GalleryWidget.call @, @_config

    @_pictures = []

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance


    if @_config.mediaIdsFromDsv isnt null and @_config.indexMapping isnt null and hgInstance.multimediaController?
      @_multimediaController = hgInstance.multimediaController
      @_loadPicturesfromDSV()


    @_pictures = @_pictures.concat(@_config.pictures)

    # $("a[rel^='prettyPhoto']", @_gallery).prettyPhoto {
    #   animation_speed:'normal'
    #   theme:'light_square'
    #   slideshow:3000
    #   autoplay_slideshow: false
    #   hideflash: true
    #   allow_resize: true
    #   deeplinking: false
    # }



  # ============================================================================
  _loadPictures: () ->

    #for picture in @_config.pictures
    for picture in @_pictures
      @addPicture picture

    @_sidebar.updateSize()

  # ============================================================================
  addPicture: (config) ->
    defaultConfig =
      image: ""
      description: ""
      copyright: ""
      crop: false

    config = $.extend {}, defaultConfig, config

    div = document.createElement "div"
    div.className = "picture-gallery-widget"

    image = document.createElement "a"
    image.className = "gallery-image"
    image.href = config.image
    image.alt = config.description
    image.title = config.description
    image.style.backgroundImage = "url('#{config.image}')"
    div.appendChild image

    if config.crop
      $(image).addClass("cropped")

    $(image).colorbox
      loop: false
      title: "<p class='gallery-copyright'>" + config.copyright + "</p>" + config.description

    text = document.createElement "div"
    text.className = "clear picture-gallery-widget-text"
    text.innerHTML = config.description
    div.appendChild text

    @addDivSlide div

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _loadPicturesfromDSV: () ->

    parse_config =
      delimiter: @_config.delimiter
      header: false

    $.get @_config.mediaIdsFromDsv,
      (data) =>
        parse_result = $.parse data, parse_config
        for result, i in parse_result.results

          if result[@_config.indexMapping.projectId] in @_config.categories

            media = result[@_config.indexMapping.mediaId]
            media_arr = media.split ","

            for m in media_arr
              mm = @_multimediaController.getMultimediaById m
              image =
                image : mm.link
                description : mm.description
                copyright: mm.source
                crop: mm.crop
              @_pictures.push image

        @_loadPictures()


