window.HG ?= {}

class HG.GraphNode

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  #constructor: (data, indicator) ->
  constructor: (latlng) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @


    @addCallback "onShow"
    @addCallback "onHide"
    @addCallback "onStyleChange"
    @addCallback "onRadiusChange"

    @_initMembers()

    @_radius = 0.4
    @_position = latlng

  # ============================================================================
  increaseRadius: ->
    @_radius = @_radius+0.05
    @notifyAll "onRadiusChange", @

  # ============================================================================
  decreaseRadius: ->
    @_radius = @_radius-0.05
    @notifyAll "onRadiusChange", @

  # ============================================================================
  setDate: (newDate) ->

    @_now = newDate

    new_active = @_isActive()

    if new_active and not @_active
      @notifyAll "onShow", @

    if not new_active and @_active
      @notifyAll "onHide", @

    @_active = new_active

  # ============================================================================
  isActive:()->
    return @_active

  # ============================================================================
  addConnection:(connection)->
    @_connections.push connection

  # ============================================================================
  removeConnection:(connection)->
    index = $.inArray(connection, @_connections)
    @_connections.splice index, 1  if index >= 0

  # ============================================================================
  getConnections:()->
    return @_connections

  # ============================================================================
  getConnectionsWithNode:(node)->
    connections_with_node = []
    for c in @_connections
      linked_nodes = c.getLinkedNodes()
      if linked_nodes[0] is node or linked_nodes[1] is node
        connections_with_node.push c
    return connections_with_node



  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _initData: (data) ->



  # ============================================================================
  _initMembers: ->

    @_color = "#D2CDC3"

    @_now = new Date(2000, 1, 1)
    @_active = false

    @_connections = []


  # ============================================================================
  _isActive: () =>

    '''if not @_start[@_state]? and not @_end[@_state]?
      return true

    if @_start[@_state]? and @_end[@_state]?
      return @_start[@_state] < @_now and @_now < @_end[@_state]

    if @_start[@_state]? and @_start[@_state] < @_now
      return true

    if @_end[@_state]? and @_end[@_state] > @_now
      return true

    false'''

    true