window.HG ?= {}

class HG.Hivent

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (name, year, month, day,
                long, lat, content) ->

    @name = name
    @year = year
    @month = month
    @day = day
    @date = new Date(year, month, day)
    @long = long
    @lat = lat
    @content = content

