window.HG ?= {}

class HG.VIPWidget extends HG.TimeGalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    HG.TimeGalleryWidget.call @, config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

  # ============================================================================
  addPerson: (config) ->
    defaultConfig =
      name: "Max Mustermann",
      date: new Date(1990, 0, 1),
      display_date: "Seit 01.01.1990",
      image: "http://placehold.it/150x150",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                    Nulla vulputate tortor eget justo elementum, ac adipiscing
                    purus luctus. Integer risus quam, feugiat a tincidunt
                    suscipit, gravida vel nulla."

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
    date.innerHTML = config.display_date
    div.appendChild date

    text = document.createElement "div"
    text.className = "clear text"
    text.innerHTML = config.description
    div.appendChild text

    @addDivSlide(config.date, div)
