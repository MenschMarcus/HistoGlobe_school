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
      for themeName, themeStyle of @_config.themeStyles
        themeStyle.areaColor     = themeStyle.areaColor ? @_config.normalStyle.areaColor
        themeStyle.areaOpacity   = themeStyle.areaOpacity ? @_config.normalStyle.areaOpacity
        themeStyle.borderWidth   = themeStyle.borderWidth ? @_config.normalStyle.borderWidth
        themeStyle.borderColor   = themeStyle.borderColor ? @_config.normalStyle.borderColor
        themeStyle.borderOpacity = themeStyle.borderOpacity ? @_config.normalStyle.borderOpacity
        themeStyle.nameSize      = themeStyle.nameSize ? @_config.normalStyle.nameSize
        themeStyle.nameColor     = themeStyle.nameColor ? @_config.normalStyle.nameColor
        themeStyle.nameOpacity   = themeStyle.nameOpacity ? @_config.normalStyle.nameOpacity

        # @_config.themeStyles.themeStyle

    console.log @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    42

  # ============================================================================
  getFallbackStyle: (value) ->
    result =
      style:
        fillColor:    d3.rgb(@_config.fillColor.fallback).toString()
        fillOpacity:  @_config.fillOpacity.fallback
        lineColor:    d3.rgb(@_config.lineColor.fallback).toString()
        lineOpacity:  @_config.lineOpacity.fallback
        lineWidth:    @_config.lineWidth.fallback
        labelOpacity: @_config.labelOpacity.fallback
      compOp:
        fillColor:    @_config.fillColor.compOp
        fillOpacity:  @_config.fillOpacity.compOp
        lineColor:    @_config.lineColor.compOp
        lineOpacity:  @_config.lineOpacity.compOp
        lineWidth:    @_config.lineWidth.compOp
        labelOpacity: @_config.labelOpacity.compOp

  # ============================================================================
  getInterpolatedStyle: (alpha) ->
    result =
      style:
        fillColor:    @_fill_color(alpha)
        fillOpacity:  @_fill_opacity(alpha)
        lineColor:    @_line_color(alpha)
        lineOpacity:  @_line_opacity(alpha)
        lineWidth:    @_line_width(alpha)
        labelOpacity: @_label_opacity(alpha)
      compOp:
        fillColor:    @_config.fillColor.compOp
        fillOpacity:  @_config.fillOpacity.compOp
        lineColor:    @_config.lineColor.compOp
        lineOpacity:  @_config.lineOpacity.compOp
        lineWidth:    @_config.lineWidth.compOp
        labelOpacity: @_config.labelOpacity.compOp

  # ============================================================================
  getStyle: (value) ->

    unless value?
      return @getFallbackStyle()

    if value >= @_config.domain[0] and value <= @_config.domain[@_config.domain.length-1]
      return @getInterpolatedStyle value

    else
      return @getFallbackStyle()

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
            theme:        1
            startDate:    2
            endDate:      3

        mappingConfig = $.extend {}, defaultConfig, mappingConfig

        # load file
        $.get mappingConfig.csvFilePath, (data) =>
          parseResult = $.parse data
          # load mapping data for each row
          # each row is already an object, not an array! -> no indexMapping needed
          # N.B: data MUST have these column names, but order can be inpedendent:
          # country_id, theme, start_date, end_date
          for row in parseResult.results.rows

            # error handling for not given start and end dates
            startDate = row.start_date ?= 0
            endDate   = row.end_date   ?= 9999

            # final mapping object
            @_countryThemeMappings.push {
              countryId:  row.country_id
              theme:      row.theme
              # create date objects from input date strings/numbers
              startDate:  new Date startDate.toString()
              endDate:    new Date endDate.toString()
            }
