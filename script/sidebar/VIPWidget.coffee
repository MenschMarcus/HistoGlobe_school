window.HG ?= {}

class HG.VIPWidget extends HG.Widget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    defaultConfig =
      icon: ""
      name: ""
      persons : []

    @_config = $.extend {}, defaultConfig, config

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onSlideChanged"

    @_id = ++LAST_vip_ID

    HG.Widget.call @, @_config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    @_timeline = hgInstance.timeline
    @_timeline.onNowChanged @, @_nowChanged

    @_VIPContent = document.createElement "div"
    @_VIPContent.className = "vip-widget"

    @_dudes = []

    for person, i in @_config.persons
      if person.name?
        personDisplay = document.createElement "div"
        personDisplay.id = "vip-widget-person-display-#{i}"
        personDisplay.className = "vip-person-display"

        portrait = document.createElement "div"
        portrait.className = "vip-widget-image"
        portrait.style.backgroundImage = "url('#{person.image}')"
        personDisplay.appendChild portrait

        name = document.createElement "div"
        name.className = "vip-widget-name"
        name.innerHTML = person.name + "<br/><small>" + person.info + "</small>"
        personDisplay.appendChild name

        @_VIPContent.appendChild personDisplay

        personHandle =
          div: personDisplay
          dude: person

        @_dudes.push personHandle

    @setName @_config.name
    @setIcon @_config.icon
    @setContent @_VIPContent

    @_nowChanged @_timeline.getNowDate()#quickhack

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _nowChanged: (now) =>

    for dude in @_dudes
      startDate = @_timeline.stringToDate dude.dude.startDate
      endDate = @_timeline.stringToDate dude.dude.endDate
      if now.getTime() >= startDate.getTime() && now.getTime() <= endDate.getTime()
        dude.div.style.height = HGConfig.vip_widget_size.val + HGConfig.vip_widget_size.unit
      else
        dude.div.style.height = 0 + "px"

  ##############################################################################
  #                             STATIC MEMBERS                                 #
  ##############################################################################

  LAST_vip_ID = 0
