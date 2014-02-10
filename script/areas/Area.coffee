window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (geoJson, indicator) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShow"
    @addCallback "onHide"
    @addCallback "onStyleChange"

    @_indicator = indicator
    @_initData(geoJson)
    @_initMembers()

  # ============================================================================
  getData: ->
    @_data

  # ============================================================================
  getLabel: ->
    @_name

  # ============================================================================
  getLabelLatLng: ->
    @_labelLatLng

  # ============================================================================
  getNormalStyle: ->
    style =
      fillColor:    @_color
      color:        "#666"
      weight:       1
      fillOpacity:  0.4
      opacity:      1
      noClip:       true
      smoothFactor: 1.0

  # ============================================================================
  setDate: (newDate) ->

    oldDate = @_now
    @_now = newDate

    oldActive = @_active
    @_active = @_isActive()

    if @_active and not oldActive
      @notifyAll "onShow", @

    if not @_active and oldActive
      @notifyAll "onHide", @

    if @_active and @_indicator?
      color = @_indicator.getColor @_iso_a2, newDate.getFullYear()
      if color?
        @_color = color
        @notifyAll "onStyleChange", @

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initData: (geoJson) ->
    @_data      = []
    @_state     = geoJson.properties.sov_a3
    @_name      = geoJson.properties.name
    # @_name      = geoJson.properties.name_de + "<br /><span class='leaflet-label-small'>(" + geoJson.properties.name_orig + ")</span>"
    @_iso_a2    = geoJson.properties.iso_a2

    @_maxLatLng = [-180, -90]
    @_minLatLng = [ 180,  90]

    data = L.GeoJSON.geometryToLayer geoJson

    if geoJson.geometry.type is "Polygon"
      @_data.push data._latlngs
    else if geoJson.geometry.type is "MultiPolygon"
      for id, layer of data._layers
        @_data.push layer._latlngs

    # calculate label position
    maxIndex = 0
    for area, i in @_data
      if area.length > @_data[maxIndex].length
        maxIndex = i

    if  @_data[maxIndex].length > 0

      @_labelLatLng = [0,0]

      for coords in @_data[maxIndex]
        @_labelLatLng[0] += coords.lat
        @_labelLatLng[1] += coords.lng

        if coords.lat > @_maxLatLng[0] then @_maxLatLng[0] = coords.lat
        if coords.lat < @_minLatLng[0] then @_minLatLng[0] = coords.lat
        if coords.lng > @_maxLatLng[1] then @_maxLatLng[1] = coords.lng
        if coords.lng < @_minLatLng[1] then @_minLatLng[1] = coords.lng

      @_labelLatLng[0] /= @_data[maxIndex].length
      @_labelLatLng[1] /= @_data[maxIndex].length


  # ============================================================================
  _initMembers: ->

    @_color = "#D2CDC3"

    @_start =
      "DEU": new Date(1990, 10, 3)

      "BIH": new Date(1991, 1, 1)
      "BLR": new Date(1991, 1, 1)
      "EST": new Date(1991, 1, 1)
      "HRV": new Date(1991, 1, 1)
      "LTU": new Date(1991, 1, 1)
      "LVA": new Date(1991, 1, 1)
      "MDA": new Date(1991, 1, 1)
      "MKD": new Date(1991, 1, 1)
      "SBM_2": new Date(1991, 1, 1)
      "SVN": new Date(1991, 1, 1)
      "UKR": new Date(1991, 1, 1)

      "CZE": new Date(1993, 1, 1)
      "SVK": new Date(1993, 1, 1)

      "MNE": new Date(2006, 6, 8)
      "SEB_2": new Date(2006, 6, 8)

      "KOS": new Date(2008, 2, 17)
      "SRB": new Date(2008, 2, 17)


    @_end =
      "DDR_2": new Date(1990, 10, 3)
      "GER_2": new Date(1990, 10, 3)

      "YUG_2": new Date(1991, 1, 1)

      "CZE_2": new Date(1993, 1, 1)

      "SBM_2": new Date(2006, 6, 8)

      "SEB_2": new Date(2008, 2, 17)

    @_now = new Date(2000, 1, 1)
    @_active = false

  # ============================================================================
  _isActive: () =>

    if not @_start[@_state]? and not @_end[@_state]?
      return true

    if @_start[@_state]? and @_end[@_state]?
      return @_start[@_state] < @_now and @_now < @_end[@_state]

    if @_start[@_state]? and @_start[@_state] < @_now
      return true

    if @_end[@_state]? and @_end[@_state] > @_now
      return true

    false

    # true
