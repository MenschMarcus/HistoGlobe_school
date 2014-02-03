#include HiventHandle.coffee

window.HG ?= {}

class HG.HiventMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, parentDiv) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onDestruction"

    @parentDiv = parentDiv

    @_hiventHandle = hiventHandle
    # @_hiventInfo = document.createElement("div")
    # @_hiventInfo.class = "btn btn-default"
    # @_hiventInfo.style.position = "absolute"
    # @_hiventInfo.style.left = "0px"
    # @_hiventInfo.style.top = "0px"
    # @_hiventInfo.style.visibility = "hidden"
    # @_hiventInfo.style.pointerEvents = "none"

    # if @parentDiv
    #   @parentDiv.appendChild @_hiventInfo

    # hivent = @_hiventHandle.getHivent()

    # $(@_hiventInfo).tooltip {title: "#{hivent.displayDate}<br />#{hivent.name}", html:true, placement: "top", container:"body"}

    @_popover = null

  # ============================================================================
  getHiventHandle: ->
    @_hiventHandle

  # ============================================================================
  showHiventName: (displayPosition) =>
    @_hiventInfo.style.left = displayPosition.x + "px"
    @_hiventInfo.style.top = displayPosition.y + "px"
    $(@_hiventInfo).tooltip "show"

  # ============================================================================
  hideHiventName: (displayPosition) =>
    $(@_hiventInfo).tooltip "hide"

  # ============================================================================
  showHiventInfo: (displayPosition) =>
    @_popover ?= new HG.HiventInfoPopover @_hiventHandle, new HG.Vector(0, 0), HG.Display.CONTAINER
    @_updatePopoverAnchor displayPosition
    @_popover.positionWindowAtAnchor()
    @_popover.show()

  # ============================================================================
  hideHiventInfo: (displayPosition) =>
    @_popover?.hide()


  # ============================================================================
  enableShowInfo: ->
    @_hiventHandle.onActive(@, @showHiventInfo)
    @_hiventHandle.onInActive(@, @hideHiventInfo)


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _updatePopoverAnchor: (position)->
    @_popover?.setAnchor new HG.Vector(position.x, position.y)

  # ============================================================================
  _destroyMarker: =>
    @_popover?._destroy()
    # @_hiventInfo.parentNode.removeChild @_hiventInfo
    @notifyAll "onDestruction"

