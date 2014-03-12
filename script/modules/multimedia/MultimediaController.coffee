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
      delimiter: "|"
      ignoredLines: [] # line indices starting at 1
      indexMappings: [
        id          : 0
        type        : 1
        description : 2
        link        : 3
        source      : 4
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
                  result[@_config.indexMappings[pathIndex].type],
                  result[@_config.indexMappings[pathIndex].description],
                  @_config.rootDirs[pathIndex] + "/" +
                         result[@_config.indexMappings[pathIndex].link],
                  result[@_config.indexMappings[pathIndex].source]
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
  _createMultiMedia: (type, description, link, source) ->
    mm = {
      "type": type
      "description": description
      "link": link
      "thumbnail": link
      "source": source
    }

    linkData = link.split(".")
    if linkData[linkData.length-1] in IFRAME_CRITERIA
      mm.link += "?iframe=true"
      mm.thumbnail = "data/video.png"

    mm

  IFRAME_CRITERIA = ['flv', 'ogv', 'mp4', 'ogg']
