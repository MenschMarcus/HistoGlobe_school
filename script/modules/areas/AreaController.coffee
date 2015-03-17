window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShowArea"
    @addCallback "onHideArea"

    @_timeline = null
    @_now = null

    defaultConfig =
      areaJSONPaths: undefined,

    conf = $.extend {}, defaultConfig, config

    # area handling
    @_areas = []                # main array of all HG areas (id, name, geometry, ...)
    @_activeAreas = []          # backup: id of all areas that are currently active
    @_addAreas = new Queue()    # id of areas that are new and to be put on the map/globe
    @_remAreas = new Queue()    # id of areas that are old and to be removed on the map/globe
    @_transAreas = new Queue()  # if of areas that transisted from one country to another (to be calculated)

    # initially load areas from input files
    @_loadAreasFromJSON conf

    # has time ever changed?
    @_hasTimeChanged = no

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_now = @_timeline.getNowDate()

    # main activity: what happens if now date changes?
    @_timeline.onNowChanged @, (date) ->
      @_filterActiveAreas date

    # category handling
    # hgInstance.categoryFilter?.onFilterChanged @,(categoryFilter) =>
    #   @_currentCategoryFilter = categoryFilter
    #   @_filterActiveAreas()

    # @_categoryFilter = hgInstance.categoryFilter if hgInstance.categoryFilter


  # ============================================================================
  getAllAreas:()->    @_areas
  getActiveAreas:()-> @_activeAreas


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _loadAreasFromJSON: (config) ->

    # parse each geojson file
    for file in config.areaJSONPaths
      $.getJSON file, (countries) =>
        numCountriesToLoad = countries.features.length  # counter
        for country in countries.features

          # parse file asynchronously
          executeAsync = (country) =>
            setTimeout () =>

              ## id
              # @_id       = country.properties.iso_a3
              # old! iso_a3 not suitable for historic countries, because it is hard to always come up with three letters for a country
              # => introduce a "country_id" in geojson, which is a 3 (current country) or 4 (historic country) letter country code
              ctryId = country.properties.country_id

              ## geometry (polygons)
              data = L.GeoJSON.geometryToLayer country
              geometry = []
              if country.geometry.type is "Polygon"
                geometry.push data._latlngs
              else if country.geometry.type is "MultiPolygon"
                for id, layer of data._layers
                  geometry.push layer._latlngs

              ## label
              name     = country.properties.name_de_shrt    # to be changed if other languages are desired
              labelPos = country.properties.label_lat_lng

              ## misc
              # startDate = new Date country.properties.start_date, 0, 1    # 01.01. of start year
              # endDate   = new Date country.properties.end_date-1, 11, 31  # 31.12. of year before
              startDate = new Date country.properties.start_date.toString()
              endDate   = new Date country.properties.end_date.toString()
              type      = 'country'
              active    = false

              # create HG area
              newArea = new HG.Area ctryId, geometry, startDate, endDate, type
              newArea.setInactive()
              if labelPos?
                newArea.setLabelWithPos name, labelPos
              else
                newArea.setLabel name

              # attach event handlers to area
              # newArea.onShow @, (area) =>
              #   @notifyAll "onShowArea", area
              #   area.isVisible = true

              # newArea.onHide @, (area) =>
              #   @notifyAll "onHideArea", area
              #   area.isVisible = false

              # fill areas array
              @_areas.push newArea

              # counter handling
              numCountriesToLoad--
              if numCountriesToLoad is 0
                # initially put areas on the map / globe
                @_filterActiveAreas @_timeline.getNowDate()

            , 0

          executeAsync country

  # ============================================================================
  # add all new and remove all old areas to map/globe
  # and emphasize transition areas (areas that move from one country to another)

  _updateAreas:()->
    # TODO assemble and show transition area

    # add all new areas (asynchronously)
    while not @_addAreas.isEmpty()
      addArea = @_addAreas.dequeue()
      @notifyAll "onShowArea", addArea

    # remove all new areas (asynchronously)
    while not @_remAreas.isEmpty()
      remArea = @_remAreas.dequeue()
      @notifyAll "onHideArea", remArea

    # # remove all old areas (asynchronously)
    # while not @_remAreas.isEmpty()
    #   remId = @_remAreas.dequeue()


  # ============================================================================
  _filterActiveAreas:(date)->

    # comparison by dates
    oldDate = @_now
    newDate = date

    for area in @_areas

      # comparison by active state
      wasActive = area.isActive()
      isActive = no
      if newDate >= area.getStartDate() and newDate < area.getEndDate()
        isActive = yes

      # change? -> became active/inactive
      becameActive    = isActive and not wasActive
      becameInactive  = wasActive and not isActive

      # console.log area.getId(), isActive, wasActive, becameActive, becameInactive

      if becameActive
        # @notifyAll "onShow", @
        @_addAreas.enqueue area
        area.setActive()

      if becameInactive
        # @notifyAll "onHide", @
        @_remAreas.enqueue area
        area.setInactive()


    # reset now Date
    @_now = newDate

    # time has changed once -> never reset to "no"
    @_hasTimeChanged = yes

    @_updateAreas()
