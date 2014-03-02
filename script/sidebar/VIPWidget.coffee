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
      copyright: ""

    config = $.extend {}, defaultConfig, config

    div = document.createElement "div"
    div.className = "vip-widget"

    portrait = document.createElement "div"
    portrait.className = "vip-widget-image"
    portrait.style.backgroundImage = "url('#{config.image}')"
    div.appendChild portrait

    name = document.createElement "div"
    name.className = "vip-widget-name"
    name.innerHTML = config.name + "<br/><small><small>" + config.displayDate + "</small></small>"
    portrait.appendChild name

    unless config.copyright is ""
      copyright = document.createElement "div"
      copyright.className = "vip-widget-copyright"
      copyright.innerHTML = config.copyright
      portrait.appendChild copyright

    text = document.createElement "div"
    text.className = "clear vip-widget-text"
    text.innerHTML = config.description
    div.appendChild text

    @addDivSlide {date: config.date, div: div}
