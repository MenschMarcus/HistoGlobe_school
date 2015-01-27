window.HG ?= {}

class HG.HiventList

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  #   --------------------------------------------------------------------------
  hgInit: (hgInstance) ->

    @_hgInstance = hgInstance
    @_hgInstance.hivent_list_module = @

    @_container = document.createElement "div"
    @_container.className = "hivent-list-module"
    @_hgInstance._top_area.appendChild @_container

    #@_timeline = hgInstance.timeline
    #epoch = hgInstance.timeline.epoch.div

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
    hivent_list = document.createElement "div"
    hivent_list.className = "hivent-list"

    # Hivents ==================================================================
    
    hivent_array = []
    if @_hgInstance.hiventController._hiventHandles?
      for hivent in @_hgInstance.hiventController._hiventHandles
        console.log @_hgInstance.categoryFilter._categoryFilter[0]
        if @_hgInstance.categoryFilter._categoryFilter[0] == hivent._hivent.category
          hivent_array.push hivent._hivent

    hivents = ''
    for hivent in hivent_array 
      hivents = hivents + '<a href="#event=' + hivent.id + '">' + hivent.name + '</a></br>'

    hivent_list.innerHTML = hivents

    @_container.appendChild hivent_list

    # remove results if input list is empty
    if hivent_array.lenth < 1
      @_container.removeChild hivent_list

    return hivent_list

    #=============================================================================