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
    @startDate = new Date(startYear, startMonth - 1, startDay)
    @endYear = endYear
    @endMonth = endMonth
    @endDay = endDay
    @endDate = new Date(endYear, endMonth - 1, endDay)
    @long = long
    @lat = lat
    @category = category
    @content = content

