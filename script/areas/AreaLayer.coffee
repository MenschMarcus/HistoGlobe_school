window.HG ?= {}

class HG.AreaLayer

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->
    $.getJSON "data/geo.json", (statesData) =>
      @_data = statesData

      for callback in @_onAreaLoadedCallbacks
        callback this

    @_initMembers()

  # ============================================================================
  getData: ->
    @_data

  # ============================================================================
  getNormalStyle: ->
    normalStyle = (feature) =>
      fillColor:    @_getColor(feature.properties.sov_a3)
      weight:       0
      opacity:      0
      fillOpacity:  0.2

  # ============================================================================
  getHighlightStyle: ->
    highlightStyle =
      weight:       0
      opacity:      0
      fillOpacity:  0.5

  # ============================================================================
  setDate: (newDate) ->

    oldDate = @_now
    @_now = newDate

    if @_somethingChangesBetween oldDate, newDate
      for callback in @_onStyleChangedCallbacks
        callback this

  # ============================================================================
  onLoaded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onAreaLoadedCallbacks.push callbackFunc

  # ============================================================================
  onStyleChanged: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      @_onStyleChangedCallbacks.push callbackFunc

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initMembers: ->
    @_onAreaLoadedCallbacks = [];
    @_onStyleChangedCallbacks = [];
    @_data = null
    @_now = new Date(2000, 1, 1)
    @_eu =
      "BEL": new Date(1958, 1, 1)
      "FR1": new Date(1958, 1, 1)
      "ITA": new Date(1958, 1, 1)
      "LUX": new Date(1958, 1, 1)
      "NL1": new Date(1958, 1, 1)
      "DEU": new Date(1958, 1, 1)
      "DN1": new Date(1973, 1, 1)
      "IRL": new Date(1973, 1, 1)
      "GB1": new Date(1973, 1, 1)
      "GRC": new Date(1981, 1, 1)
      "PRT": new Date(1986, 1, 1)
      "ESP": new Date(1986, 1, 1)
      "FI1": new Date(1995, 1, 1)
      "AUT": new Date(1995, 1, 1)
      "SWE": new Date(1995, 1, 1)
      "EST": new Date(2004, 5, 1)
      "LVA": new Date(2004, 5, 1)
      "LTU": new Date(2004, 5, 1)
      "MLT": new Date(2004, 5, 1)
      "POL": new Date(2004, 5, 1)
      "SVK": new Date(2004, 5, 1)
      "SVN": new Date(2004, 5, 1)
      "CZE": new Date(2004, 5, 1)
      "HUN": new Date(2004, 5, 1)
      "CYP": new Date(2004, 5, 1)
      "BGR": new Date(2007, 1, 1)
      "ROU": new Date(2007, 1, 1)
      "HRV": new Date(2013, 7, 1)

  # ============================================================================
  _somethingChangesBetween: (dateA, dateB) ->
    for state, date of @_eu
      if dateA < date <= dateB or dateA >= date > dateB
        return true
    false

  # ============================================================================
  _getColor: (state) =>
    if @_eu[state]? and @_eu[state] < @_now then "#ff5511" else "#ffffff"