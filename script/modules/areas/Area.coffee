window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (geoJson, areaStyler) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShow"
    @addCallback "onHide"
    @addCallback "onStyleChange"

    @_areaStyler = areaStyler

    # load area data
    @_initData geoJson


  # ============================================================================
  getGeometry: ->     @_geometry
  getLabel: ->        @_name
  getLabelLatLng: ->  @_labelLatLng
  getLabelDir: ->     @_labelDir
  getNormalStyle: ->  @_style
  getCategories: ->   @_categories
  isActive:()->       true
  # isActive:()->       @_active


  # ============================================================================
  setDate: (date) ->

    # preparing comparison:
    # old and new nowDates and active states
    oldDate = @_now
    newDate = date

    oldActive = @_active
    newActive = @isActive()

    # change? -> became active/inactive
    becameActive = newActive and not oldActive
    becameInactive = oldActive and not newActive

    if becameActive
      @notifyAll "onShow", @

    if becameInactive
      @notifyAll "onHide", @

    # set new active state and now date
    @_active = newActive
    @_now = newDate

    if @_active and @_areaStyler?
      style = @_areaStyler.getStyle @, newDate

      a =  JSON.stringify @_style
      b =  JSON.stringify style

      if style? and (becameActive or a != b)
        @_style = style
        @notifyAll "onStyleChange", @

  # ============================================================================
  setActive: (active) ->
    @_active = active


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initData: (geoJson) ->

    ## id
    # @_state       = geoJson.properties.iso_a3
    # old! iso_a3 not suitable for historic countries, because it is hard to always come up with three letters for a country
    # => introduce a "country_id" in geojson, which is a 3 (current country) or 4 (historic country) letter country code
    @_state       = geoJson.properties.country_id

    ## geometry (polygons)
    data = L.GeoJSON.geometryToLayer geoJson
    @_geometry        = []
    if geoJson.geometry.type is "Polygon"
      @_geometry.push data._latlngs
    else if geoJson.geometry.type is "MultiPolygon"
      for id, layer of data._layers
        @_geometry.push layer._latlngs

    ## label
    @_name        = geoJson.properties.name_de_shrt
    @_labelLatLng = geoJson.properties.label_lat_lng
    @_labelDir    = geoJson.properties.label_dir

    @_maxLatLng = [-180, -90]
    @_minLatLng = [ 180,  90]

    # if label position not given -> calculate it
    unless @_labelLatLng?

      # only take largest subpart of the area into account
      maxIndex = 0
      for area, i in @_geometry
        if area.length > @_geometry[maxIndex].length
          maxIndex = i

      # calculate label position based on largest subpart
      if  @_geometry[maxIndex].length > 0
        labelLatLng = [0,0]  # final position [lat, lng]

        # position = center of bounding box of polygon
        for coords in @_geometry[maxIndex]
          labelLatLng[0] += coords.lat
          labelLatLng[1] += coords.lng

          if coords.lat > @_maxLatLng[0] then @_maxLatLng[0] = coords.lat
          if coords.lat < @_minLatLng[0] then @_minLatLng[0] = coords.lat
          if coords.lng > @_maxLatLng[1] then @_maxLatLng[1] = coords.lng
          if coords.lng < @_minLatLng[1] then @_minLatLng[1] = coords.lng

        labelLatLng[0] /= @_geometry[maxIndex].length
        labelLatLng[1] /= @_geometry[maxIndex].length

        @_labelLatLng = labelLatLng

    ## categories
    @_categories = geoJson.properties.categories

    ## style
    @_style = @_areaStyler.getFallbackStyle @

    ## current date and active state
    @_now = new Date(2000, 0, 1)
    @_active = false
