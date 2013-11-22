window.HG ?= {}

class HG.NowMarker

    ##############################################################################
    #                            PUBLIC INTERFACE                                #
    ##############################################################################

    constructor: (tlDiv, mainDiv, timeline) ->
        @_timeline  = timeline
        @_mainDiv   = mainDiv
        @_tlDiv     = tlDiv

        # set position of now marker
        @_mainDiv.style.left    = window.innerWidth / 2 - @_mainDiv.offsetWidth / 2 + "px"
        @_mainDiv.style.bottom  = @_tlDiv.offsetHeight + "px"
        @_mainDiv.style.visibility = "visible";

        # middle point of circle
        @_middlePointX      = window.innerWidth / 2
        @_middlePointY      = window.innerHeight - @_tlDiv.offsetHeight
        @_radius            = @_mainDiv.offsetHeight
        

        @_dateInputField    = document.getElementById("now_date_input")
        @_playButton        = document.getElementById("now_marker_play")

        # output to test vars
        # console.log "NowMarker: Parameter:"
        # console.log "   div width: " + @_mainDiv.offsetWidth
        # console.log "   div height: " + @_mainDiv.offsetHeight
        # console.log "   div bottom: " + $(@_mainDiv).css "bottom"
        # console.log "   div left: " + $(@_mainDiv).css "left"
        @_clicked = false
        @_mainDiv.onmousedown = (e) =>
            if((@_distanceToMiddlepoint(e) - 85) >= 0)
                console.log "scale was clicked"
                @_clicked = true

        document.body.onmousemove = (e) =>

        document.body.onmouseup = (e) =>
            if @_clicked
                @_clicked = false
                console.log "timeline speed " + (e.pageX - @_middlePointX)
                timeline.setSpeed(e.pageX - @_middlePointX)

        @_playButton.onclick = (e) =>
            console.log "playbutton was clicked"
            @animationSwitch()

    # ============================================================================
    _distanceToMiddlepoint : (e) ->
        xs = 0
        ys = 0

        xs = e.pageX - @_middlePointX
        xs = xs * xs

        ys = e.pageY - @_middlePointY
        ys = ys * ys

        return Math.sqrt xs + ys

    setNowDate: (date) ->
        @_dateInputField.value = date.getFullYear()

    animationSwitch: ->        
        if @_timeline.getPlayStatus()
            @_timeline.stopTimeline()
            @_playButton.innerHTML = "PLAY"
        else 
            @_timeline.playTimeline()
            @_playButton.innerHTML = "STOP"
