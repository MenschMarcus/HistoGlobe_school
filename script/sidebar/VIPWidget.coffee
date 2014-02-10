window.HG ?= {}

class HG.VIPWidget extends HG.TimeGalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      persons : []

    @_config = $.extend {}, defaultConfig, config

    HG.TimeGalleryWidget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    for person in @_config.persons
      @addPerson person

  # ============================================================================
  addPerson: (config) ->
    defaultConfig =
      name: ""
      date: ""
      displayDate: ""
      image: ""
      description: ""

    config = $.extend {}, defaultConfig, config

    div = document.createElement "div"
    div.className = "vip-widget"

    portrait = document.createElement "img"
    portrait.src = config.image
    div.appendChild portrait

    name = document.createElement "div"
    name.className = "name"
    name.innerHTML = config.name
    div.appendChild name

    date = document.createElement "div"
    date.className = "date"
    date.innerHTML = config.displayDate
    div.appendChild date

    text = document.createElement "div"
    text.className = "clear text"
    text.innerHTML = config.description
    div.appendChild text

    @addDivSlide {date: config.date, div: div}
