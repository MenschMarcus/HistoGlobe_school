window.HG ?= {}

class HG.MultimediaController

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    @_multimedia = {}
    @_multimediaLoaded = false
    @_onMultimediaLoadedCallbacks = []

    defaultConfig =
      dsvPaths: []
      rootDirs: []
      #delimiter: "|"
      delimiter: ","
      ignoredLines: [] # line indices starting at 1
      indexMappings: [
        id          : 0
        file_type   : 2
        name        : 3
        file_name   : 1
        author      : 4
        source      : 5
        link        : 6
        last_access : 7

        # id          : 0
        # type        : 2
        # description : 3
        # link        : 1
        # source      : 4
        # crop        : 5
        # type        : 6

        #id,file_name,file_type,name, author, source, link,last_access

        # id          : 0
        # type        : 1
        # description : 2
        # link        : 3
        # source      : 4
        # crop        : 5
        # type        : 6

        # "id"          : 0,
        # "type"        : 2,
        # "description" : 3,
        # "source"      : 4,
        # "link"        : 1
      ]

    @_config = $.extend {}, defaultConfig, config

  # ============================================================================
  hgInit: (hgInstance) ->
    hgInstance.multimediaController = @
    @loadMultimediaFromDSV()

  # ============================================================================
  onMultimediaLoaded: (callbackFunc) ->
    if callbackFunc and typeof(callbackFunc) == "function"
      if @_multimediaLoaded
        callbackFunc()
      else
        @_onMultimediaLoadedCallbacks.push callbackFunc

  getMultimediaById: (id) ->
    if @_multimedia.hasOwnProperty id
      return @_multimedia[id]

    console.error "A muldimedia object with the id \"#{id}\" does not exist!"
    return undefined

  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  loadMultimediaFromDSV: (config) ->

    if @_config.dsvPaths?
      parse_config =
        delimiter: @_config.delimiter
        header: false

      pathIndex = 0
      for dsvPath in @_config.dsvPaths
        $.get dsvPath,
          (data) =>
            parse_result = $.parse data, parse_config
            for result, i in parse_result.results
              unless i+1 in @_config.ignoredLines
                mm = @_createMultiMedia(
                  result[@_config.indexMappings[pathIndex].name],
                  result[@_config.indexMappings[pathIndex].file_name],
                  result[@_config.indexMappings[pathIndex].source],
                  result[@_config.indexMappings[pathIndex].author],
                  result[@_config.indexMappings[pathIndex].link],
                  result[@_config.indexMappings[pathIndex].last_access],
                  result[@_config.indexMappings[pathIndex].file_type].toUpperCase(),
                  pathIndex
                )

                @_multimedia[result[@_config.indexMappings[pathIndex].id]] = mm

            if pathIndex == @_config.dsvPaths.length - 1
              @_multimediaLoaded = true
              for callback in @_onMultimediaLoadedCallbacks
                callback()
              @_onMultimediaLoadedCallbacks = []

            else pathIndex++

##############################################################################
#                            PRIVATE INTERFACE                               #
##############################################################################

# ============================================================================
  _createMultiMedia: (name, file_name, link, source, author, file_type, last_access, pathIndex) ->

    mm =
      "name": name
      "file name": file_name
      "link": @_config.rootDirs[pathIndex] + "/" + link
      #"thumbnail": @_config.rootDirs[pathIndex] + "/" + link
      "source": source
      "author": author
      "file type": file_type
      "last access": last_access

    # hack: if link is an image or video on the web
    # use the absolute path do not set local root directory prefix
    if file_type is "WEBIMAGE"
      mm.file_name = file_name

    if file_type is "YOUTUBE"
      mm.file_name = file_name

    mm

  #   linkData = link.split(".")
  #   if linkData[linkData.length-1] in VIDEO_CRITERIA
  #     mm.type = 1
  #     # mm.link += "?iframe=true"
  #     # mm.thumbnail = "data/video.png"

  #   if link.indexOf('youtube') > -1
  #     mm.type = 1
  #     mm.link = link
  #     # mm.thumbnail = "data/video.png"

  #   mm

  # VIDEO_CRITERIA = ['flv', 'ogv', 'mp4', 'ogg']
