window.HG ?= {}

class HG.YearMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (year, pos, parentDiv, width) ->
    @_year = year
    @_pos = pos - width/2
    @_parentDiv = parentDiv
    @_width = width

    # create HTML div
    @_yearMarkerDiv = document.createElement "div"
    @_yearMarkerDiv.id = "year" + @_year
    @_yearMarkerDiv.className = "yearMarker"
    @_yearMarkerDiv.style.left = @_pos + "px"
    @_yearMarkerDiv.style.width = @_width + "px"
    @_yearMarkerDiv.innerHTML = '<p>'+@_year+'</p>'

    # add to DOM
    @_parentDiv.appendChild @_yearMarkerDiv

    # show year marker with nice fade in effect from jQuery
    $(@_yearMarkerDiv).fadeIn()

  # ============================================================================
  setYear : (year) ->
    @_year = year
    @_yearMarkerDiv.innerHTML = '<p>'+@_year+'</p>'

  setPos : (pos) ->
    @_pos = pos
    @_yearMarkerDiv.style.left = @_pos + "px"

  getDiv : () -> @_yearMarkerDiv
  getPos : () -> @_pos
  getYear : () -> @_year
  destroy : () -> @_parentDiv.removeChild @_yearMarkerDiv
