window.HG ?= {}

class HG.ZoomButtons

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  hgInit: (hgInstance) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onZoomIn"
    @addCallback "onZoomOut"

    hgInstance.zoom_buttons = @

    if hgInstance.control_button_area?
      zoom_in =
        icon: "fa-search-plus"
        tooltip: "Ansicht vergrößern"
        callback: () =>
          @notifyAll "onZoomIn"

      zoom_out =
        icon: "fa-search-minus"
        tooltip: "Ansicht verkleinern"
        callback: () =>
          @notifyAll "onZoomOut"

      hgInstance.control_button_area.addButtonGroup [zoom_in, zoom_out]

    else
      console.error "Failed to add zoom buttons: ControlButtons module not found!"
