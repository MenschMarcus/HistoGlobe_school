window.HG ?= {}

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## ## ## ##
## ##             STATIC PUBLIC

MAX_ZOOM_LEVEL = 7          # most detailed view of timeline in DAYS
MIN_INTERVAL_INDEX = 0      # 0 = 1 Year | 1 = 2 Year | 2 = 5 Years | 3 = 10 Years | ...
INTERVAL_SCALE = 0.05       # higher value makes greater intervals between datemarkers
FADE_ANIMATION_TIME = 200   # fade in time for datemarkers and so

MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]

DATE_LOCALE = 'de-DE'
DATE_OPTIONS = {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit'
}




class HG.Timeline

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
  ## ## ## ##
  ## ##           PUBLIC

  constructor: (config) ->

    @_activeTopic = null
    @_dragged = false
    @topicsloaded = false

    HG.mixin @, HG.CallbackContainer
    HG.CallbackContainer.call @

    @addCallback "onNowChanged"
    @addCallback "onIntervalChanged"
    @addCallback "onZoom"
    @addCallback "OnTopicsLoaded"

    defaultConfig =
      timelineZoom: 1
      minYear: 1850
      maxYear: 2000
      nowYear: 1925
      topics: []
      dsvPaths: []
      rootDirs: []
      ignoredLines : []
      indexMappings: []
      delimiter: ","

    @_config = $.extend {}, defaultConfig, config

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  hgInit: (hgInstance) ->

    @_config.minYear = hgInstance.getMinMaxYear()[0]
    @_config.maxYear = hgInstance.getMinMaxYear()[1]
    @_config.nowYear = hgInstance.getStartYear()

    @_HGContainer = hgInstance.getContainer()

    hgInstance.onAllModulesLoaded @, () =>
      @_hiventController = hgInstance.hiventController
      @notifyAll "onNowChanged", @_cropDateToMinMax @_now.date
      @notifyAll "onIntervalChanged", @_getTimeFilter()

      if hgInstance.zoom_buttons_timeline
        hgInstance.zoom_buttons_timeline.onZoomIn @, () =>
          @_zoom(1)
        hgInstance.zoom_buttons_timeline.onZoomOut @, () =>
          @_zoom(-1)

      # if category/topic was changed outside the timeline
      # notify action here
      hgInstance.categoryFilter?.onFilterChanged @,(categoryFilter) =>
        for topic in @_config.topics
          if categoryFilter[0] is topic.id
            @_switchTopic(topic, false)
            break

      hgInstance.timeline?.onNowChanged @, (date) =>
        @_now.dateField.innerHTML = date.toLocaleDateString DATE_LOCALE, DATE_OPTIONS

    @_parentDiv = @addUIElement "timeline-area", "timeline-area", @_HGContainer

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    # # prepare topic dates
    # for topic in @_config.topics
    #   topic.startDate = @stringToDate(topic.startDate)
    #   topic.endDate = @stringToDate(topic.endDate)
    #   if topic.subtopics?
    #     for subtopic in topic.subtopics
    #       subtopic.startDate = @stringToDate(subtopic.startDate)
    #       subtopic.endDate = @stringToDate(subtopic.endDate)

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    @_uiElements =
      tl:           @addUIElement "tl", "swiper-container", @_parentDiv
      tl_wrapper:   @addUIElement "tl_wrapper", "swiper-wrapper", tl
      tl_slide:     @addUIElement "tl_slide", "swiper-slide", tl_wrapper
      dateMarkers:  []

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    @_now =
      date: @yearToDate(@_config.nowYear)
      marker: @addUIElement "now_marker_arrow_bottom", null, @_HGContainer
      dateField: @addUIElement "now_date_field", null, @_HGContainer

    @_now.dateField.innerHTML = @_now.date.toLocaleDateString DATE_LOCALE, DATE_OPTIONS
    $(@_now.dateField).fadeIn()

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    # transition of timeline container with swiper.js
    @_moveDelay = 0
    @_timeline_swiper ?= new Swiper '#tl',
      mode:'horizontal'
      freeMode: true
      momentumRatio: 0.5
      scrollContainer: true
      onTouchStart: =>
        @_dragged = false
        @_animationTargetDate = null
        if @_play
          @_animationSwitch()
      onTouchMove: =>
        @_dragged = true
        fireCallbacks = false
        if ++@_moveDelay == 10
          @_moveDelay = 0
          fireCallbacks = true
        @_updateNowDate(fireCallbacks)
        @_updateDateMarkers(false)
        @_updateTopics()
    @_uiElements.tl_wrapper.addEventListener "webkitTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers(false)
      @_updateTopics()
      @_dragged = false
    , false
    @_uiElements.tl_wrapper.addEventListener "transitionend", (e) =>
      @_updateNowDate()
      @_updateDateMarkers(false)
      @_updateTopics()
      @_dragged = false
    , false
    @_uiElements.tl_wrapper.addEventListener "oTransitionEnd", (e) =>
      @_updateNowDate()
      @_updateDateMarkers(false)
      @_updateTopics()
      @_dragged = false
    , false

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    # animation for timeline
    # INFO: to play timeline call @playTimeline()
    @_play = false
    @_speed = 1
    @_stopDate = @yearToDate(@_config.maxYear)
    @_nextHiventhandle = null
    setInterval @_animTimeline, 30

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    #   ZOOM
    @_uiElements.tl.addEventListener "mousewheel", (e) =>
      e.preventDefault()
      @_zoom(e.wheelDelta, e)
    @_uiElements.tl.addEventListener "DOMMouseScroll", (e) =>
      e.preventDefault()
      @_zoom(-e.detail, e)

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    $(window).resize  =>
      @_updateLayout()
      @_updateDateMarkers()
      @_updateTopics()
      @_updateNowDate()

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    hgInstance.timeline = @

    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

    # Start the timeline here !!!
    @_loadTopicsFromDSV( =>
      @_updateLayout()
      @_updateDateMarkers()
      @_updateTopics()
      @_updateNowDate()
      categoryFilter = hgInstance.categoryFilter.getCurrentFilter()
      for topic in @_config.topics
        if categoryFilter[0] is topic.id
          @_switchTopic(topic, false)
          break
      @notifyAll "OnTopicsLoaded"
      @topicsloaded = true
    )

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  _loadTopicsFromDSV: (callback = undefined) ->

    if @_config.dsvPaths?
      parse_config =
        delimiter: @_config.delimiter
        header: false

      pathIndex = 0
      for dsvPath in @_config.dsvPaths
        $.get dsvPath,
          (data) =>
            parse_result = $.parse data, parse_config
            for result, i in parse_result.results
              unless i+1 in @_config.ignoredLines

                id = result[@_config.indexMappings[pathIndex].id]
                start = @stringToDate result[@_config.indexMappings[pathIndex].start]
                end = @stringToDate result[@_config.indexMappings[pathIndex].end]
                topic = result[@_config.indexMappings[pathIndex].topic]
                subtopic_of = result[@_config.indexMappings[pathIndex].subtopic_of]
                token = result[@_config.indexMappings[pathIndex].token]
                row = result[@_config.indexMappings[pathIndex].row]

                if subtopic_of is "" # head topic
                  tmp_topic =
                    startDate: start
                    endDate: end
                    name: topic
                    id: id
                    token: token
                    row: parseInt(row)
                    subtopics: []
                  @_config.topics.push tmp_topic

                else # is subtopic
                  for headtopic in @_config.topics
                    if headtopic.id == subtopic_of
                      tmp_subtopic =
                        startDate: start
                        endDate: end
                        name: topic
                        id: id
                        token: token
                      headtopic.subtopics.push tmp_subtopic

            if pathIndex == @_config.dsvPaths.length - 1
              callback() if callback?

            else pathIndex++

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  # getter
  getTopics: =>
    @_config.topics
  getRowFromTopicId: (id) =>
    for tmp_topic in @_config.topics
      if tmp_topic.id is id
        return tmp_topic.row
        break
      else
        if tmp_topic.subtopics?
          for tmp_subtopic in tmp_topic.subtopics
            if id is tmp_subtopic.id
              return tmp_topic.row + 0.5
              break
    return -1
  getMinYear: =>
    @_config.minYear
  getMaxYear: =>
    @_config.maxYear
  getTimeInterval: ->
    intervalIndex = MIN_INTERVAL_INDEX
    while @timeInterval(intervalIndex) <= window.innerWidth * @millisPerPixel() * INTERVAL_SCALE
      intervalIndex++
    @timeInterval(intervalIndex)
  getLayout: ->
    @_uiElements
  getNowDate: ->
    @_now.date
  getNowMarker: ->
    @_now.marker
  getParentDiv: ->
    @_parentDiv
  getCanvas: ->
    @_uiElements.tl_slide
  getPlayStatus: ->
    @_play

  _getTimeFilter: ->
    timefilter = []
    timefilter.end = @maxVisibleDate()
    timefilter.now = @_now.date
    timefilter.start = @minVisibleDate()
    timefilter

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  millisPerPixel: ->
    mpp = (@yearsToMillis(@_config.maxYear - @_config.minYear) / window.innerWidth) / @_config.timelineZoom
  minVisibleDate: ->
    d = new Date(@_now.date.getTime() - (@millisPerPixel() * window.innerWidth / 2))
  maxVisibleDate: ->
    d = new Date(@_now.date.getTime() + (@millisPerPixel() * window.innerWidth / 2))
  timelineLength: ->
    @yearsToMillis(@_config.maxYear - @_config.minYear) / @millisPerPixel()
  timeInterval: (i) ->
    x = Math.floor(i/3)
    if i % 3 == 0
      return @yearsToMillis(Math.pow(10, x))
    if i % 3 == 1
      return @yearsToMillis(2 * Math.pow(10, x))
    if i % 3 == 2
      return @yearsToMillis(5 * Math.pow(10, x))
  dateToPosition: (date) ->
    dateDiff = date.getTime() - @yearToDate(@_config.minYear).getTime()
    pos = (dateDiff / @millisPerPixel()) + window.innerWidth/2

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  moveToDate: (date, delay=0, successCallback=undefined) ->
    if @yearToDate(@_config.minYear).getTime() > date.getTime()
      @moveToDate @yearToDate(@_config.minYear), delay, successCallback
    else if @yearToDate(@_config.maxYear).getTime() < date.getTime()
      @moveToDate @yearToDate(@_config.maxYear), delay, successCallback
    else
      dateDiff = @yearToDate(@_config.minYear).getTime() - date.getTime()
      @_uiElements.tl_wrapper.style.transition =  delay + "s"
      @_uiElements.tl_wrapper.style.transform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.webkitTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.MozTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.MsTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"
      @_uiElements.tl_wrapper.style.oTransform = "translate3d(" + dateDiff / @millisPerPixel() + "px ,0px, 0px)"

      @_animationTargetDate = date
      @_now.date = @_cropDateToMinMax date

      @notifyAll "onNowChanged", @_now.date
      @notifyAll "onIntervalChanged", @_getTimeFilter()

      setTimeout(successCallback, delay * 1000) if successCallback?

  # animation control
  stopTimeline: ->
    @_play = false
  playTimeline: ->
    @_play = true
  setSpeed: (speed) ->
    @_speed = speed

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
  ## ## ## ##
  ## ##           (STATIC) PUBLIC

  # TODO: make static functions

  addUIElement: (id, className, parentDiv, type="div") ->
    container = document.createElement(type)
    container.id = id
    container.className = className if className?
    parentDiv.appendChild container if parentDiv?
    container

  yearToDate: (year) ->
    date = new Date(0)
    date.setFullYear year
    date.setMonth 0
    date.setDate 1
    date.setHours 0
    date.setMinutes 0
    date.setSeconds 0
    date

  yearsToMillis: (year) ->
    millis = year * 365.25 * 24 * 60 * 60 * 1000

  monthsToMillis: (months) ->
    millis = months * 30 * 24 * 60 * 60 * 1000

  yearsToMonths: (years) ->
    months = Math.round(years * 12)

  millisToYears: (millis) ->
    year = millis / 1000 / 60 / 60 / 24 / 365.25

  millisToMonths: (millis) ->
    months = Math.round(millis / 1000 / 60 / 60 / 24 / 365.25 / 12)

  daysToMillis: (days) ->
    millis = days * 24 * 60 * 60 * 1000

  millisToDays: (millis) ->
    days = millis / 1000 / 60 / 60 / 24

  stringToDate: (string) ->
    res = (string + "").split(".")
    i = res.length
    d = new Date(1900, 0, 1)
    if i > 0
        d.setFullYear(res[i - 1])
    else
        alert "Error: were not able to convert string to date."
    if i > 1
        d.setMonth(res[i - 2] - 1)
    if i > 2
        d.setDate(res[i - 3])
    d

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
  ## ## ## ##
  ## ##             PRIVATE

  # move and zoom
  _zoom: (delta, e=null, layout=true) =>
    zoomed = false
    if delta > 0
      if @millisToDays(@maxVisibleDate().getTime()) - @millisToDays(@minVisibleDate().getTime()) > MAX_ZOOM_LEVEL
        @_config.timelineZoom *= 1.1
        zoomed = true
    else
      if @_config.timelineZoom > 1
        @_config.timelineZoom /= 1.1
        zoomed = true

    if zoomed
      if layout
        @_updateLayout()
      @_updateDateMarkers()
      @_updateTopics()
      @notifyAll "onZoom"
    zoomed

  _animTimeline: =>
    if @_play
      if @_now.date.getFullYear() <= @_config.maxYear
        toDate = new Date(@_now.date.getTime() + @_speed*@_speed * 5000 * 60 * 60 * 24 * 7)
        @moveToDate(toDate,0)
        @_updateNowDate()
        @_updateTopics()
        @_updateDateMarkers(zoomed=false)
      else
        @_animationSwitch()

  _animationSwitch: =>
    if @getPlayStatus()
      @stopTimeline()
    else
      @playTimeline()

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  #update
  _updateLayout: ->
    @_uiElements.tl.style.width       = window.innerWidth + "px"
    @_uiElements.tl_slide.style.width = (@timelineLength() + window.innerWidth) + "px"
    @_now.marker.style.left           = (window.innerWidth / 2) + "px"
    @_now.dateField.style.left        = (window.innerWidth / 2) + "px"
    @moveToDate(@_now.date, 0)
    @_timeline_swiper.reInit()

  _updateNowDate: (fireCallbacks = true) ->
    if @_animationTargetDate?
      @_now.date = @_cropDateToMinMax @_animationTargetDate
      @_animationTargetDate = null
    else
      now = new Date(@yearToDate(@_config.minYear).getTime() + (-1) * @_timeline_swiper.getWrapperTranslate("x") * @millisPerPixel())
      @_now.date = @_cropDateToMinMax now

    if fireCallbacks
      @notifyAll "onNowChanged", @_now.date
      @notifyAll "onIntervalChanged", @_getTimeFilter()

  _cropDateToMinMax: (date) ->
    if date.getFullYear() <= @_config.minYear
      date = @yearToDate @_config.minYear+1
    if date.getFullYear() > @_config.maxYear
      date = @yearToDate @_config.maxYear
    date

  _updateTopics:()->
    for topic in @_config.topics
      if !topic.div?
        topic.div = document.createElement("div")
        topic.div.id = "topic" + topic.id
        topic.div.className = "tl_topic tl_topic_row" + topic.row
        topic.div.innerHTML = '<div class="tl_subtopics"></div>' + '<div id="topic_inner_' + topic.id + '">' + topic.name + '</div>'
        topic.div.style.left = @dateToPosition(topic.startDate) + "px"
        topic.div.style.width = (@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate)) + "px"
        topic.div.style.display = "none"
        @getCanvas().appendChild topic.div

        # add subtopics
        if topic.subtopics?
          for subtopic in topic.subtopics
            subtopic.div = document.createElement("div")
            subtopic.div.id = "subtopic" + subtopic.id
            subtopic.div.className = "tl_subtopic"
            subtopic.div.innerHTML = subtopic.name
            subtopic.div.style.left = ((subtopic.startDate.getTime() - topic.startDate.getTime()) / @millisPerPixel()) + "px"
            subtopic.div.style.width = (@dateToPosition(subtopic.endDate) - @dateToPosition(subtopic.startDate)) + "px"
            $("#topic" + topic.id + " > .tl_subtopics" ).append subtopic.div

        $(topic.div).on "click", value: topic, (event) => @_switchTopic(event.data.value) if !@_dragged
        $(topic.div).fadeIn(200)

        inner_el = document.getElementById("topic_inner_" + topic.id)
        if inner_el.offsetWidth > (@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate) - 25) and topic.token != ""
          inner_el.innerHTML = topic.token
        else
          inner_el.innerHTML = topic.name
        inner_el.style.maxWidth = (@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate) - 25) + "px"
        margin = ((@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate)) / 2) - inner_el.offsetWidth / 2
        if (@dateToPosition(topic.startDate) + margin + inner_el.offsetWidth) > @dateToPosition @maxVisibleDate()
          margin = @dateToPosition(@maxVisibleDate()) - @dateToPosition(topic.startDate) - inner_el.offsetWidth - 10
          margin = 0 if margin < 0
        else if (@dateToPosition(topic.startDate) + margin) < @dateToPosition @minVisibleDate()
          margin = @dateToPosition(@minVisibleDate()) - @dateToPosition(topic.startDate) + 10
        inner_el.style.marginLeft = margin + "px"
      else
        topic.div.style.left = @dateToPosition(topic.startDate) + "px"
        topic.div.style.width = (@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate)) + "px"

        inner_el = document.getElementById("topic_inner_" + topic.id)
        if inner_el.offsetWidth > (@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate) - 25) and topic.token != ""
          inner_el.innerHTML = topic.token
        else
          inner_el.innerHTML = topic.name
        inner_el.style.maxWidth = (@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate) - 25) + "px"
        margin = ((@dateToPosition(topic.endDate) - @dateToPosition(topic.startDate)) / 2) - inner_el.offsetWidth / 2
        if (@dateToPosition(topic.startDate) + margin + inner_el.offsetWidth) > @dateToPosition @maxVisibleDate()
          margin = @dateToPosition(@maxVisibleDate()) - @dateToPosition(topic.startDate) - inner_el.offsetWidth - 10
          margin = 0 if margin < 0
        else if (@dateToPosition(topic.startDate) + margin) < @dateToPosition @minVisibleDate()
          margin = @dateToPosition(@minVisibleDate()) - @dateToPosition(topic.startDate) + 10
        inner_el.style.marginLeft = margin + "px"
        if topic.subtopics?
          for subtopic in topic.subtopics
            subtopic.div.style.left = ((subtopic.startDate.getTime() - topic.startDate.getTime()) / @millisPerPixel()) + "px"
            subtopic.div.style.width = (@dateToPosition(subtopic.endDate) - @dateToPosition(subtopic.startDate)) + "px"

  _updateDateMarkers: (zoomed=true) ->

    interval = @getTimeInterval()

    # scale datemarker
    $(".tl_datemarker").css({"max-width": Math.round(interval / @millisPerPixel()) + "px"})

    # for every year on timeline check if datemarker is needed
    # or can be removed.
    for i in [0..@_config.maxYear - @_config.minYear]
      year = @_config.minYear + i

      # fits year to interval?
      if year % @millisToYears(interval) == 0 and
      year >= @minVisibleDate().getFullYear() and
      year <= @maxVisibleDate().getFullYear()

        # show datemarker
        if !@_uiElements.dateMarkers[i]?

          # create new
          @_uiElements.dateMarkers[i] =
            div: document.createElement("div")
            year: year
            months: []
          @_uiElements.dateMarkers[i].div.id = "tl_year_" + year
          @_uiElements.dateMarkers[i].div.className = "tl_datemarker"
          @_uiElements.dateMarkers[i].div.innerHTML = year + '<div class="tl_months"></div>'
          @_uiElements.dateMarkers[i].div.style.left = @dateToPosition(@yearToDate(year)) + "px"
          #@_uiElements.dateMarkers[i].div.style.display = "none"
          @getCanvas().appendChild @_uiElements.dateMarkers[i].div

          # show and create months
          if @millisToYears(interval) == 1
            for month_name, key in MONTH_NAMES
              month =
                div: document.createElement("div")
                startDate: new Date()
                endDate: new Date()
                name: month_name
              month.startDate.setFullYear(year, key, 1)
              month.endDate.setFullYear(year, key + 1, 0)
              month.div.className = "tl_month"
              month.div.innerHTML = month.name
              month.div.style.left = ((month.startDate.getTime() - @yearToDate(year).getTime()) / @millisPerPixel()) + "px"
              month.div.style.width = (@dateToPosition(month.endDate) - @dateToPosition(month.startDate)) + "px"
              $("#tl_year_" + year + " > .tl_months" ).append month.div
              @_uiElements.dateMarkers[i].months[key] = month

          # hide and delete months
          else
            for months in @_uiElements.dateMarkers[i].months
              $(month.div).fadeOut(FADE_ANIMATION_TIME, `function() { $(this).remove(); }`)
            @_uiElements.dateMarkers[i].months.length = 0
          $(@_uiElements.dateMarkers[i].div).fadeIn(FADE_ANIMATION_TIME)
        else

          # update existing datemarker and his months
          @_uiElements.dateMarkers[i].div.style.left = @dateToPosition(@yearToDate(year)) + "px"
          if @millisToYears(interval) == 1

            # show months, create new month divs
            if @_uiElements.dateMarkers[i].months.length == 0
              for month_name, key in MONTH_NAMES
                month =
                  div: document.createElement("div")
                  startDate: new Date()
                  endDate: new Date()
                  name: month_name
                month.startDate.setFullYear(year, key, 1)
                month.endDate.setFullYear(year, key + 1, 0)
                month.div.className = "tl_month"
                month.div.innerHTML = month.name
                month.div.style.left = ((month.startDate.getTime() - @yearToDate(year).getTime()) / @millisPerPixel()) + "px"
                month.div.style.width = (@dateToPosition(month.endDate) - @dateToPosition(month.startDate)) + "px"
                $("#tl_year_" + year + " > .tl_months" ).append month.div
                @_uiElements.dateMarkers[i].months[key] = month

            # update existing month divs
            else
              for month in @_uiElements.dateMarkers[i].months
                month.div.style.left = ((month.startDate.getTime() - @yearToDate(year).getTime()) / @millisPerPixel()) + "px"
                month.div.style.width = (@dateToPosition(month.endDate) - @dateToPosition(month.startDate)) + "px"

          # hide and delete months
          else
            for month in @_uiElements.dateMarkers[i].months
              $(month.div).fadeOut(FADE_ANIMATION_TIME, `function() { $(this).remove(); }`)
            @_uiElements.dateMarkers[i].months.length = 0

      # hide and delete datemarker and their months
      else
        if @_uiElements.dateMarkers[i]?
          @_uiElements.dateMarkers[i].div.style.left = @dateToPosition(@yearToDate(year)) + "px"
          #$(@_uiElements.dateMarkers[i].div).fadeOut(FADE_ANIMATION_TIME, `function() { $(this).remove(); }`)
          $(@_uiElements.dateMarkers[i].div).remove()
          @_uiElements.dateMarkers[i] = null


  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  # eventhandler
  _switchTopic: (topic_tmp, setHash=true) ->

    # hide category
    window.location.hash = '#categories=null' if setHash

    #   if there is no active topic or different topic was clicked
    #   activate and highlight it (move to, and zoom)
    if !@_activeTopic? or topic_tmp.id isnt @_activeTopic.id
      diff = topic_tmp.endDate.getTime() - topic_tmp.startDate.getTime()
      millisec = diff / 2 + topic_tmp.startDate.getTime()
      middleDate = new Date(millisec)

      # set all topics as default and choosed as highlighted
      for topic in @_config.topics
        topic.div.className = "tl_topic tl_topic_row" + topic.row
      topic_tmp.div.className = "tl_topic_highlighted tl_topic_row" + topic_tmp.row

      # make topic active (also set in url)
      @_activeTopic = topic_tmp

      # move row so that subtopics can be shown
      @_moveTopicRows(true)

      # move timeline to center of topic bar
      # at the end of transition zoom in and filter categories
      @moveToDate middleDate, 1, =>
        if @_activeTopic.endDate > @maxVisibleDate()

          # use setInterval to zoom in repeatly
          # if zoom should stop call clearInterval(obj)
          # zoom delay is 50ms
          # todo: make zoom delay as a static parameter
          repeatObj = setInterval =>
            if @_activeTopic.endDate > (new Date(@maxVisibleDate().getTime() - (@maxVisibleDate().getTime() - @minVisibleDate().getTime()) * 0.1))
              @_zoom -1
            else
              clearInterval(repeatObj)
              window.location.hash = '#categories=' + topic_tmp.id if setHash
          , 50
        else
          repeatObj = setInterval =>
            if @_activeTopic.endDate < (new Date(@maxVisibleDate().getTime() - (@maxVisibleDate().getTime() - @minVisibleDate().getTime()) * 0.1))
              @_zoom 1
            else
              clearInterval(repeatObj)
              window.location.hash = '#categories=' + topic_tmp.id  if setHash
          , 50
    else
      if setHash
        # if same topic was clicked unable it
        # hide subtopic row and set class to default
        topic_tmp.div.className = "tl_topic tl_topic_row" + topic_tmp.row
        @_moveTopicRows(false)
        @_activeTopic = null

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  _moveTopicRows: (showSubtopics) ->
    if @_activeTopic.row is 0 and showSubtopics
      $('.tl_topic_row1').css({'bottom': HGConfig.timline_row1_position_up.val + 'px'})
    else
      $('.tl_topic_row1').css({'bottom': HGConfig.timline_row1_position.val + 'px'})



  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

  _disableTextSelection : (e) ->  return false
  _enableTextSelection : () ->    return true
