window.HG ?= {}

class HG.FullscreenButton

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  hgInit: (hgInstance) ->

    unless window.fullScreenApi.supportsFullScreen
      console.warn "Not adding fullscreen button due to missing fullScreenApi!"
      return

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onEnterFullscreen"
    @addCallback "onLeaveFullscreen"

    hgInstance.fullscreen_button = @

    if hgInstance.control_button_area?
      state_a = {}
      state_b = {}

      state_a =
        icon: "fa-arrows-alt"
        tooltip: "Zum Vollbildmodus"
        callback: () =>

          elem = document.body
          if (elem.requestFullscreen)
            elem.requestFullscreen()
          else if (elem.msRequestFullscreen)
            elem.msRequestFullscreen()
          else if (elem.mozRequestFullScreen)
            elem.mozRequestFullScreen()
          else if (elem.webkitRequestFullscreen)
            elem.webkitRequestFullscreen()

          @notifyAll "onEnterFullscreen"

          return state_b

      state_b =
        icon: "fa-compress"
        tooltip: "Vollbildmodus verlassen"
        callback: () =>
          window.fullScreenApi.cancelFullScreen();
          @notifyAll "onLeaveFullscreen"
          return state_a

      hgInstance.control_button_area.addButton state_a

    else
      console.error "Failed to add zoom buttons: ControlButtons module not found!"



