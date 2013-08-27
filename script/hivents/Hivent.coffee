window.HG ?= {}

class HG.Hivent

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (name, date,
                long, lat, content) ->

    @name = name
    @date = date
    @long = long
    @lat = lat
    @content = content

