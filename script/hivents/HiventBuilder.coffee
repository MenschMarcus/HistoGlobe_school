#include Hivent.coffee

window.HG ?= {}

class HG.HiventBuilder

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_config = config

  # ============================================================================
  constructHiventFromArray: (dataArray, pathIndex, successCallback) ->
    if dataArray isnt []
      successCallback?= (hivent) -> console.log hivent

      hiventID          = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventID]
      hiventName        = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventName]
      hiventDescription = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventDescription]
      hiventStartDate   = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventStartDate]
      hiventEndDate     = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventEndDate]
      hiventDisplayDate = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventDisplayDate]
      hiventLocation    = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventLocation]
      hiventLat         = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventLat]
      hiventLong        = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventLong]
      hiventCategory    = if dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventCategory] == '' then 'default' else dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventCategory]
      hiventMultimedia  = dataArray[@_config.hiventConfig.indexMappings[pathIndex].hiventMultimedia]

      mmDatabase = {}
      multimediaLoaded = false
      if @_config.multimediaConfig?.dsvPaths?
        parse_config =
          delimiter: @_config.multimediaConfig.delimiter
          header: false

        index = 0
        for dsvPath in @_config.multimediaConfig.dsvPaths
          $.get(dsvPath,
            (data) =>
              pars_result = $.parse data, parse_config
              for result, i in pars_result.results
                unless i+1 in @_config.multimediaConfig.ignoredLines
                  mm =
                    id : result[@_config.multimediaConfig.indexMappings[pathIndex].multimediaID]
                    type : result[@_config.multimediaConfig.indexMappings[pathIndex].multimediaType]
                    description : result[@_config.multimediaConfig.indexMappings[pathIndex].multimediaDescription]
                    link : @_config.multimediaConfig.rootDirs[index] + "/" +
                           result[@_config.multimediaConfig.indexMappings[pathIndex].multimediaLink]

                  mmDatabase["#{mm.id}"] = mm

              multimediaLoaded = true
              index++
          )
      else
        multimediaLoaded = true

      mmLoadFinished = () ->
        multimediaLoaded

      parseMultimedia = () =>

        mmHtmlString = ''
        #get related multimedia
        if hiventMultimedia != ""
          galleryID = hiventID + "_gallery"
          mmHtmlString = '\t<ul class=\"gallery clearfix\">\n'
          hiventMMIDs = hiventMultimedia.split(",")
          galleryTag = ""
          if hiventMMIDs.length > 1
            galleryTag = "[" + galleryID + "]"

          #get all related entries from multimedia database and concatenate html string
          somethingWentWrong = false
          loadedIds = []
          for id in hiventMMIDs
            if mmDatabase.hasOwnProperty id
              entry = mmDatabase["#{id}"]
              mm = @_createMultiMedia entry.type, entry.description, entry.link
              mmHtmlString +=  '\t\t<li><a href="' +
                                mm.link + '" rel="prettyPhoto" ' +
                                galleryTag + ' title="' +
                                mm.description + '" style="background-image:url(\'' +
                                mm.thumbnail + '\')"></a></li>\n'

              loadedIds.push id
            else
              console.error "A multimedia entry with the id #{id} does not exist!"
              somethingWentWrong = true

          loadFinished = () ->
            (loadedIds.length is hiventMMIDs.length) or somethingWentWrong

          loadSuccessFunction = () =>
            mmHtmlString += "\t</ul>\n"
            successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
                                    hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                                    hiventCategory, hiventMultimedia, mmHtmlString)

          @_waitFor loadFinished, loadSuccessFunction

        else
          successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
                                      hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                                      hiventCategory, hiventMultimedia, '')

      @_waitFor mmLoadFinished, parseMultimedia


  # ============================================================================
  constructHiventFromDBString: (dataString, successCallback) ->
    if dataString != ""
      successCallback?= (hivent) -> console.log hivent

      columns = dataString.split("|")

      hiventID          = columns[0]
      hiventName        = columns[1]
      hiventDescription = columns[2]
      hiventStartDate   = columns[3]
      hiventEndDate     = columns[4]
      hiventDisplayDate = columns[5]
      hiventLocation    = columns[6]
      hiventLat         = columns[7]
      hiventLong        = columns[8]
      hiventCategory    = if columns[9] == '' then 'default' else columns[9]
      hiventMultimedia  = columns[10]

      mmHtmlString = ''

      #get related multimedia
      if hiventMultimedia != ""
        galleryID = hiventID + "_gallery"
        mmHtmlString = '\t<ul class=\"gallery clearfix\">\n'
        hiventMMIDs = hiventMultimedia.split(",")
        galleryTag = ""
        if hiventMMIDs.length > 1
          galleryTag = "[" + galleryID + "]"

        #get all related entries from multimedia database and concatenate html string
        loadedIds = []
        somethingWentWrong = false
        for id in hiventMMIDs
          $.ajax({
              url: "php/query_database.php?"+
                    "serverName=#{@_config.multimediaServerName}"+
                    "&dbName=#{@_config.multimediaDatabaseName}"+
                    "&tableName=#{@_config.multimediaTableName}"+
                    "&condition=id=" + "'#{id}'",
              success: (data) =>
                cols = data.split "|"
                mm = @_createMultiMedia cols[1], cols[2], cols[3]
                mmHtmlString +=  '\t\t<li><a href=\"' +
                                  mm.link + '\" rel=\"prettyPhoto' +
                                  galleryTag + '\" title=\"' +
                                  mm.description + '\"> <img src=\"' +
                                  mm.thumbnail + '\" width=\"60px\" /></a></li>\n'

                loadedIds.push id

              error: () =>
                somethingWentWrong = true
            })

        loadFinished = () ->
          (loadedIds.length is hiventMMIDs.length) or somethingWentWrong

        loadSuccessFunction = () =>
          mmHtmlString += "\t</ul>\n"
          successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
                                  hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                                  hiventCategory, hiventMultimedia, mmHtmlString)

        @_waitFor loadFinished, loadSuccessFunction


      else
        successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
                                    hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                                    hiventCategory, hiventMultimedia, '')

  # ============================================================================
  constructHiventFromJSON: (jsonHivent, successCallback) ->
    if jsonHivent?
      successCallback?= (hivent) -> console.log hivent

      hiventID          = jsonHivent.id
      hiventName        = jsonHivent.name
      hiventDescription = jsonHivent.description
      hiventStartDate   = jsonHivent.startDate
      hiventEndDate     = jsonHivent.endDate
      hiventDisplayDate = jsonHivent.displayDate
      hiventLocation    = jsonHivent.location
      hiventLat         = jsonHivent.lat
      hiventLong        = jsonHivent.long
      hiventCategory    = if jsonHivent.category == '' then 'default' else jsonHivent.category
      hiventMultimedia  = jsonHivent.multimedia

      mmDatabase = {}
      multimediaLoaded = false
      if @_config.multimediaJSONPaths?
        for multimediaJSONPath in @_config.multimediaJSONPaths
          $.getJSON(multimediaJSONPath, (multimedia) =>

            for mm in multimedia
              mmDatabase["#{mm.id}"] = mm

            multimediaLoaded = true
          )
      else
        multimediaLoaded = true

      mmLoadFinished = () ->
        multimediaLoaded

      parseMultimedia = () =>

        mmHtmlString = ''
        #get related multimedia
        if hiventMultimedia != ""
          galleryID = hiventID + "_gallery"
          mmHtmlString = '\t<ul class=\"gallery clearfix\">\n'
          hiventMMIDs = hiventMultimedia.split(",")
          galleryTag = ""
          if hiventMMIDs.length > 1
            galleryTag = "[" + galleryID + "]"

          #get all related entries from multimedia database and concatenate html string
          somethingWentWrong = false
          loadedIds = []
          for id in hiventMMIDs
            if mmDatabase.hasOwnProperty id
              entry = mmDatabase["#{id}"]
              mm = @_createMultiMedia entry.type, entry.description, entry.link
              mmHtmlString +=  '\t\t<li><a href=\"' +
                                mm.link + '\" rel=\"prettyPhoto' +
                                galleryTag + '\" title=\"' +
                                mm.description + '\"> <img src=\"' +
                                mm.thumbnail + '\" width=\"60px\" /></a></li>\n'

              loadedIds.push id
            else
              console.error "A multimedia entry with the id #{id} does not exist!"
              somethingWentWrong = true

          loadFinished = () ->
            (loadedIds.length is hiventMMIDs.length) or somethingWentWrong

          loadSuccessFunction = () =>
            mmHtmlString += "\t</ul>\n"
            successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
                                    hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                                    hiventCategory, hiventMultimedia, mmHtmlString)

          @_waitFor loadFinished, loadSuccessFunction

        else
          successCallback @_createHivent(hiventID, hiventName, hiventDescription, hiventStartDate,
                                      hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                                      hiventCategory, hiventMultimedia, '')

      @_waitFor mmLoadFinished, parseMultimedia


  ############################# MAIN FUNCTIONS #################################
  _createHivent: (hiventID, hiventName, hiventDescription, hiventStartDate,
                  hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                  hiventCategory, hiventMMIDs, mmHtmlString) ->

    if hiventID != "" and hiventName != ""

      #check whether location is set
      locationString = ''
      if hiventLocation != ''
        locationString = hiventLocation + ','

      #concatenate content
      content = '\t<h3>' + locationString + " " + hiventDisplayDate + '</h3>\n' +
                mmHtmlString +
                '\t<p>\n\t\t' +
                hiventDescription +
                '\n\t<p>\n'

      startDate = hiventStartDate.split '.'
      endDate = hiventEndDate.split '.'

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


  # ============================================================================
  _createMultiMedia: (type, description, link) ->
    mm = {
      "type": type
      "description": description
      "link": link
      "thumbnail": link
    }

    linkData = link.split(".")
    if linkData[linkData.length-1] in IFRAME_CRITERIA
      mm.link += "?iframe=true"
      mm.thumbnail = "data/video.png"

    mm

  # ============================================================================
  _waitFor: (condition, successCallback) =>
    window.setTimeout (() =>
      unless condition()
        @_waitFor condition, successCallback

      else successCallback()), 100

  IFRAME_CRITERIA = ['flv', 'ogv', 'mp4', 'ogg']

