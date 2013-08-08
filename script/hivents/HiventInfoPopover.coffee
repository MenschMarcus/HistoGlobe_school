#include Hivent.coffee

window.HG ?= {}

class HG.HiventInfoPopover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hivent) ->

    @_hivent = hivent

    @_parentDiv = document.createElement "div"
    @_parentDiv.id = "hiventInfoPopover"
    @_parentDiv.style.position = "absolute"
    @_parentDiv.style.left = "600px"
    @_parentDiv.style.top = "200px"
    @_parentDiv.style.width = "150px"
    @_parentDiv.style.height = "150px"

    @_titleDiv = document.createElement "div"
    @_titleDiv.id = "hiventInfoPopoverTitle"
    @_titleDiv.innerHTML = "title"
    @_titleDiv.style.backgroundColor = "#ccc"

    @_closeDiv = document.createElement "div"
    @_closeDiv.id = "hiventInfoPopoverClose"
    @_closeDiv.innerHTML = "X"
    @_closeDiv.style.backgroundColor = "#eee"
    @_closeDiv.style.float = "right"
    @_closeDiv.addEventListener 'mouseup', @hide, false

    @_bodyDiv = document.createElement "div"
    @_bodyDiv.id = "hiventInfoPopoverBody"
    @_bodyDiv.innerHTML = "body"
    @_bodyDiv.style.backgroundColor = "#fff"
    @_bodyDiv.style.height = "100%"

    @_titleDiv.appendChild @_closeDiv
    @_parentDiv.appendChild @_titleDiv
    @_parentDiv.appendChild @_bodyDiv
    document.getElementsByTagName("body")[0].appendChild @_parentDiv

    @_titleDiv.addEventListener 'mousedown', @onMouseDown, false

    @_lastMousePos = null

  # ============================================================================
  onMouseDown: (event) =>
    @_titleDiv.addEventListener 'mousemove', @onMouseMove, false
    @_titleDiv.addEventListener 'mouseup', @onMouseUp, false
    @_titleDiv.addEventListener 'mouseout', @onMouseOut, false
    event.preventDefault()

  # ============================================================================
  onMouseUp: (event) =>
    @_titleDiv.removeEventListener 'mousemove', @onMouseMove, false
    @_titleDiv.removeEventListener 'mouseup', @onMouseUp, false
    @_titleDiv.removeEventListener 'mouseout', @onMouseOut, false
    @_lastMousePos = null

  # ============================================================================
  onMouseMove: (event) =>
    currentMousePos = {
                        x: event.clientX
                        y: event.clientY
                      }

    @_lastMousePos ?= currentMousePos

    currentDivPos = $(@_parentDiv).offset()
    $(@_parentDiv).offset {
                     left: currentDivPos.left + (currentMousePos.x - @_lastMousePos.x)
                     top:  currentDivPos.top + (currentMousePos.y - @_lastMousePos.y)
                    }

    @_lastMousePos = currentMousePos

  # ============================================================================
  onMouseOut: (event) =>
    @_titleDiv.removeEventListener 'mousemove', @onMouseMove, false
    @_titleDiv.removeEventListener 'mouseup', @onMouseUp, false
    @_titleDiv.removeEventListener 'mouseout', @onMouseOut, false
    @_lastMousePos = null

  # ============================================================================
  show: =>
    @_parentDiv.style.visibility = "visible"

  # ============================================================================
  hide: =>
    @_parentDiv.style.visibility = "hidden"


