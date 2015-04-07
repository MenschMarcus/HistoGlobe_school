window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  BIG_JUMP_THRESHOLD = 50  # years

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
    @_changeQueue = new Queue()

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
      oldDate = @_now
      newDate = date

      # for small changes: update all areas one at a time
      if (Math.abs oldDate.getFullYear()-newDate.getFullYear()) < (BIG_JUMP_THRESHOLD)
        @_updateAreas oldDate, newDate
      # for big jumps: completely redraw the map
      else
        @_redrawAreas newDate

      # update now date
      @_now = date

    # infinite loop that executes all changes in the queue
    mainLoop = setInterval () =>    # => is important to be able to access global variables (compared to ->)
      @_doChanges()
    , 1000 # TODO: set back to 50

    # ???
    # hgInstance.onAllModulesLoaded @, () =>
    #   hgInstance.hivent_list_module?.onUpdateTheme @, (theme) =>
    #     @_theme = theme
    #     @_updateAreas @_now

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  # add all new and remove all old areas to map/globe
  # -> immediately, without changes
  _redrawAreas: (nowDate)->

    # put all current areas on the map
    for area in @_areas

      # comparison by active state
      wasActive = area.isActive()
      isActive = no
      if nowDate >= area.getStartDate() and nowDate < area.getEndDate()
        isActive = yes

      # if area became active
      if isActive and not wasActive
        area.setActive()
        @notifyAll "onAddArea", area

      # if area became inactive
      if wasActive and not isActive
        area.setInactive()
        @notifyAll "onRemoveArea", area

    # put all current labels on the map
    for label in @_labels

      # comparison by active state
      wasActive = label.isActive()
      isActive = no
      if nowDate >= label.getStartDate() and nowDate < label.getEndDate()
        isActive = yes

      # if label became active
      if isActive and not wasActive
        label.setActive()
        @notifyAll "onAddLabel", label

      # if label became inactive
      if wasActive and not isActive
        label.setInactive()
        @notifyAll "onRemoveLabel", label


  # ============================================================================
  # add all new and remove all old areas to map/globe
  # and emphasize transition areas (areas that move from one country to another)
  _updateAreas: (oldDate, newDate) ->
    # change direction: forwards (-1) or backwards (1) ?
    # changes are sorted the other way!
    changeDir = -1
    if oldDate > newDate
      changeDir = 1
      # swap old and new date, so it can be assumed that always oldDate < newDate
      tempDate = oldDate
      oldDate = newDate
      newDate = tempDate

    # idea: go through all changes in (reversed) order
    # check if the change date is inside the change range from the old to the new date
    # as soon as one change is inside, all changes will be executed until  one change is outside the range
    # -> then termination of the loop
    enteredChangeRange = no
    for change in @_changes by changeDir
      if change.date >= oldDate and change.date < newDate
        # enqueue next change
        ready = yes       # [0]: flag yes/no
        oldAreas = []     # [1]: areas to be deleted
        newAreas = []     # [2]: areas to be added
        oldLabels = []    # [3]: labels to be deleted
        newLabels = []    # [4]: labels to be added
        transRegions = [] # [5]: regions to be faded out when change is done

        for id in change.old_areas
          area = @_getAreaById id
          if area?
            oldAreas.push area if changeDir is -1   # timeline moves forward => old areas are old areas
            newAreas.push area if changeDir is 1    # timeline moves backward => old areas are new areas

        for id in change.new_areas
          area = @_getAreaById id
          if area?
            newAreas.push area if changeDir is -1
            oldAreas.push area if changeDir is 1

        for id in change.old_labels
          label = @_getLabelById id
          if label?
            oldLabels.push label if changeDir is -1
            newLabels.push label if changeDir is 1

        for id in change.new_labels
          label = @_getLabelById id
          if label?
            newLabels.push label if changeDir is -1
            oldLabels.push label if changeDir is 1

        # TODO: transition areas

        @_changeQueue.enqueue [ready, oldAreas, newAreas, oldLabels, newLabels, transRegions]

        enteredChangeRange = yes
      else
        break if enteredChangeRange

  # ============================================================================
  # find next ready area change and execute it (one at a time)
  _doChanges: () ->
    # execute change if it is ready
    if not @_changeQueue.isEmpty()
      if @_changeQueue.peek()[0]
        change = @_changeQueue.dequeue()

        # remove all old areas
        for area in change[1]
          console.log "rem area", area.getId() if area?
          area.setInactive()
          @notifyAll "onRemoveArea", area

        # add all new areas
        for area in change[2]
          console.log "add area", area.getId() if area?
          area.setActive()
          @notifyAll "onAddArea", area

        # remove all old labels
        for label in change[3]
          console.log "rem label", label.getName() if label?
          label.setInactive()
          @notifyAll "onRemoveLabel", label

        # add all new labels
        for label in change[4]
          console.log "add label", label.getName() if label?
          label.setActive()
          @notifyAll "onAddLabel", label

        # fade-out transition region
        for transRegion in change[5]
          @notifyAll "onFadeOutArea", transRegion



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
                  @_redrawAreas @_timeline.getNowDate()

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
                  @_redrawAreas @_timeline.getNowDate()

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

              # create JavaScript Date
              change.date = new Date change.date.toString()

              # fill labels array
              @_changes.push change

              # one less change to go
              numChangesToLoad--
              if numChangesToLoad is 0
                @_changesLoaded = yes

            , 0 # execute immediately

          executeAsync change

  # ============================================================================
  # find area/label
  _getAreaById: (id) ->
    for area in @_areas
      if area.getId() is id
        return area
    undefined

  _getLabelById: (id) ->
    for label in @_labels
      if label.getId() is id
        return label
    undefined
