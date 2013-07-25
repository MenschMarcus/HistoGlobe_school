window.HG ?= {}

class HG.Hivent

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (inName, inCategory, inDate, inDisplayDate,
                inLong, inLat, inDescription, inParties) ->


    @name = inName
    @category = inCategory
    @date = inDate
    @displayDate = inDisplayDate
    @long = inLong
    @lat = inLat
    @description = inDescription
    @parties = inParties

