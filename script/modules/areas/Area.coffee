window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (geoJson, area_styler) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShow"
    @addCallback "onHide"
    @addCallback "onStyleChange"

    @_area_styler = area_styler
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
  getLabelDir: ->
    @_labelDir

  # ============================================================================
  getNormalStyle: ->
    @_style

  # ============================================================================
  getCategories: ->
    @_categories


  # ============================================================================
  setDate: (newDate) ->

    oldDate = @_now
    @_now = newDate

    new_active = @isActive()

    if new_active and not @_active
      @notifyAll "onShow", @

    if not new_active and @_active
      @notifyAll "onHide", @

    became_active = not @_active and new_active

    @_active = new_active

    if @_active and @_area_styler?
      style = @_area_styler.getStyle @, newDate

      a =  JSON.stringify @_style
      b =  JSON.stringify style

      if style? and (became_active or a != b)
        @_style = style
        console.log "TELL ME"
        @notifyAll "onStyleChange", @

  # ============================================================================
  isActive:()->
    return true

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initData: (geoJson) ->
    @_data        = []
    # @_state       = geoJson.properties.iso_a3
    # old! iso_a3 not suitable for historic countries, because it is hard to always come up with three letters for a country
    # => introduce a "country_id" in geojson, which is a 3 (current country) or 4 (historic country) letter country code

    @_state       = geoJson.properties.country_id
    @_name        = geoJson.properties.name_de
    @_labelLatLng = geoJson.properties.label_lat_long
    @_labelDir    = geoJson.properties.label_dir

    @_categories = geoJson.properties.categories

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

      labelLatLng = [0,0]

      for coords in @_data[maxIndex]
        labelLatLng[0] += coords.lat
        labelLatLng[1] += coords.lng

        if coords.lat > @_maxLatLng[0] then @_maxLatLng[0] = coords.lat
        if coords.lat < @_minLatLng[0] then @_minLatLng[0] = coords.lat
        if coords.lng > @_maxLatLng[1] then @_maxLatLng[1] = coords.lng
        if coords.lng < @_minLatLng[1] then @_minLatLng[1] = coords.lng

      labelLatLng[0] /= @_data[maxIndex].length
      labelLatLng[1] /= @_data[maxIndex].length

      unless @_labelLatLng?
        @_labelLatLng = labelLatLng

  # ============================================================================
  _initMembers: ->

    @_style = @_area_styler.getFallbackStyle @

    @_now = new Date(2000, 0, 1)
    @_active = false

