window.HG ?= {}

class HG.Display

  focus: (hivent) ->
    console.log hivent
    @center
      x: hivent.long
      y: hivent.lat

