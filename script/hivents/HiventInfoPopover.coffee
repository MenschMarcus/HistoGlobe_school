#include Hivent.coffee
#include Display.coffee

window.HG ?= {}

class HG.HiventInfoPopover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hivent, parentDiv) ->

    @_hivent = hivent
    @_parentDiv = parentDiv
    @_anchor = {x: 200, y: 200}

    @_mainDiv = document.createElement "div"
    @_mainDiv.id = "hiventInfoPopover"
    @_mainDiv.style.position = "absolute"
    @_mainDiv.style.left = "600px"
    @_mainDiv.style.top = "200px"
    @_mainDiv.style.width = "150px"
    @_mainDiv.style.height = "150px"
    @_mainDiv.style.zIndex = "#{HG.Display.Z_INDEX + 2}"
    @_mainDiv.addEventListener 'mousedown', @onMouseDown, false

    @_titleDiv = document.createElement "div"
    @_titleDiv.id = "hiventInfoPopoverTitle"
    @_titleDiv.innerHTML = "title"
    @_titleDiv.style.backgroundColor = "#ccc"
    @_titleDiv.style.height = "20px"

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

    document.getElementsByTagName("body")[0].appendChild @_mainDiv

    @_centerPos = {
                    x: @_mainDiv.offsetLeft + @_mainDiv.offsetWidth/2 - @_parentDiv.parentNode.offsetLeft
                    y: @_mainDiv.offsetTop  + @_mainDiv.offsetHeight/2 - @_parentDiv.parentNode.offsetTop
                  }

    @_raphael = Raphael @_parentDiv, @_parentDiv.offsetWidth, @_parentDiv.offsetHeight
    @_raphael.canvas.style.position = "absolute"
    @_raphael.canvas.style.zIndex = "#{HG.Display.Z_INDEX + 3}"
    @_raphael.canvas.style.pointerEvents = "none"
    console.log @_parentDiv
    @_pointer = @_raphael.path "M #{@_centerPos.x} #{@_centerPos.y}
                                L #{@_anchor.x} #{@_anchor.y}"
    @_pointer.attr "fill", "#fff"
    @_pointer.attr "stroke", "#000"

    @_lastMousePos = null

  # ============================================================================
  onMouseDown: (event) =>
    @_mainDiv.addEventListener 'mousemove', @onMouseMove, false
    @_mainDiv.addEventListener 'mouseup', @onMouseUp, false
    @_mainDiv.addEventListener 'mouseout', @onMouseOut, false
    event.preventDefault()

  # ============================================================================
  onMouseUp: (event) =>
    @_mainDiv.removeEventListener 'mousemove', @onMouseMove, false
    @_mainDiv.removeEventListener 'mouseup', @onMouseUp, false
    @_mainDiv.removeEventListener 'mouseout', @onMouseOut, false
    @_lastMousePos = null

  # ============================================================================
  onMouseMove: (event) =>
    currentMousePos = {
                        x: event.clientX
                        y: event.clientY
                      }

    @_lastMousePos ?= currentMousePos

    currentDivPos = $(@_mainDiv).offset()
    $(@_mainDiv).offset {
                     left: currentDivPos.left + (currentMousePos.x - @_lastMousePos.x)
                     top:  currentDivPos.top + (currentMousePos.y - @_lastMousePos.y)
                    }

    @_lastMousePos = currentMousePos

  # ============================================================================
  onMouseOut: (event) =>
    @_mainDiv.removeEventListener 'mousemove', @onMouseMove, false
    @_mainDiv.removeEventListener 'mouseup', @onMouseUp, false
    @_mainDiv.removeEventListener 'mouseout', @onMouseOut, false
    @_lastMousePos = null

  # ============================================================================
  show: =>
    @_mainDiv.style.visibility = "visible"

  # ============================================================================
  hide: =>
    @_mainDiv.style.visibility = "hidden"


