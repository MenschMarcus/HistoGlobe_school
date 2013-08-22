#include Hivent.coffee
#include Display.coffee
#include Vector.coffee

window.HG ?= {}

class HG.HiventInfoPopover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hivent, anchor, parentDiv) ->

    @_hivent = hivent
    @_parentDiv = parentDiv
    @_anchor = anchor

    @_mainDiv = document.createElement "div"
    @_mainDiv.id = "hiventInfoPopover"
    @_mainDiv.style.position = "absolute"
    @_mainDiv.style.left = "#{anchor.at(0) + WINDOW_TO_ANCHOR_OFFSET_X}px"
    @_mainDiv.style.top = "#{anchor.at(1) + WINDOW_TO_ANCHOR_OFFSET_Y}px"
    @_mainDiv.style.width = "#{BODY_DEFAULT_WIDTH}px"
    @_mainDiv.style.height = "#{BODY_DEFAULT_HEIGHT}px"
    @_mainDiv.style.zIndex = "#{HG.Display.Z_INDEX + 2}"
    @_mainDiv.addEventListener 'mousedown', @_onMouseDown, false

    @_titleDiv = document.createElement "div"
    @_titleDiv.id = "hiventInfoPopoverTitle"
    @_titleDiv.innerHTML = "title"
    @_titleDiv.style.backgroundColor = "#ccc"
    @_titleDiv.style.height = "#{TITLE_DEFAULT_HEIGHT}px"

    @_closeDiv = document.createElement "div"
    @_closeDiv.id = "hiventInfoPopoverClose"
    @_closeDiv.innerHTML = "X"
    @_closeDiv.style.backgroundColor = "#eee"
    @_closeDiv.style.styleFloat = "right"
    @_closeDiv.style.cssFloat = "right"
    @_closeDiv.addEventListener 'mouseup', @hide, false

    @_bodyDiv = document.createElement "div"
    @_bodyDiv.id = "hiventInfoPopoverBody"
    @_bodyDiv.innerHTML = "body"
    @_bodyDiv.style.backgroundColor = "#fff"
    @_bodyDiv.style.height = "100%"


    @_titleDiv.appendChild @_closeDiv
    @_mainDiv.appendChild @_titleDiv
    @_mainDiv.appendChild @_bodyDiv

    @_centerPos = new HG.Vector 0, 0
    @_updateCenterPos()

    @_raphael = Raphael @_parentDiv, @_parentDiv.offsetWidth, @_parentDiv.offsetHeight
    @_raphael.canvas.style.position = "absolute"
    @_raphael.canvas.style.zIndex = "#{HG.Display.Z_INDEX + 1}"
    @_raphael.canvas.style.pointerEvents = "none"

    @_arrow = @_raphael.path ""
    @_updateArrow()

    @_lastMousePos = null
    @_addedToDOM = false

  # ============================================================================
  show: =>
    unless @_addedToDOM
      document.getElementsByTagName("body")[0].appendChild @_mainDiv
      @_addedToDOM = true
    @_mainDiv.style.visibility = "visible"
    @_arrow.show()

  # ============================================================================
  hide: =>
    @_mainDiv.style.visibility = "hidden"
    @_arrow.hide()

  # ============================================================================
  setAnchor: (anchor) ->
    @_anchor = anchor
    @_updateArrow()

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _updateCenterPos: ->
    @_centerPos = new HG.Vector(@_mainDiv.offsetLeft + @_mainDiv.offsetWidth/2 -
                                @_parentDiv.parentNode.offsetLeft + ARROW_ROOT_OFFSET_X,
                                @_mainDiv.offsetTop  + @_mainDiv.offsetHeight/2 -
                                @_parentDiv.parentNode.offsetTop + ARROW_ROOT_OFFSET_Y)

  # ============================================================================
  _updateArrow: ->
    centerToAnchor = @_anchor.clone()
    centerToAnchor.sub @_centerPos
    centerToAnchor.normalize()
    ortho = new HG.Vector -centerToAnchor.at(1), centerToAnchor.at(0)
    ortho.mulScalar ARROW_ROOT_WIDTH/2
    arrowRight = @_centerPos.clone()
    arrowRight.add ortho
    arrowLeft = @_centerPos.clone()
    arrowLeft.sub ortho

    @_arrow.attr "path", "M #{@_centerPos.at 0} #{@_centerPos.at 1}
                          L #{arrowRight.at 0} #{arrowRight.at 1}
                          L #{@_anchor.at 0} #{@_anchor.at 1}
                          L #{arrowLeft.at 0} #{arrowLeft.at 1}
                          Z"
    @_arrow.attr "fill", "#fff"
    @_arrow.attr "stroke", "#fff"


  # ============================================================================
  _onMouseDown: (event) =>
    @_mainDiv.addEventListener 'mousemove', @_onMouseMove, false
    @_mainDiv.addEventListener 'mouseup', @_onMouseUp, false
    @_mainDiv.addEventListener 'mouseout', @_onMouseOut, false
    event.preventDefault()

  # ============================================================================
  _onMouseUp: (event) =>
    @_mainDiv.removeEventListener 'mousemove', @_onMouseMove, false
    @_mainDiv.removeEventListener 'mouseup', @_onMouseUp, false
    @_mainDiv.removeEventListener 'mouseout', @_onMouseOut, false
    @_lastMousePos = null

  # ============================================================================
  _onMouseMove: (event) =>
    currentMousePos = new HG.Vector event.clientX, event.clientY

    @_lastMousePos ?= currentMousePos

    currentDivPos = $(@_mainDiv).offset()
    $(@_mainDiv).offset {
                     left: currentDivPos.left + (currentMousePos.at(0) - @_lastMousePos.at(0))
                     top:  currentDivPos.top + (currentMousePos.at(1) - @_lastMousePos.at(1))
                    }

    @_updateCenterPos()
    @_updateArrow()
    @_lastMousePos = currentMousePos

  # ============================================================================
  _onMouseOut: (event) =>
    @_mainDiv.removeEventListener 'mousemove', @_onMouseMove, false
    @_mainDiv.removeEventListener 'mouseup', @_onMouseUp, false
    @_mainDiv.removeEventListener 'mouseout', @_onMouseOut, false
    @_lastMousePos = null

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  ARROW_ROOT_WIDTH = 20
  ARROW_ROOT_OFFSET_X = 0
  ARROW_ROOT_OFFSET_Y = 60
  WINDOW_TO_ANCHOR_OFFSET_X = 30
  WINDOW_TO_ANCHOR_OFFSET_Y = -140
  BODY_DEFAULT_WIDTH = 150
  BODY_DEFAULT_HEIGHT = 150
  TITLE_DEFAULT_HEIGHT = 20
