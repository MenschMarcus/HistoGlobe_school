window.HG ?= {}

window.HG.Database ?= {}

class HG.HiventDatabaseInterface

  ##############################################################################
  #                            PUBLIC INTERFACE                                #
  ##############################################################################

  # ============================================================================
  constructor: (databaseName) ->
    @_databaseName = databaseName

  # ============================================================================
  getHivents: (tableName, selector = "*",
               lowerLimit = "0", upperLimit = "1",
               condition = "",
               successCallback ) =>

    if (tableName?)
      successCallback?= (data) -> console.log data

       $.ajax({
            url: "php/query_database.php?dbName=#{@_databaseName}&tableName=#{tableName}&lowerLimit=#{lowerLimit}&upperLimit=#{upperLimit}",
            success: (data) =>
              builder = new HG.HiventBuilder()
              # rows = data.split "\n"
              # for row in rows
              #   builder.constructHiventFromDBString row, (hivent) =>
              #     @_hiventHandles.push new HG.HiventHandle hivent
              #     $.ajax({
              #               data: hivent,
              #               type: "POST",
              #               url: "php/add_hivent.php?dbName=hivents&tableName=test",
              #               success: (data) =>
              #                 console.log data
              #       })
              #   @_hiventsChanged = true
              #   @_filterHivents();


          })
    else
      console.error "Unable to get hivents: No table name specified!"
