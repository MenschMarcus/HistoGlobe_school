window.HG ?= {}

class HG.HiventList

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  constructor: (config) ->

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onHiventListChanged"

    @props = 
      active: false
      heigth: 0

  #   --------------------------------------------------------------------------
  hgInit: (hgInstance) ->



    @_hgInstance = hgInstance
    @_hgInstance.hivent_list_module = @

    @_container = document.createElement "div"
    @_container.className = "hivent-list-module"
    @_hgInstance._top_area.appendChild @_container
    @_allTopics = @_hgInstance.timeline._config.topics
    @_hivent_array = []
    @_hivent_list = document.createElement "div"
    @_hivent_list.className = "hivent-list"


    @_hgInstance.onAllModulesLoaded @, () =>
      @_hgInstance.search_box_area?.onSearchBoxChanged @, (search_props) =>
        if @props.active
          if search_props.active
            @props.height = (window.innerHeight - 180) / 2 
          else
            @props.height = (window.innerHeight - 180)
        console.log "HL" + @props.active
        $(@_hivent_list).css({'max-height': (@props.height - 10) + "px"}) # max height of list with timelin height


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

    # Hivents ==================================================================

    @_hivent_array = []
    if @_hgInstance.hiventController._hiventHandles?
      for hivent in @_hgInstance.hiventController._hiventHandles
        if @_hgInstance.categoryFilter._categoryFilter[0] == hivent._hivent.category
          @_hivent_array.push hivent._hivent

    aktualleCath = "HIVENTORRRR"

    for topic in @_allTopics
      if topic.id == @_hgInstance.categoryFilter.getCurrentFilter()[0]
        aktualleCath = topic.name

    hivents = '<div id="hivent-list-headline">' + 'Aktuelle Epoche: ' + aktualleCath + '</div><ul>'

    for hivent in @_hivent_array
      yearString = ''
      if hivent.startYear == hivent.endYear
        yearString = hivent.startYear
      else
        yearString = hivent.startYear + ' bis ' + hivent.endYear

      hivents += '<a href="#event=' + hivent.id +
                 '"><li><div class="wrap"><div class="res_name"> ' +
                  hivent.name + '</div><div class="res_location">' + hivent.locationName[0] +
                  '</div><div class="res_year">' + yearString + '</div></div><i class="fa fa-map-marker"></i></li></a>'

    hivents += '</ul>'

    @_hivent_list.innerHTML = hivents
    
    if @_hivent_array.length > 0
      @_container.appendChild @_hivent_list
      @props.active = true
    else
      @props.active = false

    if @_hgInstance.search_box_area.props.active
      @props.height = (window.innerHeight - 180) / 2 
    else
      @props.height = (window.innerHeight - 180)

    $(@_hivent_list).css({'max-height': (@props.height - 10) + "px"}) # max height of list with timelin height

    @notifyAll "onHiventListChanged", @props

    return @_hivent_list

    #=============================================================================
