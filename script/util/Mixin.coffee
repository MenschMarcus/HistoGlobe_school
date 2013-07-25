window.HG ?= {}

# ============================================================================
HG.mixin = (object, mixin) ->

  for name, method of mixin.prototype
    object[name] = method

  for name, method of mixin
    object[name] = method

