window.HG ?= {}

class HG.PictureWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, icon, name, url) ->

    HG.Widget.call @, container

    $(container).addClass = "pictureWidget"

    @setName name
    @setIcon icon

    content = document.createElement "img"
    content.src = url

    @setContent content
