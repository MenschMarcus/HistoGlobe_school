window.HG ?= {}

class HG.PictureWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, icon, name, url) ->

    HG.Widget.call @, container

    @setName name
    @setIcon icon

    image = document.createElement "img"
    image.src = url

    content = document.createElement "div"
    content.className = "pictureWidget"
    content.appendChild image

    @setContent content
