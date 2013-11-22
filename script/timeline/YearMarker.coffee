window.HG ?= {}

class HG.YearMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (date, pos, parentDiv) ->
    @_date = date
    @_pos = pos
    @_parentDiv = parentDiv
    #@_width = width

    # create HTML div
    @_yearMarkerDiv = document.createElement "div"
    @_yearMarkerDiv.id = "year" + @_date.getFullYear()
    @_yearMarkerDiv.className = "yearMarker"
    @_yearMarkerDiv.style.left = @_pos + "px"    
    @_yearMarkerDiv.innerHTML = '<p>'+@_date.getFullYear()+'</p>'

    # add to DOM
    @_parentDiv.appendChild @_yearMarkerDiv

    # show year marker with nice fade in effect from jQuery
    $(@_yearMarkerDiv).fadeIn(400)

  # ============================================================================
  ###setDate : (date) ->
    @_date = date
    @_yearMarkerDiv.innerHTML = '<p>'+ @_date +'</p>'###

  setPos : (pos) ->
    @_pos = pos
    @_yearMarkerDiv.style.left = @_pos + "px"

  setWidth : (width) ->
    @_yearMarkerDiv.style.width = width + "px"

  moveTo : (time, pos) ->
    @_pos = pos
    $(@_yearMarkerDiv).animate({
      left: pos + "px",
    }, time );

  getDiv : () -> @_yearMarkerDiv
  getPos : () -> @_pos
  getDate : () -> @_date

  getWidth : () -> width = @_yearMarkerDiv.offsetWidth

  highlight: (step) ->
    if step == 2
      @_yearMarkerDiv.className = "yearMarkerH2"
    if step == 1
      @_yearMarkerDiv.className = "yearMarkerH1"
    if step == 0
      @_yearMarkerDiv.className = "yearMarker"      

  destroy : () ->
    $(@_yearMarkerDiv).fadeOut(400, `function() { $(this).remove(); }`);

