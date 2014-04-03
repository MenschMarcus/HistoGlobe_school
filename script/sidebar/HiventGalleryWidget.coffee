window.HG ?= {}

class HG.HiventGalleryWidget extends HG.TimeGalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
  	defaultConfig =
  	  htmlSlides : []

  	@_hivents = []
  	@_hiventHandles = []
  	@_hiventsLoaded = false
  	@_onHiventAddedCallbacks = []

  	@_config = $.extend {}, defaultConfig, config

  	HG.TimeGalleryWidget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @loadHiventsFromDSV()

  # ============================================================================
  addSlide: (config) ->
    defaultConfig =
      date : undefined
      html : undefined

    config = $.extend {}, defaultConfig, config
    date = config.date.split "."
    @_changeDates[@getSlideCount()] = new Date date[2], date[1] - 1, date[0]
    super config.html


  ############################### INIT FUNCTIONS ###############################

  # ============================================================================
  loadHiventsFromDSV: () ->
    if @_config.dsvPaths?
      defaultConfig =
        dsvPaths: []
        delimiter: "|"
        ignoredLines: [] # line indices starting at 1
        indexMappings: [
          id          : 0
          name        : 1
          description : 2
          startDate   : 3
          endDate     : 4
          displayDate : 5
          category    : 6
          multimedia  : 7
        ]

      @_config = $.extend {}, defaultConfig, @_config

      parse_config =
        delimiter: @_config.delimiter
        header: false

      pathIndex = 0
      for dsvPath in @_config.dsvPaths
        $.get dsvPath,
          (data) =>
            parse_result = $.parse data, parse_config
            console.log parse_result
            builder = new HG.HiventBuilder @_config, @_hgInstance.multimediaController
            for result, i in parse_result.results
              unless i+1 in @_config.ignoredLines
                builder.constructHiventFromArray result, pathIndex, (hivent) =>
                  if hivent
                    #handle = new HG.HiventHandle hivent
                    #console.log hivent
                  	@_hivents.push hivent
                  	# slide =
                  	# 	date : hivent.displayDate
                  	# 	html : hivent.name
                  	#@addHTMLSlide slide
                  	#@_hiventHandles.push handle
                  	#callback handle for callback in @_onHiventAddedCallbacks
                    #@_filterHivents()
            pathIndex++

            @_hiventsLoaded = true