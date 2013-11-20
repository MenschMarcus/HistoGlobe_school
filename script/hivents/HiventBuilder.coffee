#include Hivent.coffee

window.HG ?= {}

class HG.HiventBuilder

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: () ->

  # ============================================================================
  constructHivent: (dataString) ->
    if dataString != ""
      columns = dataString.split("|")

      hiventID          = columns[0]
      hiventName        = columns[1]
      hiventDescription = columns[2]
      hiventStartDate   = columns[3]
      hiventEndDate     = columns[4]
      hiventLocation    = columns[5]
      hiventLong        = columns[7]
      hiventLat         = columns[6]
      hiventCategory    = columns[8]
      hiventMMIDs       = columns[9]

      mmHtmlString = ""

      #get corresponding multimedia
      if hiventMMIDs != ""
        galleryID = hiventID + "_gallery"
        mmHtmlString = '\t<ul class=\"gallery clearfix\">\n'
        hiventMMIDs = hiventMMIDs.split(",")
        galleryTag = ""
        if hiventMMIDs.length > 1
          galleryTag = "[" + galleryID + "]"
        for id in hiventMMIDs
          $.ajax({
              url: "php/query_database.php?dbName=hivents&tableName=hivent_multimedia&condition=ID=" + "'#{id}'",
              success: (data) =>
                # console.log id
                cols = data.split "|"

                mm = @_createMultiMedia cols[1], cols[2], cols[3]
                mmHtmlString +=  '\t\t<li><a href=\"' +
                                  mm.link + '\" rel=\"prettyPhoto' +
                                  galleryTag + '\" title=\"' +
                                  mm.description + '\"> <img src=\"' +
                                  mm.thumbnail + '\" width=\"60px\" /></a></li>\n'
                if id == hiventMMIDs[hiventMMIDs.length-1]
                  mmHtmlString += "\t</ul>\n"
                  # console.log mmHtmlString
            })


  ############################### INIT FUNCTIONS ###############################



  ############################# MAIN FUNCTIONS #################################

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

  IFRAME_CRITERIA = ['flv', 'ogv', 'mp4', 'ogg']

