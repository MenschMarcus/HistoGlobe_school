window.HG ?= {}

class HG.YearMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (date, pos, parentDiv, width) ->
    @_date = date
    @_pos = pos
    @_parentDiv = parentDiv
    @_width = width

    # create HTML div
    @_yearMarkerDiv = document.createElement "div"
    @_yearMarkerDiv.id = "year" + @_date.getFullYear()
    @_yearMarkerDiv.className = "yearMarker"
    @_yearMarkerDiv.style.left = @_pos + "px"
    @_yearMarkerDiv.style.width = @_width + "px"
    @_yearMarkerDiv.innerHTML = '<p>'+@_date.getFullYear()+'</p>'

    # add to DOM
    @_parentDiv.appendChild @_yearMarkerDiv

    # show year marker with nice fade in effect from jQuery
    $(@_yearMarkerDiv).fadeIn()

  # ============================================================================
  ###setDate : (date) ->
    @_date = date
    @_yearMarkerDiv.innerHTML = '<p>'+ @_date +'</p>'###

  setPos : (pos) ->
    @_pos = pos
    @_yearMarkerDiv.style.left = @_pos + "px"

  moveTo : (time, pos) ->
    @_pos = pos
    $(@_yearMarkerDiv).animate({
      left: pos + "px",
    }, time );

  getDiv : () -> @_yearMarkerDiv
  getPos : () -> @_pos
  getDate : () -> @_date

  destroy : () ->
    $(@_yearMarkerDiv).fadeOut()
    @_parentDiv.removeChild @_yearMarkerDiv
