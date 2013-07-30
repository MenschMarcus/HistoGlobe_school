window.HG ?= {}

# ============================================================================
HG.addCallback = (object, callbackName) ->

  # add an array which will contain the callbacks to the object
  arrayName = "_#{callbackName}Callbacks"
  object[arrayName] = []

  # add a function to register callbacks to the object
  object[callbackName] = (obj, callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      for i in [0...object[arrayName].length]
        if object[arrayName][i][0] == obj
          object[arrayName][i][1].push callbackFunc
          return

      object[arrayName].push [obj, [callbackFunc]]

# ============================================================================
HG.notify = (object, callbackName, objectToBeNotified, parameters...) ->
  arrayName = "_#{callbackName}Callbacks"
  for i in [0...object[arrayName].length]
    if object[arrayName][i][0] == objectToBeNotified
      for j in [0...object[arrayName][i][1].length]
        object[arrayName][i][1][j].apply object[arrayName][i][0], parameters
      break

# ============================================================================
HG.notifyAll = (object, callbackName, parameters...) ->
  arrayName = "_#{callbackName}Callbacks"
  for i in [0...object[arrayName].length]
    for j in [0...object[arrayName][i][1].length]
      object[arrayName][i][1][j].apply object[arrayName][i][0], parameters

