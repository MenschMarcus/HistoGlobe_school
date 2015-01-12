window.HG ?= {}

class HG.NowMarker

    ##############################################################################
    #                            PUBLIC INTERFACE                                #
    ##############################################################################

    # ============================================================================
    constructor: (timeline, container, speedometer) ->
        @_timeline  = timeline
        @_container   = container
        @_speedometer = (speedometer is "true")

        @_uiElements =
            dateInput:      {}
            arrow:          {}
            arrow_2:        {}
            init: (tl, container) ->
                this.dateInput      = tl.addUIElement "now_date_input", null, this.nowMarkerIn, "input"
                this.arrow          = tl.addUIElement "now_marker_arrow", null, document.getElementById("histoglobe")
                this.arrow_2        = tl.addUIElement "now_marker_arrow_bottom", null, document.getElementById("histoglobe")
        @_uiElements.init(@_timeline, @_container)

        @_uiElements.dateInput.name         = "now_date"
        @_uiElements.dateInput.type         = "text"

        $(window).resize  =>
            @_updatePositions()

        @_updatePositions()

        # =========================================================================
        if @_speedometer
            @_clicked = false
            @_hiddenSpeed = 0
            @_container.onmousedown = (e) =>
                if((@_distanceToMiddlepoint(e) - 75) >= 0)
                    @_clicked = true
                    @_disableTextSelection e
            @_container.onmousemove = (e) =>
                if @_clicked
                    unless @_timeline.getPlayStatus()
                        @_playButton.className = "fa fa-play"
                    @_hiddenSpeed = e.pageX - @_middlePointX
                    $(@_uiElements.pointer).rotate(@_angleOnCircle(e))
            @_container.onmouseup = (e) =>
                if @_clicked
                    @_timeline.setSpeed (@_radius + e.pageX - @_middlePointX)/@_radius
                    $(@_uiElements.pointer).rotate(@_angleOnCircle(e))
                    @_enableTextSelection()
                    @_clicked = false
        $(@_uiElements.dateInput).keyup (e) =>
            if e.keyCode == 13
                d = @_timeline.stringToDate @_uiElements.dateInput.value

                @_timeline.moveToDate(d, 1)

    #   --------------------------------------------------------------------------
    nowDateChanged: ->
        date = @_timeline.getNowDate()
        day = date.getDate() + ""
        day = "0" + day if day.length == 1
        month = (date.getMonth() + 1) + ""
        month = "0" + month if month.length == 1
        year = date.getFullYear() + ""
        @_uiElements.dateInput.value = day + "." + month + "." + year
        # console.log "Now Date Changed "+ day + "." + month + "." + year             ## RAUS !!!

    #   --------------------------------------------------------------------------
    addButton : (buttonDiv, callback) =>
      @_uiElements.buttonArea.appendChild buttonDiv
      buttonDiv.onclick = callback

    #   --------------------------------------------------------------------------
    clearButtons : () ->
      $(@_uiElements.buttonArea).empty()

    #   --------------------------------------------------------------------------
    animationSwitch: =>
        if @_timeline.getPlayStatus()
            @_timeline.stopTimeline()
            @_uiElements.playButton.className = "fa fa-play now_marker_button"
        else
            @_timeline.playTimeline()
            @_uiElements.playButton.className = "fa fa-pause now_marker_button"

    #   --------------------------------------------------------------------------
    jumpToFront: =>
      if @_timeline.getPlayStatus()
        @_timeline.stopTimeline()
      @_timeline.moveToDate @_timeline.yearToDate(@_timeline.getMinYear()), 0.5

    #   --------------------------------------------------------------------------
    jumpToBack: =>
      if @_timeline.getPlayStatus()
        @_timeline.stopTimeline()
      @_timeline.moveToDate @_timeline.yearToDate(@_timeline.getMaxYear()), 0.5


    ##############################################################################
    #                            PRIVATE INTERFACE                               #
    ##############################################################################

    #   --------------------------------------------------------------------------
    _distanceToMiddlepoint : (e) ->
        xs = 0
        ys = 0

        xs = e.pageX - @_middlePointX
        xs = xs * xs

        ys = e.pageY - @_middlePointY
        ys = ys * ys

        return Math.sqrt xs + ys

    #   --------------------------------------------------------------------------
    _angleOnCircle : (e) ->
        mY = window.innerHeight - @_middlePointY

        fac = 180 / Math.PI

        vectorAX = 0
        vectorAY = 100

        vectorBX = e.pageX - @_middlePointX
        vectorBY = window.innerHeight - e.pageY - mY

        res = vectorAX * vectorBX + vectorAY * vectorBY

        res2a = Math.sqrt(Math.pow(vectorAX, 2) + Math.pow(vectorAY, 2))
        res2b = Math.sqrt(Math.pow(vectorBX, 2) + Math.pow(vectorBY, 2))
        res2 = res / (res2a * res2b)

        angle = Math.acos(res2) * fac
        if e.pageX < @_middlePointX
            angle *= -1
        angle

    #   --------------------------------------------------------------------------
    _updatePositions: ->
        # Position of arrow pointing on timeline
        @_uiElements.arrow.style.left   = window.innerWidth / 2 - 10 + "px"
        @_uiElements.arrow_2.style.left   = window.innerWidth / 2 - 10 + "px"
    #   --------------------------------------------------------------------------
    _disableTextSelection : (e) ->  return false
    _enableTextSelection : () ->    return true
