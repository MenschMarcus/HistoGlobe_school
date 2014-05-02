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

    content = document.createElement "div"
    content.innerHTML = @_hiventHandle.getHivent().content
    body.appendChild content

    $("a[rel^='prettyPhoto']", content).prettyPhoto {
      animation_speed:'normal'
      theme:'light_square'
      slideshow:3000
      autoplay_slideshow: false
      hideflash: true
      allow_resize: false
      deeplinking: false
    }

    # create popover
    @_popover = new HG.Popover
      hgInstance: hgInstance
      placement:  "auto"
      content:    body
      title:      @_hiventHandle.getHivent().name
      container:  container
      showArrow:  showArrow
      fullscreen: !showArrow

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
