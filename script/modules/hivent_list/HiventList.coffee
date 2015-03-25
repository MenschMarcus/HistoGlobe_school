window.HG ?= {}

class HG.HiventList

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onHiventListChanged"
    @addCallback "onUpdateTheme"

    @props =
      active: false
      heigth_hivent_list: 0
      heigth_options: 0
      boder: 0

    @theme = ''

  #   --------------------------------------------------------------------------
  hgInit: (hgInstance) ->

    @_hgInstance = hgInstance
    @_hgInstance.hivent_list_module = @

    @_container = document.createElement "div"
    @_container.className = "hivent-list-module"
    @_hgInstance._top_area.appendChild @_container
    @_allTopics = @_hgInstance.timeline._config.topics
    console.log @_hgInstance.timeline.getTopics()
    @_hivent_array = []
    @_hivent_list = document.createElement "div"
    @_hivent_list.className = "hivent-list"
    @_hivent_headline = document.createElement "div"
    @_hivent_headline.className = "hivent-list-headline"
    @_alliances_option = document.createElement "div"
    @_alliances_option.className = "hivent-list-alliances"


    @_hgInstance.onAllModulesLoaded @, () =>
      @_hgInstance.onActive
      @_hgInstance.search_box_area?.onSearchBoxChanged @, (search_props) =>
        if @props.active
          if search_props.active
            @props.height_hivent_list = 0
            @props.heigth_options = 0
            @props.boder = 0
          else
            @props.height_hivent_list = (window.innerHeight - 190 - 53 - 43)
            @props.heigth_options = 43
            @props.boder = 1
        $(@_hivent_list).css({'max-height': (@props.height_hivent_list) + "px"}) # max height of list with timelin height
        $(@_alliances_option).css({'max-height':(@props.heigth_options) + "px"})
        $(@_alliances_option).css({'border-bottom': (@props.border) + "px"})

    @_hgInstance.onTopAreaSlide @, (t) =>
      if @_hgInstance.isInMobileMode()
        @_container.style.left = "#{t*0.5}px"
      else
        @_container.style.left = "0px"

  # ============================================================================

  addHiventList: () ->
    @_addHiventList

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addHiventList: () ->

    # remove results if input list is empty
    if @_hivent_array.length > 0
      @_container.removeChild @_hivent_list
      @_container.removeChild @_hivent_headline
      @_container.removeChild @_alliances_option

    # Hivents ==================================================================

    @_hivent_array = []
    if @_hgInstance.hiventController._hiventHandles?
      for hivent in @_hgInstance.hiventController._hiventHandles


        if @_hgInstance.categoryFilter._categoryFilter[0] == hivent._hivent.category
          hivent.onActive @, ()->
            console.log @_hgInstance.categoryFilter._categoryFilter[0]
            console.log hivent._hivent.category
            console.log document.getElementsByClassName(hivent.id)[0]
            document.getElementsByClassName(hivent.id)[0].style.color= "red"
            0

          @_hivent_array.push hivent._hivent

    #############################################################
    console.log @_allTopics
    console.log @_hgInstance.categoryFilter.getCurrentFilter()[0]
    #############################################################

    aktualleCath = ""
    if @_hgInstance.categoryFilter.getCurrentFilter()[0] != "bipolar"
      @theme = ""
      @notifyAll "onUpdateTheme", @theme

    for topic in @_allTopics
      if topic.id == @_hgInstance.categoryFilter.getCurrentFilter()[0]
        aktualleCath = topic.name

    headline = '<div>' + 'Aktuelles Thema: ' + aktualleCath + '</div>'

    alliances = '<div class="alliances-content"> Millitärbündnisse </div>'

    hivents = '<ul>'

    for hivent in @_hivent_array
      yearString = ''
      if hivent.startYear == hivent.endYear
        yearString = hivent.startYear
      else
        yearString = hivent.startYear + ' bis ' + hivent.endYear

      hivents += '<a href="#event=' + hivent.id +
                 '"><li class="' + hivent.id + '"><div class="wrap" ><div class="res_name"> ' +
                  hivent.name + '</div><div class="res_location">' + hivent.locationName[0] +
                  '</div><div class="res_year">' + yearString + '</div></div><i class="fa fa-map-marker"></i></li></a>'

    hivents += '</ul>'


    # some stuff to do
    @_hivent_headline.innerHTML = headline
    @_alliances_option.innerHTML = alliances
    @_hivent_list.innerHTML = hivents

    if @_hivent_array.length > 0
      @_container.appendChild @_hivent_headline
      @_container.appendChild @_alliances_option
      @_container.appendChild @_hivent_list
      @props.active = true
    else
      @props.active = false

    if @_hgInstance.search_box_area.props.active
      @props.height_hivent_list = 0
      @props.heigth_options = 0
      @props.border = 0
    else
      @props.height_hivent_list = (window.innerHeight - 190 - 53 - 43)
      @props.heigth_options = 43
      @props.border = 1

    $(@_hivent_list).css({'max-height': (@props.height_hivent_list) + "px"}) # max height of list with timelin height
    $(@_alliances_option).css({'max-height':(@props.heigth_options) + "px"})
    $(@_alliances_option).css({'border-bottom': (@props.border) + "px"})

    if @_hgInstance.categoryFilter.getCurrentFilter()[0] != "bipolar"
      $(@_alliances_option).css({'max-height':0 + "px"})

    @notifyAll "onHiventListChanged", @props

    $(@_alliances_option).click () =>
      # hivent list alliaces click
      if @theme? && @theme != ""
        @theme = ""
      else
        if @_hgInstance.categoryFilter.getCurrentFilter()[0] == "bipolar"
          @theme = "bipolarAlliances"
        else
          @theme = ""
      @notifyAll "onUpdateTheme", @theme

    return @_hivent_list

    #=============================================================================
