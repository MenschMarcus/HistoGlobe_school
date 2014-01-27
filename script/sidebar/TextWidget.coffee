window.HG ?= {}

class HG.TextWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (container, icon, name, text) ->

    HG.Widget.call @, container

    @setName name
    @setIcon icon

    content = document.createElement "div"
    content.className = "textWidget"
    content.innerHTML = text

    @setContent content
