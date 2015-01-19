window.HG ?= {}

class HG.HiventList

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================

  hgInit: (hgInstance) ->

    @_hgInstance = hgInstance
    @_hgInstance.hivent_list = @

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
    hivent_list.innerHTML = '<span>Hivent 1</span><br>
    <span>Hivent 2</span><br>
    <span>Hivent 3</span><br>
    <span>Hivent 4</span><br>
    <span>Hivent 5</span><br>
    <span>Hivent 6</span><br>
    <span>Hivent 7</span><br>
    <span>Hivent 8</span><br>
    <span>Hivent 9</span><br>
    <span>Hivent 10</span>'

    # Hivents ==================================================================
    #hivent_array = []

    #if @_hgInstance.hiventController._hiventHandles
      #for hivent in @_hgInstance.hiventController._hiventHandles
        #hivent_array.push hivent._hivent
        #continue

    #hivents = ''
    #for result in hivent_array 
    	#hivents = hivents + '<a href="#event=' + result.id + '">' + result.name + ' (' + result.startYear + ')</a>'

    #hivent_list.innerHTML = hivents

    @_container.appendChild hivent_list

    return hivent_list

    #=============================================================================