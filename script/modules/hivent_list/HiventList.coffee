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
    #console.log "Timeline Topics", @_hgInstance.timeline.getTopics()
    @_hivent_array = []
    @_hivent_list = document.createElement "div"
    @_hivent_list.className = "hivent-list"
    @_hivent_headline = document.createElement "div"
    @_hivent_headline.className = "hivent-list-headline"
    @_alliances_option = document.createElement "div"
    @_alliances_option.className = "hivent-list-alliances"
    @_container = document.createElement "div"
    @_container.className = "hivent-list-module"
    @_hgInstance._top_area.appendChild @_container

    @_hgInstance.hivent_list_module = @

    window.hgInstance=@_hgInstance

    $(@_hivent_list).on("click", ".hiventListItem",  ->
      id=this.id
      handle=window.hgInstance.hiventController.getHiventHandleById(id)
      handle.toggleActive(@, 0)        
      )
    $(@_hivent_list).on("mouseenter", ".hiventListItem",  ->      
      id=this.id      
      handle=window.hgInstance.hiventController.getHiventHandleById(id)
      handle.mark @, 0
      handle.linkAll @, 0          
      ).on("mouseleave", ".hiventListItem", ->
        id=this.id
        
        handle=window.hgInstance.hiventController.getHiventHandleById(id)

        if !handle._activated
          handle.unMark @, 0
          handle.unLinkAll @, 0   
      )

    handels=window.hgInstance.hiventController.getHivents()

    
    $(@_alliances_option).click () =>
      knopp = $(".toggle_on_off")
      display_knopp = $(".legend_table")
      # hivent list alliaces click
      if @theme == ''
        @theme = 'bipolarAlliances'
        knopp.removeClass "switch-off"
        knopp.addClass "switch-on"
        display_knopp.removeClass "display_off"
        display_knopp.addClass "display_on"
        $(@_hivent_list).css({'max-height': ((window.innerHeight - 190 - 53 - 43 - 71)) + "px"})
      else
        @theme = ''
        knopp.removeClass "switch-on"
        knopp.addClass "switch-off"
        display_knopp.removeClass "display_on"
        display_knopp.addClass "display_off"
        $(@_hivent_list).css({'max-height': ((window.innerHeight - 190 - 53 - 43)) + "px"})

      #console.log @theme
      @notifyAll "onUpdateTheme", @theme

    @_hgInstance.onAllModulesLoaded @, () =>
      @_hgInstance.search_box_area?.onSearchBoxChanged @, (search_props) =>
        if @props.active
          if search_props.active
            @props.height_hivent_list = 0
            @props.heigth_options = 0
            @props.boder = 0
          else
            @props.height_hivent_list = (window.innerHeight - 190 - 53 - 43)
            @props.heigth_options = 43 + 71
            @props.boder = 1


        $(@_hivent_list).css({'max-height': (@props.height_hivent_list) + "px"}) # max height of list with timelin height
        $(@_alliances_option).css({'max-height':(@props.heigth_options) + "px"})
        $(@_alliances_option).css({'border-bottom': (@props.border) + "px"})

      if @_hgInstance.timeline._config.topics.length > 0
        @_allTopics = @_hgInstance.timeline._config.topics
        @_addHiventList()
      else
        @_hgInstance.timeline.OnTopicsLoaded @, () =>
          @_allTopics = @_hgInstance.timeline._config.topics
          @_addHiventList()

      @_hgInstance.hiventInfoAtTag?.onHashChanged @, (key, value) =>
          if key is "categories"
            @_addHiventList()

    @_hgInstance.onTopAreaSlide @, (t) =>
      if @_hgInstance.isInMobileMode()
        @_container.style.left = "#{t*0.5}px"
      else
        @_container.style.left = "0px"


  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addHiventList: () ->

    # remove results if input list is empty
    if @_hivent_array.length > 0
      @_container.removeChild @_hivent_list
      @_container.removeChild @_hivent_headline

    # Hivents ==================================================================

    @_hivent_array = []
    if @_hgInstance.hiventController._hiventHandles?
      for hivent in @_hgInstance.hiventController._hiventHandles
        if @_hgInstance.categoryFilter._categoryFilter[0] == hivent._hivent.category
          @_hivent_array.push hivent._hivent

    #############################################################

    aktualleCath = ""
    if @_hgInstance.categoryFilter.getCurrentFilter()[0] != "bipolar"
      @theme = ""
      @notifyAll "onUpdateTheme", @theme

    for topic in @_allTopics
      if topic.id == @_hgInstance.categoryFilter.getCurrentFilter()[0]
        aktualleCath = topic.name

    headline = '<div>' + aktualleCath + '</div>'
    #<i class="toggle_on_off fa fa-toggle-off fa-4"></i>
    alliances = '<div class="alliances-content"><i class="shield_bipolar fa fa-shield"></i> Millitärbündnisse anzeigen <span class="toggle_on_off switch-off"></span>' +
      '<br><table class="legend_table display_off">
        <tr><td><div id="nato"></div></td><td> NATO</td></tr>
        <tr><td><div id="natooM"></div></td><td> NATO (nicht im Millitärbündnis)</td></tr>
        <tr><td><div id="warschP"></div></td><td> Warschauer Pakt</td></tr>
      </table>
      </div>'

    hivents = '<ul>'

    for hivent in @_hivent_array
      yearString = ''
      if hivent.startYear == hivent.endYear
        yearString = hivent.startYear
      else
        yearString = hivent.startYear + ' bis ' + hivent.endYear

      hivents += '<a  href="#event=' + hivent.id +
                 '"><li class= "hiventListItem inactive" id='+hivent.id+'><div class="wrap" ><div class="res_name"> ' +
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
      @props.heigth_options = 43 + 71
      @props.border = 1


    $(@_hivent_list).css({'max-height': (@props.height_hivent_list) + "px"}) # max height of list with timelin height
    $(@_alliances_option).css({'max-height':(@props.heigth_options) + "px"})
    $(@_alliances_option).css({'border-bottom': (@props.border) + "px"})

    if @_hgInstance.categoryFilter.getCurrentFilter()[0] != "bipolar"
      $(@_alliances_option).css({'max-height':0 + "px"})

    @notifyAll "onHiventListChanged", @props

    return @_hivent_list

  activateElement: (id) ->     
    $("#"+id).switchClass("inactive", "active")
  deactivateElement:(id) ->    
    $("#"+id).switchClass("active", "inactive")


    #=============================================================================
