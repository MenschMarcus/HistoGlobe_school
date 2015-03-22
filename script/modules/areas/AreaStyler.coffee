window.HG ?= {}

class HG.AreaStyler

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->

    defaultConfig =
      normalStyle:
        areaColor:      "#FCFCFC",
        areaOpacity:    0.75,
        borderWidth:    1.0,
        borderColor:    "#BBBBBB",
        borderOpacity:  1.0,
        nameSize:       1,
        nameColor:      "#BBBBBB",
        nameOpacity:    1.0

    @_config = $.extend {}, defaultConfig, config

    ## get mapping: country -> theme -> time period
    @_loadMappingFromCSV config

    ## calculate styles
    # normal style: if not in modules.json, take default config

    # highlight style:  if not in modules.json, take normal style = no highlight style
    if @_config.highlightStyle?
      @_config.highlightStyle.areaColor     = @_config.highlightStyle.areaColor ? @_config.normalStyle.areaColor
      @_config.highlightStyle.areaOpacity   = @_config.highlightStyle.areaOpacity ? @_config.normalStyle.areaOpacity
      @_config.highlightStyle.borderWidth   = @_config.highlightStyle.borderWidth ? @_config.normalStyle.borderWidth
      @_config.highlightStyle.borderColor   = @_config.highlightStyle.borderColor ? @_config.normalStyle.borderColor
      @_config.highlightStyle.borderOpacity = @_config.highlightStyle.borderOpacity ? @_config.normalStyle.borderOpacity
      @_config.highlightStyle.nameSize      = @_config.highlightStyle.nameSize ? @_config.normalStyle.nameSize
      @_config.highlightStyle.nameColor     = @_config.highlightStyle.nameColor ? @_config.normalStyle.nameColor
      @_config.highlightStyle.nameOpacity   = @_config.highlightStyle.nameOpacity ? @_config.normalStyle.nameOpacity
    else
      @_config.highlightStyle = @_config.normalStyle

    # theme styles: take from modules.json and take normal style as fallback style
    if @_config.themeStyles?
      for themeName, themeClasses of @_config.themeStyles
        for themeClassName, themeClassStyle of themeClasses
          themeClassStyle.areaColor     = themeClassStyle.areaColor ? @_config.normalStyle.areaColor
          themeClassStyle.areaOpacity   = themeClassStyle.areaOpacity ? @_config.normalStyle.areaOpacity
          themeClassStyle.borderWidth   = themeClassStyle.borderWidth ? @_config.normalStyle.borderWidth
          themeClassStyle.borderColor   = themeClassStyle.borderColor ? @_config.normalStyle.borderColor
          themeClassStyle.borderOpacity = themeClassStyle.borderOpacity ? @_config.normalStyle.borderOpacity
          themeClassStyle.nameSize      = themeClassStyle.nameSize ? @_config.normalStyle.nameSize
          themeClassStyle.nameColor     = themeClassStyle.nameColor ? @_config.normalStyle.nameColor
          themeClassStyle.nameOpacity   = themeClassStyle.nameOpacity ? @_config.normalStyle.nameOpacity

    # translate the style from the user point of view to the leaflet point of view
    @_normalStyle     = @_config.normalStyle
    @_highlightStyle  = @_config.highlightStyle

    # theme style structure:
    # each theme has a name and can have multpile classes, each class has a name and a style
    # => array of theme objects (name, classes), theme class as array of theme class objects (name, style)
    @_themeStyles     = []
    if @_config.themeStyles?
      for themeName, themeClasses of @_config.themeStyles
        theme = {}
        theme.themeName = themeName
        theme.themeClasses = []
        for className, classStyle of themeClasses
          themeClass = {}
          themeClass.className = className
          themeClass.classStyle = classStyle
          theme.themeClasses.push themeClass
        @_themeStyles.push theme

  # ============================================================================
  hgInit: (hgInstance) ->

    hgInstance.areaStyler = @

  # ============================================================================
  getNormalStyle: () ->
    @_normalStyle

  # ============================================================================
  getHighlightStyle: () ->
    @_highlightStyle

  # ============================================================================
  # given country id and theme and current date
  # return style of the country at this point
  getCountryStyle: (inCountryId, inThemeName, inNowDate) ->
    countryStyle = null

    # find theme in stored theme styles
    themeFound = no
    for theme in @_themeStyles
      if theme.themeName == inThemeName
        themeFound = yes

        # find country in stored country-theme-mappings
        for country in @_countryThemeMappings
          if country.countryId == inCountryId

            # get style for theme class of given country in stored theme styles
            for themeClass in theme.themeClasses
              if themeClass.className == country.themeClass

                # check if style currently active
                if inNowDate >= country.startDate and inNowDate < country.endDate

                  # final assignment of output style
                  countryStyle = themeClass.classStyle
                  break

    if not themeFound
      console.error "requested theme '" + themeName + "' not found."

    countryStyle

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _loadMappingFromCSV: (config) ->

    @_countryThemeMappings = []

    if config.countryThemeMapping?

      # interpret each mapping as an own config
      # file path, to be ignored header lines of csv file and indices mapped to data
      for mappingConfig in config.countryThemeMapping

        defaultConfig =
          csvFilePath:    ""
          delimiter:      ","
          indexMapping:
            countryId:    0
            themeClass:   1
            startDate:    2
            endDate:      3

        mappingConfig = $.extend {}, defaultConfig, mappingConfig

        # load file
        $.get mappingConfig.csvFilePath, (data) =>
          parseResult = $.parse data
          # load mapping data for each row
          # each row is already an object, not an array! -> no indexMapping needed
          # N.B: data MUST have these column names, but order can be inpedendent:
          # country_id, theme_class, start_date, end_date
          for row in parseResult.results.rows

            # error handling for not given start and end dates
            startDate = row.start_date ?= 0
            endDate   = row.end_date   ?= 9999

            # final mapping object
            @_countryThemeMappings.push {
              countryId:  row.country_id
              themeClass: row.theme_class
              # create date objects from input date strings/numbers
              startDate:  new Date startDate.toString()
              endDate:    new Date endDate.toString()
            }
