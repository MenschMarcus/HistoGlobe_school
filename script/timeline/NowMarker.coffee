window.HG ?= {}

class HG.NowMarker

    ##############################################################################
    #                            PUBLIC INTERFACE                                #
    ##############################################################################

    constructor: (tlDiv, mainDiv, timeline) ->
        @_timeline  = timeline
        @_mainDiv   = mainDiv
        @_tlDiv     = tlDiv

        # Elements of Now Marker Box
        @_dateInputField    = document.getElementById("now_date_input")
        @_playButton        = document.getElementById("now_marker_play")
        @_pointer           = document.getElementById("now_marker_pointer")
        @_arrow             = document.getElementById("now_marker_sign")

        # Set position of now marker
        @_setNowMarkerPosition()

        # Set position/rotation of pointer
        $(@_pointer).rotate(0)

        # Catching mouse events
        @_clicked = false
        @_mainDiv.onmousedown = (e) =>
            if((@_distanceToMiddlepoint(e) - 75) >= 0)
                @_clicked = true
                @_disableTextSelection e


        document.body.onmousemove = (e) =>
            if @_clicked
                $(@_pointer).rotate(@_angleOnCircle(e))

        document.body.onmouseup = (e) =>
            if @_clicked
                @_clicked = false
                timeline.setSpeed(e.pageX - @_middlePointX)
                $(@_pointer).rotate(@_angleOnCircle(e))
                @_enableTextSelection()

        @_playButton.onclick = (e) =>
            @animationSwitch()

        $(document.body).keyup (e) =>
            if e.keyCode == 32
                 @animationSwitch()

        $(window).resize  =>
            @_setNowMarkerPosition()

        # Catch enter key on the date input field
        $(@_dateInputField).keyup (e) ->
            if e.keyCode == 13
                if not isNaN @value
                    timeline._scrollToDate timeline._yearToDate @value

    _distanceToMiddlepoint : (e) ->
        xs = 0
        ys = 0

        xs = e.pageX - @_middlePointX
        xs = xs * xs

        ys = e.pageY - @_middlePointY
        ys = ys * ys

        return Math.sqrt xs + ys

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

    _setNowMarkerPosition: ->
        @_mainDiv.style.left    = window.innerWidth / 2 - @_mainDiv.offsetWidth / 2 + "px"
        @_mainDiv.style.bottom  = @_tlDiv.offsetHeight + "px"
        @_mainDiv.style.visibility = "visible"

        # middle point of circle
        @_middlePointX      = window.innerWidth / 2
        @_middlePointY      = window.innerHeight - @_tlDiv.offsetHeight
        @_radius            = @_mainDiv.offsetHeight

        # Position of arrow pointing on timeline
        @_arrow.style.left   = window.innerWidth / 2 - 10 + "px"

    setNowDate: (date) ->
        @_dateInputField.value = date.getFullYear()

    animationSwitch: ->
        if @_timeline.getPlayStatus()
            @_timeline.stopTimeline()
            @_playButton.innerHTML = "<img src='img/timeline/playIcon.png'>"
        else
            @_timeline.playTimeline()
            @_playButton.innerHTML = "<img src='img/timeline/pauseIcon.png'>"

    _disableTextSelection : (e) ->  return false
    _enableTextSelection : () ->    return true


