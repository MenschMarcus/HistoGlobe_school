window.HG ?= {}

class HG.GraphNodeConnection

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (latlngA,latlngB,startTime,endTime,info) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @
    @addCallback "onShow"
    @addCallback "onHide"

    @startPoint = latlngA

    @endPoint = latlngB

    @_startTime = startTime

    @_endTime = endTime

    @linkedNodes = []

    @_active = true

    @_now = new Date(2000, 1, 1)

    @_info = info

    @isInfoVisible = false

    @_actionQueue = [] # 1 = future insertion; 0 = future deletion

  # ============================================================================
  setDate: (newDate) ->

    @_now = newDate

    new_active = @_isActive()

    if new_active and not @_active

      @_actionQueue.push 1

    if not new_active and @_active

      @_actionQueue.push 0

    @_active = new_active

  # ============================================================================
  drawChanges: () ->

    while @_actionQueue.length isnt 0
      action = @_actionQueue.shift()
      if action is 1
        for node in @linkedNodes
          node.addConnection(@)
          node.increaseRadius()
        @notifyAll "onShow", @
      if action is 0
        for node in @linkedNodes
          node.removeConnection(@)
          node.decreaseRadius()
        @notifyAll "onHide", @

  # ============================================================================
  isActive:()->
    return @_active

  # ============================================================================
  addLinkedNode: (node) =>
    @linkedNodes.push node

  # ============================================================================
  getLinkedNodes: () =>
    
    return @linkedNodes

  # ============================================================================
  getInfoForShow: () =>
    @isInfoVisible = true;
    return @_info

  # ============================================================================
  getColor: () =>

    count = 0
    ret_color = {r:0,g:0,b:0}

    if @_info.defense
      ret_color.r=0.2
      ret_color.g=0.2
      ret_color.b=1
      ++count
      #return color={r:0,g:0.26274509803921568627450980392157,b:0.34117647058823529411764705882353}
    if @_info.neutrality
      ret_color.r=1
      ret_color.g=1
      ret_color.b=0.2
      ++count
      #return color={r:0.65882352941176470588235294117647,g:0.23921568627450980392156862745098,b:0.27450980392156862745098039215686}
    if @_info.nonaggression
      ret_color.r=0.2
      ret_color.g=1
      ret_color.b=0.2
      ++count
      #return color={r:0.08627450980392156862745098039216,g:0.28235294117647058823529411764706,b:0.34901960784313725490196078431373}
    if @_info.entente
      ret_color.r=0.2
      ret_color.g=0.2
      ret_color.b=1
      ++count
      #return color={r:0.18039215686274509803921568627451,g:0.26666666666666666666666666666667,b:0.36862745098039215686274509803922}
    #return color={r:0,g:0,b:0}
    if count is not 0
      ret_color.r = ret_color.r/count
      ret_color.g = ret_color.g/count
      ret_color.b = ret_color.b/count
    return ret_color

  # ============================================================================
  _isActive: () =>

    return @_startTime < @_now and @_now < @_endTime

