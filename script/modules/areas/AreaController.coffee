window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################


  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onAddArea"
    @addCallback "onRemoveArea"
    @addCallback "onFadeInArea"
    @addCallback "onFadeOutArea"
    @addCallback "onUpdateAreaStyle"
    @addCallback "onAddLabel"
    @addCallback "onRemoveLabel"
    @addCallback "onMoveLabel"
    @addCallback "onUpdateLabelStyle"


    @_timeline  = null
    @_now       = null
    @_theme     = null
    # @_theme     = 'bipolarAlliances'

    defaultConfig =
      areaJSONPaths: undefined,

    conf = $.extend {}, defaultConfig, config

    # area handling
    @_areas = []    # set of all HG areas (id, geometry, ...)
    @_labels = []   # set of all HG labels (id, name, position, ...)
    @_changes = []  # set of all HG areas (id, type, date, old/new areas/labels)

    # main queue, each element describes one area change
    @_areaChanges = []

    # initially load areas from input files
    @_areasLoaded = no
    @_labelsLoaded = no
    @_changesLoaded = no
    @_loadAreasFromJSON conf
    @_loadLabelsFromJSON conf
    @_loadChangesFromJSON conf

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.areaController = @

    @_timeline = hgInstance.timeline
    @_now = @_timeline.getNowDate()

    @_styler = hgInstance.styler

    # main activity: what happens if now date changes?
    @_timeline.onNowChanged @, (date) ->
      @_pushAreas()

    # infinite loop that executes all changes in the queue
    mainLoop = setInterval () =>    # => is important to be able to access global variables (compared to ->)
      @_doChanges()
    , 50

    # ???
    # hgInstance.onAllModulesLoaded @, () =>
    #   hgInstance.hivent_list_module?.onUpdateTheme @, (theme) =>
    #     @_theme = theme
    #     @_updateAreas @_now

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _loadAreasFromJSON: (config) ->

    # parse each geojson file
    for file in config.areaJSONPaths
      $.getJSON file, (areas) =>
        numAreasToLoad = areas.features.length  # counter

        for area in areas.features

          # parse file asynchronously
          executeAsync = (area) =>
            setTimeout () =>

              # meta
              areaId    = area.properties.id
              startDate = new Date area.properties.start_date.toString()
              endDate   = new Date area.properties.end_date.toString()
              type      = area.properties.type

              # geometry (polygons)
              data = L.GeoJSON.geometryToLayer area
              geometry = []
              if area.geometry.type is "Polygon"
                geometry.push data._latlngs
              else if area.geometry.type is "MultiPolygon"
                for id, layer of data._layers
                  geometry.push layer._latlngs

              # create HG area
              newArea = new HG.Area areaId, geometry, startDate, endDate, type, @_styler

              # set initial style
              if @_theme?
                # check if area has a class in this theme
                nowDate = @_timeline.getNowDate
                themeClasses = newArea.getThemeClasses @_theme
                if themeClasses?
                  for themeClass in themeClasses
                    if nowDate >= themeClass.startDate and nowDate < themeClass.endDate
                      newThemeClass = themeClass.className
                      break

              # fill areas array
              @_areas.push newArea

              # one less area to go
              numAreasToLoad--
              if numAreasToLoad is 0
                @_areasLoaded = yes
                # if labels and areas fully loaded, initially put them on the map
                if @_labelsLoaded
                  @_pushAreas()

            , 0 # execute immediately

          executeAsync area

  # ============================================================================
  _loadLabelsFromJSON: (config) ->

    # parse each geojson file
    for file in config.labelJSONPaths
      $.getJSON file, (labels) =>
        numLabelsToLoad = labels.features.length  # counter

        for label in labels.features

          # parse file asynchronously
          executeAsync = (label) =>
            setTimeout () =>

              # meta
              labelId   = label.properties.id
              startDate = new Date label.properties.start_date.toString()
              endDate   = new Date label.properties.end_date.toString()
              name      = label.properties.name

              # geometry (point)
              position    = label.geometry.coordinates
              boundingBox = label.properties.boundingBox

              # create HG label if it exists
              if position[0]?
                newLabel = new HG.Label labelId, name, position, boundingBox, startDate, endDate, @_styler

                # set initial style
                if @_theme?
                  # check if label has a class in this theme
                  nowDate = @_timeline.getNowDate
                  themeClasses = newLabel.getThemeClasses @_theme
                  if themeClasses?
                    for themeClass in themeClasses
                      if nowDate >= themeClass.startDate and nowDate < themeClass.endDate
                        newThemeClass = themeClass.className
                        break

                # fill labels array
                @_labels.push newLabel

              # one less label to go
              numLabelsToLoad--
              if numLabelsToLoad is 0
                @_labelsLoaded = yes
                # if labels and areas fully loaded, initially put them on the map
                if @_areasLoaded
                  @_pushAreas()

            , 0 # execute immediately

          executeAsync label

  # ============================================================================
  _loadChangesFromJSON: (config) ->

    # parse each geojson file
    for file in config.changeJSONPaths
      $.getJSON file, (changes) =>
        numChangesToLoad = changes.features.length  # counter

        for change in changes.features

          # parse file asynchronously
          executeAsync = (change) =>
            setTimeout () =>

              # fill labels array
              @_changes.push change

              # one less change to go
              numChangesToLoad--
              if numChangesToLoad is 0
                @_changesLoaded = yes

            , 0 # execute immediately

          executeAsync change


  # ============================================================================
  # add all new and remove all old areas to map/globe
  # and emphasize transition areas (areas that move from one country to another)
  _pushAreas:()->

    # get current date
    @_now = @_timeline.getNowDate()

    # put all current areas on the map
    for area in @_areas
      if @_now >= area.getStartDate() and @_now < area.getEndDate()
        if not area.isActive()
          area.setActive()
          @notifyAll "onFadeInArea", area
      else
        if area.isActive()
          area.setInactive()
          @notifyAll "onFadeOutArea", area

    # put all current labels on the map
    for label in @_labels
      if @_now >= label.getStartDate() and @_now < label.getEndDate()
        if not label.isActive()
          label.setActive()
          @notifyAll "onAddLabel", label
      else
        if label.isActive()
          label.setInactive()
          @notifyAll "onRemoveLabel", label

  # # ============================================================================
  # # add all new and remove all old areas to map/globe
  # # and emphasize transition areas (areas that move from one country to another)
  # _pushAreas:(date)->

  #   console.log "GO"

  #   # comparison by dates
  #   oldDate = @_now
  #   newDate = date

  #   # changing areas in this step
  #   areasChanged = no
  #   newAreas = []
  #   oldAreas = []
  #   newStyles = []

  #   for area in @_areas

  #     # comparison by active state
  #     wasActive = area.isActive()
  #     isActive = no
  #     if newDate >= area.getStartDate() and newDate < area.getEndDate()
  #       isActive = yes

  #     # if area became active
  #     if isActive and not wasActive
  #       area.setActive()
  #       areasChanged = yes
  #       newAreas.push area

  #     # if area became inactive
  #     if wasActive and not isActive
  #       area.setInactive()
  #       areasChanged = yes
  #       oldAreas.push area

  #     # check if style changed
  #     if isActive
  #       oldThemeClass = area.getActiveThemeClass()
  #       newThemeClass = 'normal'  # initially normal class, if not overwritten by
  #       # if currently a theme active
  #       if @_theme?
  #         # check if area has a class in this theme
  #         themeClasses = area.getThemeClasses @_theme
  #         if themeClasses?
  #           for themeClass in themeClasses
  #             if newDate >= themeClass.startDate and newDate < themeClass.endDate
  #               newThemeClass = themeClass.className
  #               break

  #       # check if theme style has changed
  #       if (oldThemeClass.localeCompare newThemeClass) != 0   # N.B.! this took so long to find out how to actually compare if two strings are NOT equal in CoffeeScript...
  #         area.setActiveThemeClass @_theme, newThemeClass
  #         areasChanged = yes
  #         newStyles.push area


  #   ## update the changing areas
  #   if areasChanged
  #     # fade-in transition area (areas that actually change)
  #     # assemble transition areas
  #     # TODO
  #     # transAreaGeo = [[[52.874124, 7.601427], [53.026369, 13.962511], [48.022933, 13.217549], [47.890499, 6.647725]]]
  #     # transArea = new HG.Area "T1", null, transAreaGeo, null, null, "trans"
  #     transArea = null
  #     # if transArea
  #     #   @notifyAll "onShowArea", transArea
  #     #   transArea.setActive()

  #     # if there is no transition area, the adding and deletion of countries can happen right away
  #     ready = yes

  #     # enqueue set of area change
  #     # @_areaChanges.enqueue [ready, newAreas, oldAreas, newStyles, transArea]

  #   # reset now Date
  #   @_now = newDate


  # ============================================================================
  # find next ready area change and execute it (one at a time)
  _doChanges: () ->
    for change in @_areaChanges
      if change.isReady
        # execute it
        # terminate loop
        break
