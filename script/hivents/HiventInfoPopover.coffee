window.HG ?= {}

class HG.HiventInfoPopover

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (hiventHandle, container, hgInstance, hiventIndex, showArrow) ->

    @_hiventHandle = hiventHandle
    @_hgInstance = hgInstance
    @_visible = false
    @_multimediaController = hgInstance.multimediaController

    # generate content
    body = document.createElement "div"

    locationString = ''
    if hiventIndex? and @_hiventHandle.getHivent().locationName?
      locationString = @_hiventHandle.getHivent().locationName[hiventIndex] + ', '

    subheading = document.createElement "h3"
    subheading.innerHTML = locationString + @_hiventHandle.getHivent().displayDate
    body.appendChild subheading

    gotoDate = document.createElement "i"
    gotoDate.className = "fa fa-clock-o"
    $(gotoDate).tooltip {title: "Springe zum Ereignisdatum", placement: "right", container:"#histoglobe"}
    $(gotoDate).click () =>
      @_hgInstance.timeline.moveToDate @_hiventHandle.getHivent().startDate, 0.5
    subheading.appendChild gotoDate


    text = document.createElement "div"
    text.innerHTML = @_hiventHandle.getHivent().content
    body.appendChild text


    # create popover
    @_popover = new HG.Popover
      hgInstance: hgInstance
      placement:  "auto"
      content:    body
      title:      @_hiventHandle.getHivent().name
      container:  container
      showArrow:  showArrow
      fullscreen: !showArrow



    @_multimedia = @_hiventHandle.getHivent().multimedia
    if @_multimedia != "" and @_multimediaController?
      mmids = @_multimedia.split ","

      gallery = new HG.Gallery
        interactive : true
        showPagination : (mmids.length >= 2)

      gallery.mainDiv.style.marginLeft = -HGConfig.widget_body_padding.val + "px"
      gallery.mainDiv.style.marginRight = -HGConfig.widget_body_padding.val + "px"

      body.insertBefore gallery.mainDiv, text

      gallery.init()

      @_popover.onResize @, () =>
        gallery.reInit()

      @_multimediaController.onMultimediaLoaded () =>

        for id in mmids
          mm = @_multimediaController.getMultimediaById id
          if mm?

            # if mm.type is 0
            elem = document.createElement "a"
            gallery.addDivSlide elem

            elem.href = mm.thumbnail
            elem.title = mm.description
            elem.alt = mm.description
            elem.style.backgroundImage = "url('" + mm.thumbnail + "')"
            elem.className = "gallery-image"
            $(elem).colorbox
              # rel: gallery.id
              # current: "Bild {current} von {total}"
              # loop: false
              title: "<p class='gallery-copyright'>" + mm.source + "</p>" + mm.description
              html : if mm.type is 0 then '' else "<video width='320' height='240' controls> <source src='#{mm.link}' type='video/mp4'> </video>"

            if mm.crop
              $(elem).addClass("cropped")

            # else
            #   elem = document.createElement "div"
            #   gallery.addDivSlide elem

            #   link = mm.link

            #   elem.innerHTML = '<div id="jp_container_1" class="jp-video ">
            #     <div class="jp-type-single">
            #       <div id="jquery_jplayer_1" class="jp-jplayer"></div>
            #       <div class="jp-gui">
            #         <div class="jp-video-play">
            #           <a href="javascript:;" class="jp-video-play-icon" tabindex="1">play</a>
            #         </div>
            #         <div class="jp-interface">
            #           <div class="jp-progress">
            #             <div class="jp-seek-bar">
            #               <div class="jp-play-bar"></div>
            #             </div>
            #           </div>
            #           <div class="jp-current-time"></div>
            #           <div class="jp-duration"></div>
            #           <div class="jp-controls-holder">
            #             <ul class="jp-controls">
            #               <li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
            #               <li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
            #               <li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>
            #               <li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>
            #               <li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>
            #               <li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>
            #             </ul>
            #             <div class="jp-volume-bar">
            #               <div class="jp-volume-bar-value"></div>
            #             </div>
            #             <ul class="jp-toggles">
            #               <li><a href="javascript:;" class="jp-full-screen" tabindex="1" title="full screen">full screen</a></li>
            #               <li><a href="javascript:;" class="jp-restore-screen" tabindex="1" title="restore screen">restore screen</a></li>
            #               <li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>
            #               <li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>
            #             </ul>
            #           </div>
            #           <div class="jp-details">
            #             <ul>
            #               <li><span class="jp-title"></span></li>
            #             </ul>
            #           </div>
            #         </div>
            #       </div>
            #       <div class="jp-no-solution">
            #         <span>Update Required</span>
            #         To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
            #       </div>
            #     </div>
            #   </div>'

            #   $('#jquery_jplayer_1').jPlayer
            #     ready: () ->
            #       $(this).jPlayer "setMedia",
            #         m4v: link,
            #         poster: "data/video.png"
            #     ,
            #     swfPath: "script/third-party/",
            #     size:
            #       width: "320px",
            #       height: "180px"
            #       # cssClass: "jp-video-360p"
            #     ,
            #     preload: 'metadata',
            #     smoothPlayBar: true,
            #     keyEnabled: true,
            #     remainingDuration: true,
            #     toggleDuration: true
            #     supplied: "m4v"




    @_hiventHandle.onDestruction @, @_popover.destroy


  # ============================================================================
  show: (position) =>
    @_popover.show
      x: position.at(0)
      y: position.at(1)
      @_visible = true

  # ============================================================================
  hide: =>
    @_popover.hide()
    @_hiventHandle._activated = false
    @_visible = false

  # ============================================================================
  isVisible: =>
    @_visible

  # ============================================================================
  updatePosition: (position) ->
    @_popover.updatePosition
      x: position.at(0)
      y: position.at(1)

  # ============================================================================
  destroy: () ->
    @_popover.destroy()
