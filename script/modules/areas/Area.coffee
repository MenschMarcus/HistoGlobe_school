window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (id, geometry, startDate, endDate, type) ->

    # HG.mixin @, HG.CallbackContainer
    # HG.CallbackContainer.call @

    # @addCallback "onShow"
    # @addCallback "onHide"

    # init necessary area data
    @_id        = id
    @_geometry  = geometry
    @_startDate = startDate
    @_endDate   = endDate
    @_type      = type

  # ============================================================================
  getId: ->           @_id
  getName: ->         @_name
  getLabelPos: ->     @_labelPos
  getStartDate: ->    @_startDate
  getendDate: ->      @_endDate
  getGeometry: ->     @_geometry
  getType: ->         @_type
  isActive: ->        @_active


  # ============================================================================
  # set the label of the area only with a name given
  setLabel: (name) ->
    @_name = name
    @_labelPos = @_calcLabelPos()

  # ============================================================================
  # set label of the area with name and position
  setLabelWithPos: (name, labelPos) ->
    @_name = name
    @_labelPos = labelPos

  # ============================================================================
  setActive: () ->
    @_active = yes

  # ============================================================================
  setInactive: () ->
    @_active = no



  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _calcLabelPos: () ->

    minLat = 180
    minLng = 90
    maxLat = -180
    maxLng = -90

    # only take largest subpart of the area into account
    maxIndex = 0
    for area, i in @_geometry
      if area.length > @_geometry[maxIndex].length
        maxIndex = i

    # calculate label position based on largest subpart
    if  @_geometry[maxIndex].length > 0
      # final position [lat, lng]
      labelLat = 0
      labelLng = 0

      # position = center of bounding box of polygon
      for coords in @_geometry[maxIndex]
        labelLat += coords.lat
        labelLng += coords.lng

        if coords.lat < minLat then minLat = coords.lat
        if coords.lat > maxLat then maxLat = coords.lat
        if coords.lng < minLng then minLng = coords.lng
        if coords.lng > maxLng then maxLng = coords.lng

      labelLat /= @_geometry[maxIndex].length
      labelLng /= @_geometry[maxIndex].length

      [labelLat, labelLng]
