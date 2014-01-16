window.HG ?= {}

class HG.Hivent

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (id, name,
                startYear, startMonth, startDay,
                endYear, endMonth, endDay, displayDate,
                long, lat, category, content) ->

    @id = id
    @name = name
    @startYear = startYear
    @startMonth = startMonth
    @startDay = startDay
    @startDate = new Date(startYear, startMonth - 1, startDay)
    @endYear = endYear
    @endMonth = endMonth
    @endDay = endDay
    @endDate = new Date(endYear, endMonth - 1, endDay)
    @displayDate = displayDate
    @long = long
    @lat = lat
    @category = category
    @content = content

