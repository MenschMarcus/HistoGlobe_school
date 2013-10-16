window.HG ?= {}

class HG.YearMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (year, pos, parentDiv) ->
    @_parentDiv = parentDiv
    @_year = year
    @_pos = pos

    # create HTML div
    @_yearMarkerDiv = document.createElement "div"
    @_yearMarkerDiv.id = "year" + @_year
    @_yearMarkerDiv.className = "yearMarker"
    @_yearMarkerDiv.style.left = @_pos + "px"
    @_yearMarkerDiv.innerHTML = '<p>'+@_year+'</p>'

    # add to DOM
    @_parentDiv.append @_yearMarkerDiv

  # ============================================================================
  destroy : () ->
    @_parentDiv.removeChild @_yearMarkerDiv
