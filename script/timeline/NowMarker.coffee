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
            pointer:        {}
            nowMarkerIn:    {}
            buttonArea:     {}
            playButton:     {}
            dateInput:      {}
            arrow:          {}
            init: (tl, container) ->
                this.pointer        = tl.addUIElement "now_marker_pointer", null, container
                this.nowMarkerIn    = tl.addUIElement "now_marker_in", null, container
                this.buttonArea     = tl.addUIElement "now_marker_button_area", null, this.nowMarkerIn
                this.playButton     = tl.addUIElement "now_marker_play", "fa fa-step-forward", null, "i"
                this.dateInput      = tl.addUIElement "now_date_input", null, this.nowMarkerIn, "input"
                this.arrow          = tl.addUIElement "now_marker_arrow", null, document.getElementById("histoglobe")
        @_uiElements.init(@_timeline, @_container)

        @addButton @_uiElements.playButton, @animationSwitch

        @_uiElements.dateInput.name         = "now_date"
        @_uiElements.dateInput.type         = "text"
        @_uiElements.dateInput.maxlength    = 10
        @_uiElements.dateInput.size         = 10

        $(@_uiElements.pointer).rotate(0)
        $(@_uiElements.pointer).css
            "display" : "none" if !@_speedometer

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
                # res = (@_uiElements.dateInput.value + "").split(".")
                # d = new Date()
                # if res.length > 0
                #     d.setFullYear(res[res.length - 1])
                # else
                #     alert "Couldn't read the given date. Please try another."
                # d.setMonth(res[res.length - 2] - 1) if res.lengt > 1
                # d.setDate(res[res.length - 3]) if res.length > 2
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
            @_playButton.className = "fa fa-play"
        else
            @_timeline.playTimeline()
            @_playButton.className = "fa fa-pause"

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
        @_container.style.left    = window.innerWidth / 2 - @_container.offsetWidth / 2 + "px"
        @_container.style.bottom  = @_timeline.getLayout().tl.offsetHeight + "px"
        @_container.style.visibility = "visible"

        # middle point of circle
        @_middlePointX      = window.innerWidth / 2
        @_middlePointY      = window.innerHeight - @_timeline.getLayout().tl.offsetHeight
        @_radius            = @_container.offsetHeight

        # Position of arrow pointing on timeline
        @_uiElements.arrow.style.left   = window.innerWidth / 2 - 10 + "px"

    #   --------------------------------------------------------------------------
    _disableTextSelection : (e) ->  return false
    _enableTextSelection : () ->    return true
