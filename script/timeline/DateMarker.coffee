window.HG ?= {}

class HG.DateMarker

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (date, pos, parentDiv) ->
    @_date = date
    @_pos = pos
    @_parentDiv = parentDiv
    #@_width = width

    # create HTML div
    @_dateMarkerDiv = document.createElement "div"
    @_dateMarkerDiv.id = "date" + @_date.getFullYear() + "/" + (@_date.getMonth + 1) + "/" + @_date.getDate()
    @_dateMarkerDiv.className = "dateMarker"
    @_dateMarkerDiv.style.left = @_pos + "px"
    @_dateMarkerDiv.innerHTML = '<p>'+ @_date.getFullYear() + "/" + (@_date.getMonth + 1) + "/" + @_date.getDate() + '</p>'

    # add to DOM
    @_parentDiv.appendChild @_dateMarkerDiv

    # show year marker with nice fade in effect from jQuery
    $(@_dateMarkerDiv).fadeIn(400)

  # ============================================================================
  ###setDate : (date) ->
    @_date = date
    @_dateMarkerDiv.innerHTML = '<p>'+ @_date +'</p>'###

  setPos : (pos) ->
    @_pos = pos
    @_dateMarkerDiv.style.left = @_pos + "px"

  setWidth : (width) ->
    @_dateMarkerDiv.style.width = width + "px"

  moveTo : (time, pos) ->
    @_pos = pos
    $(@_dateMarkerDiv).animate({
      left: pos + "px",
    }, time );

  getDiv : () -> @_dateMarkerDiv
  getPos : () -> @_pos
  getDate : () -> @_date

  getWidth : () -> width = @_dateMarkerDiv.offsetWidth

  highlight: (step) ->
    if step == 2
      @_dateMarkerDiv.className = "dateMarkerH2"
    if step == 1
      @_dateMarkerDiv.className = "dateMarkerH1"
    if step == 0
      @_dateMarkerDiv.className = "dateMarker"

  destroy : () ->
    $(@_dateMarkerDiv).fadeOut(400, `function() { $(this).remove(); }`);

