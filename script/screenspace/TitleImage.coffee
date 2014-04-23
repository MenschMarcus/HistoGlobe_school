window.HG ?= {}

class HG.TitleImage

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      images: []

    @_actualImage = null
    @_config = $.extend {}, defaultConfig, config

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    HG.Widget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    #super hgInstance

    @_timeline = hgInstance.timeline
    @_timeline.onNowChanged @, @_nowChanged

    @_div           = document.createElement("div")
    @_div.id        = "title_image_container"
    @_div.className = "title_image_container"

    @_images = []

    for image, index in @_config.images
      @_images.push @_addImage image, index

    $("#histoglobe").append @_div

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addImage: (image, index) ->

    imageDiv           = document.createElement("img")
    imageDiv.id        = "title_image_" + index
    imageDiv.className = "title_image"
    imageDiv.src = image.path

    @_div.appendChild imageDiv

    retMessage =
      div: imageDiv
      text: image.path
      date: @_timeline.stringToDate image.date

  # ============================================================================
  _nowChanged: (now) =>
    index = 0
    while index < @_images.length
      if (index == @_images.length-1 and @_images[index].date < now and now > @_images[index-1].date) or
          (@_images[index].date < now and now < @_images[index+1].date)
        @changeImages(index)
        break
      index++

  # ============================================================================
  compareDates: (date1, date2) ->
    if date1.getFullYear() == date2.getFullYear() && date1.getMonth() == date2.getMonth()
      return true
    else
      return false

  # ============================================================================
  changeImages: (index) ->
    if @_actualImage == null
      $(@_images[index].div).fadeIn(100)
    if @_actualImage isnt @_images[index].div
      $(@_actualImage).fadeOut(100, => $(@_images[index].div).fadeIn(100))
    @_actualImage = @_images[index].div




