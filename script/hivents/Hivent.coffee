window.HG ?= {}

class HG.Hivent

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (id, name,
                startYear, startMonth, startDay,
                endYear, endMonth, endDay,
                locationName,
                long, lat, category, content,
                description, mmIDs) ->

    @id = id
    @name = name
    @startYear = startYear
    @startMonth = startMonth
    @startDay = startDay
    @startDate = new Date(startYear, startMonth, startDay)
    @endYear = endYear
    @endMonth = endMonth
    @endDay = endDay
    @endDate = new Date(endYear, endMonth, endDay)
    @locationName = locationName
    @long = long
    @lat = lat
    @category = category
    @content = content
    @description = description
    @mmIDs = mmIDs

