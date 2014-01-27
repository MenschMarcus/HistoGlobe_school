window.HG ?= {}

class HG.TextWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, swiper, icon, name, text) ->

    HG.Widget.call @, container, swiper

    @setName name
    @setIcon icon

    content = document.createElement "div"
    content.innerHTML = text

    @setContent content
