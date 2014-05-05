window.HG ?= {}

class HG.HiventInfoPopover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, container, hgInstance, hiventIndex, showArrow) ->

    @_hiventHandle = hiventHandle
    @_hgInstance = hgInstance
    @_visible = false
    @_multimediaController = hgInstance.multimediaController

    # generate content
    body = document.createElement "div"

    locationString = ''
    if hiventIndex? and @_hiventHandle.getHivent().locationName?
      locationString = @_hiventHandle.getHivent().locationName[hiventIndex] + ', '

    subheading = document.createElement "h3"
    subheading.innerHTML = locationString + @_hiventHandle.getHivent().displayDate
    body.appendChild subheading

    gotoDate = document.createElement "i"
    gotoDate.className = "fa fa-clock-o"
    $(gotoDate).tooltip {title: "Springe zum Ereignisdatum", placement: "right", container:"#histoglobe"}
    $(gotoDate).click () =>
      @_hgInstance.timeline.moveToDate @_hiventHandle.getHivent().startDate, 0.5
    subheading.appendChild gotoDate


    text = document.createElement "div"
    text.innerHTML = @_hiventHandle.getHivent().content
    body.appendChild text


    # create popover
    @_popover = new HG.Popover
      hgInstance: hgInstance
      placement:  "auto"
      content:    body
      title:      @_hiventHandle.getHivent().name
      container:  container
      showArrow:  showArrow
      fullscreen: !showArrow



    @_multimedia = @_hiventHandle.getHivent().multimedia
    if @_multimedia != "" and @_multimediaController?
      mmids = @_multimedia.split ","

      gallery = new HG.Gallery
        interactive : true
        showPagination : (mmids.length >= 2)

      gallery.mainDiv.style.marginLeft = -HGConfig.widget_body_padding.val + "px"
      gallery.mainDiv.style.marginRight = -HGConfig.widget_body_padding.val + "px"

      body.insertBefore gallery.mainDiv, text

      gallery.init()

      @_popover.onResize @, () =>
        gallery.reInit()

      @_multimediaController.onMultimediaLoaded () =>

        for id in mmids
          mm = @_multimediaController.getMultimediaById id
          if mm?
            img = document.createElement "a"
            img.href = mm.thumbnail
            img.title = mm.description
            img.alt = mm.description
            img.style.backgroundImage = "url('" + mm.thumbnail + "')"
            img.className = "gallery-image"

            $(img).colorbox
              title: "<p class='gallery-copyright'>" + mm.source + "</p>" + mm.description
              # rel: gallery.id
              # current: "Bild {current} von {total}"
              # loop: false

            if mm.crop
              $(img).addClass("cropped")

            gallery.addDivSlide img

    @_hiventHandle.onDestruction @, @_popover.destroy


  # ============================================================================
  show: (position) =>
    @_popover.show
      x: position.at(0)
      y: position.at(1)
      @_visible = true

  # ============================================================================
  hide: =>
    @_popover.hide()
    @_hiventHandle._activated = false
    @_visible = false

  # ============================================================================
  isVisible: =>
    @_visible

  # ============================================================================
  updatePosition: (position) ->
    @_popover.updatePosition
      x: position.at(0)
      y: position.at(1)

  # ============================================================================
  destroy: () ->
    @_popover.destroy()
