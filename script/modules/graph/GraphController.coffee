window.HG ?= {}

class HG.GraphController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onShowGraphNode"
    @addCallback "onHideGraphNode"
    @addCallback "onGraphLoaded"

    @addCallback "onShowGraphNodeConnection"
    @addCallback "onHideGraphNodeConnection"

    @_nodes = new Array()
    @_connections = []

    @_timeline = null
    @_now = null
    @_config = config

    @_visibleLabels = []

    @_countryCodes = []

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.graphController = @

    @_timeline = hgInstance.timeline

    @_now = @_timeline.getNowDate()

    @_timeline.onNowChanged @, (date) ->
      @_now = date
      # for key,node of @_nodes
      #   node.setDate date
      for c in @_connections
        c.setDate date

      for c in @_connections
        #draw changes asynchronously
        execute_async = (c) =>
         setTimeout () =>
           c.drawChanges()
         , 0

        execute_async c  # async
        #c.drawChanges() #  sync


    @_areaController = hgInstance.areaController

    @_areaController.onLabelsLoaded @,() =>

      @_visibleLabels = @_areaController.getAllLabels()

      @_loadCountryCodesFromCSV(@_config.countryCodesPath)

      @loadGraphFromCSV @_config.alliancePath

    # @_areaController.onCountriesLoaded @,() =>

    #   @_visibleLabels = @_areaController.getActiveAreas()

    #   @loadGraphFromCSV @_config.csvPath

  # ============================================================================
  loadGraphFromCSV: (path) ->

    $.get(path, (data) =>

      csvval=data.split("\n")

      #remove first entry:
      csvval.shift()

      lastCountryA = null
      lastCountryB = null
      lastYearBegin = null
      lastYearEnd = null

      for line in csvval
        csvvalue=line.split(",")
        if csvvalue[7] > 1940

          defense = csvvalue[13] is "1"
          neutrality = csvvalue[14] is "1"
          nonaggression = csvvalue[15] is "1"
          entente = csvvalue[16] is "1"

          info = new Array();
          info["defense"] = defense
          info["neutrality"] = neutrality
          info["nonaggression"] = nonaggression
          info["entente"] = entente

          latlngA = null
          latlngB = null
          LabelA = null
          LabelB = null
          IdA = null
          IdB = null

          countryID = @_countryCodes[csvvalue[1]]

          unless @_nodes[countryID]?

            for label in @_visibleLabels
              if label.getId() is countryID
                latlngA = label.getPosition()
                LabelA = label
                IdA = label.getId()
                break
              #console.log "Could not find corresponding position in visible labels: ",countryID
          else
             latlngA = @_nodes[countryID]._position
             IdA = countryID

          countryID2 = @_countryCodes[csvvalue[3]]

          unless @_nodes[countryID2]?

            for label in @_visibleLabels
              if label.getId() is countryID2
                latlngB = label.getPosition()
                LabelB = label
                IdB = label.getId()
                break
              #console.log "Could not find corresponding position in visible labels: ",countryID2
          else
             latlngB = @_nodes[countryID2]._position
             IdB = countryID2

          #both found:
          if latlngA isnt null and latlngB isnt null

            yearBegin = csvvalue[7]
            yearEnd = csvvalue[10]

            #just one pair per alliance
            unless IdA is lastCountryA and IdB is lastCountryB and
            yearBegin is lastYearBegin and yearEnd is lastYearEnd

              #connection:
              startTime = new Date(yearBegin, csvvalue[6]-1, csvvalue[5])
              endTime = new Date(yearEnd, csvvalue[9]-1, csvvalue[8])

              newConnection = new HG.GraphNodeConnection(latlngA,latlngB,startTime,endTime,info)
              #@notifyAll "onShowGraphNodeConnection" ,latlngA,latlngB
              #@notifyAll "onShowGraphNodeConnection" ,newConnection

              newConnection.onShow @,(connection) =>
                @notifyAll "onShowGraphNodeConnection",connection
              newConnection.onHide @,(connection) =>
                @notifyAll "onHideGraphNodeConnection",connection
              newConnection.setDate @_now

              @_connections.push newConnection 

              #nodes:
              if LabelA isnt null
                newNode = new HG.GraphNode latlngA
                newNode.addConnection newConnection#TO REMOVE
                newConnection.addLinkedNode newNode
                @_nodes[LabelA.getId()] = newNode

              else
                @_nodes[IdA].increaseRadius()
                @_nodes[IdA].addConnection newConnection
                newConnection.addLinkedNode @_nodes[IdA]

              #nodes:
              if LabelB isnt null
                newNode = new HG.GraphNode latlngB
                newNode.addConnection newConnection
                newConnection.addLinkedNode newNode
                @_nodes[LabelB.getId()] = newNode
              else
                @_nodes[IdB].increaseRadius()
                @_nodes[IdB].addConnection newConnection#TO REMOVE
                newConnection.addLinkedNode @_nodes[IdB]

            lastCountryA = IdA
            lastCountryB = IdB
            lastYearBegin = yearBegin
            lastYearEnd = yearEnd

      @notifyAll "onGraphLoaded"
    )

  # ============================================================================
  getAllGraphNodes:()->
    return @_nodes

  # ============================================================================
  getActiveGraphNodes:()->
    result = []
    for key,n of @_nodes
      if n.isActive()
        result.push n
    return result

  # ============================================================================
  getActiveGraphNodeConnections:()->
    result = []
    for c in @_connections
      if c._isActive()
        result.push c
    return result

  # ============================================================================
  _loadCountryCodesFromCSV:(path)->

    $.get(path, (data) =>

      csvval=data.split(";")

      #remove first entry:
      csvval.shift()

      for line in csvval
        csvvalue=line.split(",")
        id = csvvalue[0].replace(/\s+/g, '')
        @_countryCodes[csvvalue[1]] = id
    )