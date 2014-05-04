#include Hivent.coffee

window.HG ?= {}

class HG.HiventBuilder

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config, multimediaController) ->
    @_config = config
    @_multimediaController = multimediaController

  # ============================================================================
  constructHiventFromArray: (dataArray, pathIndex, successCallback) ->
    if dataArray isnt []
      successCallback?= (hivent) -> console.log hivent

      ID          = dataArray[@_config.indexMappings[pathIndex].id]
      name        = dataArray[@_config.indexMappings[pathIndex].name]
      description = dataArray[@_config.indexMappings[pathIndex].description]
      startDate   = dataArray[@_config.indexMappings[pathIndex].startDate]
      endDate     = dataArray[@_config.indexMappings[pathIndex].endDate]
      displayDate = dataArray[@_config.indexMappings[pathIndex].displayDate]
      location    = dataArray[@_config.indexMappings[pathIndex].location]
      lat         = dataArray[@_config.indexMappings[pathIndex].lat]
      long        = dataArray[@_config.indexMappings[pathIndex].long]
      category    = if dataArray[@_config.indexMappings[pathIndex].category] == '' then 'default' else dataArray[@_config.indexMappings[pathIndex].category]
      multimedia  = dataArray[@_config.indexMappings[pathIndex].multimedia]

      successCallback @_createHivent(ID, name, description, startDate,
                                    endDate, displayDate, location, long, lat,
                                    category, multimedia)


  # ============================================================================
  # constructHiventFromDBString: (dataString, successCallback) ->
  #   if dataString != ""
  #     successCallback?= (hivent) -> console.log hivent

  #     columns = dataString.split("|")

  #     hiventID          = columns[0]
  #     hiventName        = columns[1]
  #     hiventDescription = columns[2]
  #     hiventStartDate   = columns[3]
  #     hiventEndDate     = columns[4]
  #     hiventDisplayDate = columns[5]
  #     hiventLocation    = columns[6]
  #     hiventLat         = columns[7]
  #     hiventLong        = columns[8]
  #     hiventCategory    = if columns[9] == '' then 'default' else columns[9]
  #     hiventMultimedia  = columns[10]

  #     mmHtmlString = ''

  #     #get related multimedia
  #     if hiventMultimedia != ""
  #       galleryID = hiventID + "_gallery"
  #       mmHtmlString = '\t<ul class=\"gallery clearfix\">\n'
  #       hiventMMIDs = hiventMultimedia.split(",")
  #       galleryTag = ""
  #       if hiventMMIDs.length > 1
  #         galleryTag = "[" + galleryID + "]"

  #       #get all related entries from multimedia database and concatenate html string
  #       loadedIds = []
  #       somethingWentWrong = false
  #       for id in hiventMMIDs
  #         $.ajax({
  #             url: "php/query_database.php?"+
  #                   "serverName=#{@_config.multimediaServerName}"+
  #                   "&dbName=#{@_config.multimediaDatabaseName}"+
  #                   "&tableName=#{@_config.multimediaTableName}"+
  #                   "&condition=id=" + "'#{id}'",
  #             success: (data) =>
  #               cols = data.split "|"
  #               mm = @_createMultiMedia cols[1], cols[2], cols[3]
  #               mmHtmlString +=  '\t\t<li><a href=\"' +
  #                                 mm.link + '\" rel=\"prettyPhoto' +
  #                                 galleryTag + '\" title=\"' +
  #                                 mm.description + '\"> <img src=\"' +
  #                                 mm.thumbnail + '\" width=\"60px\" /></a></li>\n'

  #               loadedIds.push id

  #             error: () =>
  #               somethingWentWrong = true
  #           })

  #       loadFinished = () ->
  #         (loadedIds.length is hiventMMIDs.length) or somethingWentWrong

  #       loadSuccessFunction = () =>
  #         mmHtmlString += "\t</ul>\n"
  #         successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
  #                                 hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
  #                                 hiventCategory, hiventMultimedia, mmHtmlString)

  #       @_waitFor loadFinished, loadSuccessFunction


  #     else
  #       successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
  #                                   hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
  #                                   hiventCategory, hiventMultimedia, '')

  # # ============================================================================
  # constructHiventFromJSON: (jsonHivent, successCallback) ->
  #   if jsonHivent?
  #     successCallback?= (hivent) -> console.log hivent

  #     hiventID          = jsonHivent.id
  #     hiventName        = jsonHivent.name
  #     hiventDescription = jsonHivent.description
  #     hiventStartDate   = jsonHivent.startDate
  #     hiventEndDate     = jsonHivent.endDate
  #     hiventDisplayDate = jsonHivent.displayDate
  #     hiventLocation    = jsonHivent.location
  #     hiventLat         = jsonHivent.lat
  #     hiventLong        = jsonHivent.long
  #     hiventCategory    = if jsonHivent.category == '' then 'default' else jsonHivent.category
  #     hiventMultimedia  = jsonHivent.multimedia

  #     mmDatabase = {}
  #     multimediaLoaded = false
  #     if @_config.multimediaJSONPaths?
  #       for multimediaJSONPath in @_config.multimediaJSONPaths
  #         $.getJSON(multimediaJSONPath, (multimedia) =>

  #           for mm in multimedia
  #             mmDatabase["#{mm.id}"] = mm

  #           multimediaLoaded = true
  #         )
  #     else
  #       multimediaLoaded = true

  #     mmLoadFinished = () ->
  #       multimediaLoaded

  #     parseMultimedia = () =>

  #       mmHtmlString = ''
  #       #get related multimedia
  #       if hiventMultimedia != ""
  #         galleryID = hiventID + "_gallery"
  #         mmHtmlString = '\t<ul class=\"gallery clearfix\">\n'
  #         hiventMMIDs = hiventMultimedia.split(",")
  #         galleryTag = ""
  #         if hiventMMIDs.length > 1
  #           galleryTag = "[" + galleryID + "]"

  #         #get all related entries from multimedia database and concatenate html string
  #         somethingWentWrong = false
  #         loadedIds = []
  #         for id in hiventMMIDs
  #           if mmDatabase.hasOwnProperty id
  #             entry = mmDatabase["#{id}"]
  #             mm = @_createMultiMedia entry.type, entry.description, entry.link
  #             mmHtmlString +=  '\t\t<li><a href=\"' +
  #                               mm.link + '\" rel=\"prettyPhoto' +
  #                               galleryTag + '\" title=\"' +
  #                               mm.description + '\"> <img src=\"' +
  #                               mm.thumbnail + '\" width=\"60px\" /></a></li>\n'

  #             loadedIds.push id
  #           else
  #             console.error "A multimedia entry with the id #{id} does not exist!"
  #             somethingWentWrong = true

  #         loadFinished = () ->
  #           (loadedIds.length is hiventMMIDs.length) or somethingWentWrong

  #         loadSuccessFunction = () =>
  #           mmHtmlString += "\t</ul>\n"
  #           successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
  #                                   hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
  #                                   hiventCategory, hiventMultimedia, mmHtmlString)

  #         @_waitFor loadFinished, loadSuccessFunction

  #       else
  #         successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
  #                                     hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
  #                                     hiventCategory, hiventMultimedia, '')

  #     @_waitFor mmLoadFinished, parseMultimedia


  ############################# MAIN FUNCTIONS #################################
  _createHivent: (hiventID, hiventName, hiventDescription, hiventStartDate,
                  hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                  hiventCategory, hiventMMIDs) ->

    if hiventID != "" and hiventName != ""

      #concatenate content
      content = '<p>' + hiventDescription + '<p>'

      startDate = hiventStartDate.split '.'
      endDate = hiventEndDate.split '.'
      hiventLocation = hiventLocation?.replace(/\s*;\s*/g, ';').split(';')
      hiventLat = "#{hiventLat}".replace(/\s*;\s*/g, ';').split(';') if hiventLat?
      hiventLong = "#{hiventLong}".replace(/\s*;\s*/g, ';').split(';') if hiventLong?

      hivent = new HG.Hivent(
        hiventID,
        hiventName,
        startDate[2],
        startDate[1],
        startDate[0],
        endDate[2],
        endDate[1],
        endDate[0],
        hiventDisplayDate,
        hiventLocation,
        hiventLong,
        hiventLat,
        hiventCategory,
        content,
        hiventDescription,
        hiventMMIDs
      )

      hivent
