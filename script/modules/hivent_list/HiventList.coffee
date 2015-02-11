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
    @_hivent_array = []
    @_hivent_list = document.createElement "div"
    @_hivent_list.className = "hivent-list"

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

    # remove results if input list is empty
    if @_hivent_array.length > 0
      @_container.removeChild @_hivent_list

    # Hivents ==================================================================

    @_hivent_array = []
    if @_hgInstance.hiventController._hiventHandles?
      for hivent in @_hgInstance.hiventController._hiventHandles
        if @_hgInstance.categoryFilter._categoryFilter[0] == hivent._hivent.category
          @_hivent_array.push hivent._hivent

    hivents = '<ul>'
    for hivent in @_hivent_array
      hivents += '<a href="#event=' + hivent.id + '"><li><i class="fa fa-map-marker"></i> ' + hivent.name + '</li></a>'
    hivents += '</ul>'

    @_hivent_list.innerHTML = hivents
    @_hivent_list.style.display = "none"
    @_container.appendChild @_hivent_list
    $(@_hivent_list).css({'max-height': (window.innerHeight - 150) + "px"}) # max height of list with timelin height
    $(@_hivent_list).fadeIn(1000)

    return @_hivent_list

    #=============================================================================