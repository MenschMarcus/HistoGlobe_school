window.HG ?= {}

class HG.Display

  focus: (hivent) ->
    @center
      x: hivent.long
      y: hivent.lat

