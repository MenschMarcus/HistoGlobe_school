#include Hivent.coffee

window.HG ?= {}

class HG.HiventBuilder

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  # config =
  #   hiventServerName: string -- name of the server
  #   hiventDatabaseName: string -- name of the database
  #   hiventTableName: string -- name of the table
  #   multimediaServerName: string -- name of the server
  #   multimediaDatabaseName: string -- name of the database
  #   multimediaTableName: string -- name of the table
  constructor: (config) ->
    @_config = config

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
      hiventMultimedia        = columns[10]

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
            })

        loadFinished = () ->
          loadedIds.length is hiventMMIDs.length

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

  # # ============================================================================
  # constructDBStringFromHivent: (hivent, successCallback) ->

  #   successCallback?= (hiventString) -> console.log hiventString

  #   hiventString = hivent.id + '|' + hivent.name + '|' + hivent.description + '|' +
  #                  hivent.startDay + '.' + hivent.startMonth + '.' + hivent.startYear + '|' +
  #                  hivent.endDay + '.' + hivent.endMonth + '.' + hivent.endYear + '|' +
  #                  hivent.locationName + '|' + hivent.long + '|' + hivent.lat + '|' +
  #                  hivent.category + '|' + hivent.mmIDs

  #   successCallback hiventString

  ############################### INIT FUNCTIONS ###############################



  ############################# MAIN FUNCTIONS #################################
  _createHivent: (hiventID, hiventName, hiventDescription, hiventStartDate,
                  hiventEndDate, hiventDisplayDate, hiventLocation, hiventLong, hiventLat,
                  hiventCategory, hiventMMIDs, mmHtmlString) ->

    #check whether location is set
    locationString = ''
    if hiventLocation != ''
      locationString = hiventLocation + ','

    #concatenate content
    content = '\t<h3>' + locationString + hiventDisplayDate + '</h3>\n' +
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
      mm.thumbnail = "data/hivent_icons/icon_join.png"

    mm

  # ============================================================================
  _waitFor: (condition, successCallback) =>
    window.setTimeout (() =>
      unless condition()
        @_waitFor condition, successCallback

      else successCallback()), 100

  IFRAME_CRITERIA = ['flv', 'ogv', 'mp4', 'ogg']

