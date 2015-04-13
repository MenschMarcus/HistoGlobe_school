window.HG ?= {}

class HG.AreaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  DEBUG_AREAS   = no
  DEBUG_LABELS  = no


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
    @addCallback "onUpdateLabelStyle"


    @_timeline        = null
    @_now             = null
    @_theme           = ''
    @_isHighContrast  = no

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

    @_aniTime = hgInstance._config.areaAniTime
    @_timeline = hgInstance.timeline
    @_now = new Date -5000, 0, 1  # horrible init start year hack

    @_styler = hgInstance.styler

    # main activity: what happens if now date changes?
    @_timeline.onNowChanged @, (date) ->
      if @_areasLoaded and @_labelsLoaded and @_changesLoaded
        oldDate = @_now
        newDate = date
        @_updateCountries oldDate, newDate
        # update now date
        @_now = date

    hgInstance.onAllModulesLoaded @, () =>
      hgInstance.hivent_list_module?.onUpdateTheme @, (theme) =>
        @_theme = theme
        @_updateStyle @_now

    # toggle highContrast mode
    hgInstance.highcontrast_button.onEnterHighContrast @, () =>
      @_isHighContrast = yes
      for area in @_areas
        @notifyAll "onUpdateAreaStyle", area, yes
      for label in @_labels
        @notifyAll "onUpdateLabelStyle", label, yes

    hgInstance.highcontrast_button.onLeaveHighContrast @, () =>
      @_isHighContrast = no
      for area in @_areas
        @notifyAll "onUpdateAreaStyle", area, no
      for label in @_labels
        @notifyAll "onUpdateLabelStyle", label, no

    # infinite loop that executes all changes in the queue
    mainLoop = setInterval () =>    # => is important to be able to access global variables (compared to ->)
      @_doChanges()
    , 1000 # TODO: change back to 50



  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  # add all new and remove all old areas to map/globe
  # and emphasize transition areas (areas that move from one country to another)

  _updateCountries: (oldDate, newDate) ->

    # change direction: forwards (+1) or backwards (-1) ?
    # changes are sorted the other way!
    changeDir = 1
    if oldDate > newDate
      changeDir = -1
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

        # fade-in transition region
        hasTransition = no
        for id in change.transition_regions
          if id?
            hasTransition = yes
            transRegion = @_getAreaById id
            @notifyAll "onFadeInArea", transRegion, yes

        # enqueue next change
        timestamp = null  # [0]: timestamp at wich changes shall be executed
        oldAreas = []     # [1]: areas to be deleted
        newAreas = []     # [2]: areas to be added
        oldLabels = []    # [3]: labels to be deleted
        newLabels = []    # [4]: labels to be added
        transRegions = [] # [5]: regions to be faded out when change is done

        timestamp = new Date()
        if hasTransition
          timestamp.setMilliseconds timestamp.getMilliseconds() + @_aniTime

        for id in change.new_areas
          newAreas.push id if changeDir is 1
          oldAreas.push id if changeDir is -1

        for id in change.old_areas
          oldAreas.push id if changeDir is 1      # timeline moves forward => old areas are old areas
          newAreas.push id if changeDir is -1     # timeline moves backward => old areas are new areas

        for id in change.new_labels
          newLabels.push id if changeDir is 1
          oldLabels.push id if changeDir is -1

        for id in change.old_labels
          oldLabels.push id if changeDir is 1
          newLabels.push id if changeDir is -1

        for id in change.transition_regions
          transRegions.push id

        # remove duplicates -> all areas/labels that are both in new or old array
        # TODO: O(n²) in the moment -> does that get better?
        iNew = 0
        iOld = 0
        lenNew = newAreas.length
        lenOld = oldAreas.length
        while iNew < lenNew
          while iOld < lenOld
            if newAreas[iNew] == oldAreas[iOld]
              newAreas[iNew] = null
              oldAreas[iOld] = null
              break
            ++iOld
          ++iNew

        iNew = 0
        iOld = 0
        lenNew = newLabels.length
        lenOld = oldLabels.length
        while iNew < lenNew
          while iOld < lenOld
            if newLabels[iNew] == oldLabels[iOld]
              newLabels[iNew] = null
              oldLabels[iOld] = null
              break
            ++iOld
          ++iNew

        # finally enqueue distinct changes
        @_changeQueue.enqueue [timestamp, oldAreas, newAreas, oldLabels, newLabels, transRegions]

        enteredChangeRange = yes
      else
        break if enteredChangeRange

  # ============================================================================
  # updates the style values for areas and labels
  _updateStyle: () ->
    return

  # ============================================================================
  # find next ready area change and execute it (one at a time)
  _doChanges: () ->
    # execute change if it is ready
    while not @_changeQueue.isEmpty()
      # check if first element in queue is ready (timestamp is reached)
      break if @_changeQueue.peek()[0] > new Date()

      change = @_changeQueue.dequeue()

      # remove all old areas
      for id in change[1]
        area = @_getAreaById id
        if area?
          console.log "rem area", area.getId() if DEBUG_AREAS
          @notifyAll "onRemoveArea", area

      # add all new areas
      for id in change[2]
        area = @_getAreaById id
        if area?
          console.log "add area", area.getId() if DEBUG_AREAS
          @notifyAll "onAddArea", area

      # remove all old labels
      for id in change[3]
        label = @_getLabelById id
        if label?
          console.log "rem label", label.getName() if DEBUG_LABELS
          @notifyAll "onRemoveLabel", label

      # add all new labels
      for id in change[4]
        label = @_getLabelById id
        if label?
          console.log "add label", label.getName() if DEBUG_LABELS
          @notifyAll "onAddLabel", label

      # fade-out transition region
      for id in change[5]
        transRegion = @_getAreaById id
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
              type      = 'country'
              # startDate = new Date area.properties.start_date.toString()
              # endDate   = new Date area.properties.end_date.toString()

              # geometry (polygons)
              geometry = []

              # error handling: empty layer because of non-existing geometry
              if area.geometry.coordinates.length is 0
                geometry = [[]]

              else
                data = L.GeoJSON.geometryToLayer area
                if area.geometry.type is "Polygon"
                  geometry.push data._latlngs
                else if area.geometry.type is "MultiPolygon"
                  for id, layer of data._layers
                    geometry.push layer._latlngs

              # create HG area
              newArea = new HG.Area areaId, geometry, type, @_styler

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
              name      = label.properties.name
              prio      = label.properties.prio
              # startDate = new Date label.properties.start_date.toString()
              # endDate   = new Date label.properties.end_date.toString()

              # geometry (point)
              position    = label.geometry.coordinates
              # boundingBox = label.properties.boundingBox

              # create HG label if it exists
              if position[0]?
                newLabel = new HG.Label labelId, name, prio, position, @_styler

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
    if id?
      for area in @_areas
        if area.getId() is id
          return area
    undefined

  _getLabelById: (id) ->
    if id?
      for label in @_labels
        if label.getId() is id
          return label
    undefined
