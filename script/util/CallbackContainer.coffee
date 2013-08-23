window.HG ?= {}

class HG.CallbackContainer

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  addCallback: (callbackName) ->

    # add an array which will contain the callbacks to the object
    arrayName = "_#{callbackName}Callbacks"
    @[arrayName] = []

    # add a function to register callbacks to the object
    @[callbackName] = (obj, callbackFunc) ->
      if callbackFunc and typeof(callbackFunc) == "function"
        for i in [0...@[arrayName].length]
          if @[arrayName][i][0] == obj
            @[arrayName][i][1].push callbackFunc
            return

        @[arrayName].push [obj, [callbackFunc]]

  # ============================================================================
  notify: (callbackName, objectToBeNotified, parameters...) ->
    arrayName = "_#{callbackName}Callbacks"
    for i in [0...@[arrayName].length]
      if @[arrayName][i][0] == objectToBeNotified
        for j in [0...@[arrayName][i][1].length]
          @[arrayName][i][1][j].apply @[arrayName][i][0], parameters
        break

  # ============================================================================
  notifyAll: (callbackName, parameters...) ->
    arrayName = "_#{callbackName}Callbacks"
    for i in [0...@[arrayName].length]
      for j in [0...@[arrayName][i][1].length]
        @[arrayName][i][1][j].apply @[arrayName][i][0], parameters

  # ============================================================================
  removeListener: (callbackName, listenerToBeRemoved) ->
    arrayName = "_#{callbackName}Callbacks"
    for i in [0...@[arrayName].length]
      if @[arrayName][i][0] == listenerToBeRemoved
        @[arrayName].splice i,1

  # ============================================================================
  removeListener: (callbackName) ->
    arrayName = "_#{callbackName}Callbacks"
    @[arrayName] = []
