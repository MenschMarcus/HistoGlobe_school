window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  SHOW_THEME  = on
  THEME       = 'bipolarAlliances'

  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShowArea"
    @addCallback "onHideArea"
    @addCallback "onUpdateArea"

    @_timeline = null
    @_now = null

    defaultConfig =
      areaJSONPaths: undefined,

    conf = $.extend {}, defaultConfig, config

    # area handling
    @_areas = []  # main array of all HG areas (id, name, geometry, ...)

    @_areaChanges = new Queue() # main queue, each element describes one area change
      # 1) flag: ready to be executed? (if transition animation of related areas is done)
      # 2) set of areas to be added on the map
      # 3) set of areas to be deleted from the map
      # 4) set of areas whose style is to be changed on the map
      # 5) set of transition areas to be faded out on the map


    # initially load areas from input files
    @_loadAreasFromJSON conf

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_now = @_timeline.getNowDate()

    @_areaStyler = hgInstance.areaStyler

    # main activity: what happens if now date changes?
    @_timeline.onNowChanged @, (date) ->
      @_updateAreas date

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
            @notifyAll "onShowArea", area
            area.setActive()

          # remove all old areas
          for area in areaChange[2]
            @notifyAll "onHideArea", area
            area.setInactive()

          # change style of all areas to be changed
          for area in areaChange[3]
            @notifyAll "onUpdateArea", area

          # fade-out transition area
          # transArea = areaChange[4]
          # if transArea
          #   @notifyAll "onHideArea", transArea
          #   transArea.setInactive()

        # update style


      # ++ctr
      # if ctr == 5
      #   console.log "DONE!"
      #   clearInterval mainLoop
    , 50


  # ============================================================================
  getAllAreas:()->
    @_areas


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
              countryId = country.properties.id

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
              newArea = new HG.Area countryId, name, geometry, startDate, endDate, type, @_areaStyler

              # manually set label position if given in data
              if labelPos?
                newArea.setLabelPos labelPos

              # fill areas array
              @_areas.push newArea

              # one less area to go
              numAreasToLoad--

              # initially put areas on the map / globe
              if numAreasToLoad is 0
                @_updateAreas @_timeline.getNowDate()

            , 0

          executeAsync country

  # ============================================================================
  # add all new and remove all old areas to map/globe
  # and emphasize transition areas (areas that move from one country to another)

  _updateAreas:(date)->

    # comparison by dates
    oldDate = @_now
    newDate = date

    # changing areas in this step
    areasChanged = no
    newAreas = []
    oldAreas = []
    newStyles = []

    for area in @_areas

      # comparison by active state
      wasActive = area.isActive()
      isActive = no
      if newDate >= area.getStartDate() and newDate < area.getEndDate()
        isActive = yes

      # if area became active
      if isActive and not wasActive
        area.setActive()
        areasChanged = yes
        newAreas.push area

      # if area became inactive
      if wasActive and not isActive
        area.setInactive()
        areasChanged = yes
        oldAreas.push area

      # check if style changed
      if isActive
        oldStyleTheme = area.getCurrentStyleTheme()
        newStyleTheme = null
        # distinction: currently a theme active?
        if SHOW_THEME
          if area.getId() is '1958-9999-FRA'
            console.log area.isInTheme THEME, newDate
          if area.isInTheme THEME, newDate
            newStyleTheme = THEME
          else
            newStyleTheme = 'normal'
        else
          newStyleTheme = 'normal'

        # check if theme style has changed
        if (oldStyleTheme.localeCompare newStyleTheme) != 0   # N.B.! this took so long to find out how to actually compare if two strings are NOT equal in CoffeeScript...
          console.log area.getId(), newStyleTheme
          area.setCurrentStyleTheme newStyleTheme
          areasChanged = yes
          newStyles.push area


    ## update the changing areas
    if areasChanged
      # fade-in transition area (areas that actually change)
      # assemble transition areas
      # TODO
      # transAreaGeo = [[[52.874124, 7.601427], [53.026369, 13.962511], [48.022933, 13.217549], [47.890499, 6.647725]]]
      # transArea = new HG.Area "T1", null, transAreaGeo, null, null, "trans"
      transArea = null
      # if transArea
      #   @notifyAll "onShowArea", transArea
      #   transArea.setActive()

      # if there is no transition area, the adding and deletion of countries can happen right away
      ready = yes

      # enqueue set of area change
      @_areaChanges.enqueue [ready, newAreas, oldAreas, newStyles, transArea]

    # reset now Date
    @_now = newDate
