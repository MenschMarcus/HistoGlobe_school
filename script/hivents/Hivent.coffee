window.HG ?= {}

class HG.Hivent

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (name, date, displayDate,
                long, lat, content) ->


    @name = name
    @date = date
    @displayDate = displayDate
    @long = long
    @lat = lat
    @content = content

