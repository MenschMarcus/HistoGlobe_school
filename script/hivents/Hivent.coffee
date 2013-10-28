window.HG ?= {}

class HG.Hivent

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (name,
                startYear, startMonth, startDay,
                endYear, endMonth, endDay,
                long, lat, category, content) ->

    @name = name
    @startYear = startYear
    @startMonth = startMonth
    @startDay = startDay
    @startDate = new Date(startYear, startMonth, startDay)
    @endYear = endYear
    @endMonth = endMonth
    @endDay = endDay
    @endDate = new Date(endYear, endMonth, endDay)
    @long = long
    @lat = lat
    @category = category
    @content = content

