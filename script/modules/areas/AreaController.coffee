window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  SHOW_BLOCKS = on

  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShowArea"
    @addCallback "onHideArea"
    # @addCallback "onShowArea"
    # @addCallback "onHideArea"

    @_timeline = null
    @_now = null

    defaultConfig =
      areaJSONPaths: undefined,

    conf = $.extend {}, defaultConfig, config

    # area handling
    @_areas = []                # main array of all HG areas (id, name, geometry, ...)
    @_activeAreas = []          # backup: id of all areas that are currently active

    @_areaChanges = new Queue() # main queue, each element describes one area change
      # 1) flag: ready to be executed? (if transition animation of related areas is done)
      # 2) set of areas to be added on the map
      # 3) set of areas to be deleted from the map
      # 4) set of transition areas to be faded out on the map


    # initially load areas from input files
    @_loadAreasFromJSON conf

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_now = @_timeline.getNowDate()

    @_areaStyler = hgInstance.areaStyler
    console.log @_areaStyler.getCountryThemeStyle '1990-9999-DEU', 'bipolarAlliances', @_now

    # main activity: what happens if now date changes?
    @_timeline.onNowChanged @, (date) ->
      @_filterActiveAreas date

    # start working through loop that makes sure countries are added and removed correctly
    # ctr = 0
    # mainLoop = setInterval (mainLoop, ctr) =>


    # ctr = 0
    mainLoop = setInterval () =>    # => is important to be able to access global variables (compared to ->)

      # check if area change can happen
      if not @_areaChanges.isEmpty()
        isReady = @_areaChanges.peek()[0]
        if isReady
          areaChange = @_areaChanges.dequeue()

          # add all new areas
          for area in areaChange[1]
            # console.log "add ", area.getId()
            @notifyAll "onShowArea", area
            area.setActive()

          # remove all old areas
          for area in areaChange[2]
            # console.log "rem ", area.getId()
            @notifyAll "onHideArea", area
            area.setInactive()

          # fade-out transition area
          transArea = areaChange[3]
          if transArea
            @notifyAll "onHideArea", transArea, yes
            transArea.setInactive()

      # ++ctr
      # if ctr == 5
      #   console.log "DONE!"
      #   clearInterval mainLoop
    , 50


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
        numAreasToLoad = countries.features.length  # counter

        for country in countries.features

          # parse file asynchronously
          executeAsync = (country) =>
            setTimeout () =>

              ## id
              # @_id       = country.properties.iso_a3
              # old! iso_a3 not suitable for historic countries, because it is hard to always come up with three letters for a country
              # => introduce a "country_id" in geojson, which is a 3 (current country) or 4 (historic country) letter country code
              ctryId = country.properties.country_id

              ## misc
              name     = country.properties.name_de_shrt    # to be changed if other languages are desired
              labelPos = country.properties.label_lat_lng
              startDate = new Date country.properties.start_date.toString()
              endDate   = new Date country.properties.end_date.toString()
              type      = 'country'
              active    = false

              ## geometry (polygons)
              data = L.GeoJSON.geometryToLayer country
              geometry = []
              if country.geometry.type is "Polygon"
                geometry.push data._latlngs
              else if country.geometry.type is "MultiPolygon"
                for id, layer of data._layers
                  geometry.push layer._latlngs

              # create HG area
              newArea = new HG.Area ctryId, name, geometry, startDate, endDate, type
              newArea.setInactive()
              if labelPos?
                newArea.setLabelPos labelPos

              # fill areas array
              @_areas.push newArea

              # one less area to go
              numAreasToLoad--

              # initially put areas on the map / globe
              if numAreasToLoad is 0
                @_filterActiveAreas @_timeline.getNowDate()

            , 0

          executeAsync country


  # ============================================================================
  # add all new and remove all old areas to map/globe
  # and emphasize transition areas (areas that move from one country to another)

  _filterActiveAreas:(date)->

    # comparison by dates
    oldDate = @_now
    newDate = date

    # changing areas in this step
    areasChanged = no
    newAreas = []
    oldAreas = []

    for area in @_areas

      # comparison by active state
      wasActive = area.isActive()
      isActive = no
      if newDate >= area.getStartDate() and newDate < area.getEndDate()
        isActive = yes

      # if area became active
      if isActive and not wasActive
        newAreas.push area
        area.setActive()
        areasChanged = yes

      # if area became inactive
      if wasActive and not isActive
        oldAreas.push area
        area.setInactive()
        areasChanged = yes

    ## update the changing areas
    if areasChanged
      # fade-in transition area (areas that actually change)
      # assemble transition areas
      # TODO
      transAreaGeo = [[[52.874124, 7.601427], [53.026369, 13.962511], [48.022933, 13.217549], [47.890499, 6.647725]]]
      transArea = new HG.Area "T1", null, transAreaGeo, null, null, "trans"
      transArea = null
      if transArea
        @notifyAll "onShowArea", transArea, yes
        transArea.setActive()

      # if there is no transition area, the adding and deletion of countries can happen right away
      ready = no
      if not transArea
        ready = yes

      # enqueue set of area change
      @_areaChanges.enqueue [ready, newAreas, oldAreas, transArea]




    # reset now Date
    @_now = newDate
