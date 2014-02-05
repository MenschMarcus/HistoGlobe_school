window.HG ?= {}

class HG.TimeGalleryWidget extends HG.GalleryWidget

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (config) ->
    HG.GalleryWidget.call @, config

  # ============================================================================
  hgInit: (hgInstance) ->
    super hgInstance

    hgInstance.timeline.onNowChanged @, (data) =>
      console.log date
