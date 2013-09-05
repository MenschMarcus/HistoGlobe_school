window.HG ?= {}

class HG.Area

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (geoJson) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShow"
    @addCallback "onHide"
    @addCallback "onStyleChange"

    @_initData(geoJson)
    @_initMembers()

  # ============================================================================
  getData: ->
    @_data

  # ============================================================================
  getLabel: ->
    @_name

  # ============================================================================
  getNormalStyle: ->
    style =
      fillColor:    @_getColor()
      color:        "#666"
      weight:       2
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

    if @_active and @_styleChangesBetween oldDate, newDate
      @notifyAll "onStyleChange", @

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initData: (geoJson) ->
    @_data = []
    @_state = geoJson.properties.sov_a3
    @_name = geoJson.properties.name

    data = L.GeoJSON.geometryToLayer geoJson

    if geoJson.geometry.type is "Polygon"
      @_data.push data._latlngs
    else if geoJson.geometry.type is "MultiPolygon"
      for id, layer of data._layers
        @_data.push layer._latlngs

  # ============================================================================
  _initMembers: ->

    @_eu =
      "AUT": new Date(1995, 1, 1)
      "BEL": new Date(1958, 1, 1)
      "BGR": new Date(2007, 1, 1)
      "CYP": new Date(2004, 5, 1)
      "CZE": new Date(2004, 5, 1)
      "DEU": new Date(1958, 1, 1)
      "DN1": new Date(1973, 1, 1)
      "ESP": new Date(1986, 1, 1)
      "EST": new Date(2004, 5, 1)
      "FI1": new Date(1995, 1, 1)
      "FR1": new Date(1958, 1, 1)
      "GB1": new Date(1973, 1, 1)
      "GER_2": new Date(1958, 1, 1)
      "GRC": new Date(1981, 1, 1)
      "HRV": new Date(2013, 7, 1)
      "HUN": new Date(2004, 5, 1)
      "IRL": new Date(1973, 1, 1)
      "ITA": new Date(1958, 1, 1)
      "LTU": new Date(2004, 5, 1)
      "LUX": new Date(1958, 1, 1)
      "LVA": new Date(2004, 5, 1)
      "MLT": new Date(2004, 5, 1)
      "NL1": new Date(1958, 1, 1)
      "POL": new Date(2004, 5, 1)
      "PRT": new Date(1986, 1, 1)
      "ROU": new Date(2007, 1, 1)
      "SVK": new Date(2004, 5, 1)
      "SVN": new Date(2004, 5, 1)
      "SWE": new Date(1995, 1, 1)

    @_euro =
      "AUT": new Date(1999, 1, 1)
      "BEL": new Date(1999, 1, 1)
      "CYP": new Date(2008, 1, 1)
      "DEU": new Date(1999, 1, 1)
      "ESP": new Date(1999, 1, 1)
      "EST": new Date(2011, 1, 1)
      "FI1": new Date(1999, 1, 1)
      "FR1": new Date(1999, 1, 1)
      "GRC": new Date(2001, 1, 1)
      "IRL": new Date(1999, 1, 1)
      "ITA": new Date(1999, 1, 1)
      "LUX": new Date(1999, 1, 1)
      "MLT": new Date(2008, 1, 1)
      "NL1": new Date(1999, 1, 1)
      "PRT": new Date(1999, 1, 1)
      "SVK": new Date(2009, 1, 1)
      "SVN": new Date(2007, 1, 1)

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

  # ============================================================================
  _getColor: () =>

    if @_euro[@_state]? and @_euro[@_state] < @_now then return "#464BAE"
    if @_eu[@_state]? and @_eu[@_state] < @_now     then return "#4B83B5"

    "#D2CDC3"

  # ============================================================================
  _styleChangesBetween: (dateA, dateB) ->
    date = @_eu[@_state]
    if dateA < date <= dateB or dateA >= date > dateB
      return true

    date = @_euro[@_state]
    if dateA < date <= dateB or dateA >= date > dateB
      return true

    false
