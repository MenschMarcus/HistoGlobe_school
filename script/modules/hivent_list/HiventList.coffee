window.HG ?= {}

class HG.HiventList

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================

  hgInit: (hgInstance) ->

    @_hgInstance = hgInstance
    @_hgInstance.hivent_list_module = @

    @_container = document.createElement "div"
    @_container.className = "hivent-list-module"
    @_hgInstance._top_area.appendChild @_container

    @_hgInstance.onTopAreaSlide @, (t) =>
      if @_hgInstance.isInMobileMode()
        @_container.style.left = "#{t*0.5}px"
      else
        @_container.style.left = "0px"

  # ============================================================================

  addHiventList: (config) ->
    @_addHiventList config

  ##############################################################################
  #                            PRIVATE INTERFACE                               #
  ##############################################################################

  # ============================================================================
  _addHiventList: () ->

    hivent_list = document.createElement "div"
    hivent_list.className = "hivent-list"

    # Hivents ==================================================================
    hivent_array = []
    $(hivent_list).click () =>
      #console.log @_hgInstance.hiventController._hiventHandles
      if @_hgInstance.hiventController._hiventHandles
        for hivent in @_hgInstance.hiventController._hiventHandles
          hivent_array.push hivent._hivent
          console.log "hans"
          #continue

      hivents = ''
      for hivent in hivent_array 
        hivents = hivents + '<a href="#event=' + hivent.id + '">' + hivent.name + '</a></br>'

      hivent_list.innerHTML = hivents

    @_container.appendChild hivent_list

    return hivent_list

    #=============================================================================