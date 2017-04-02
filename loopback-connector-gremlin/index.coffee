{createClient, bindForClient} = require 'gremlin'

{Connector} = require 'loopback-connector'

debug = (require 'debug') 'loopback:connector:gremlin'

class Gremlin extends Connector
  constructor: (@client, settings) ->
    super 'gremlin', settings

  getDefaultIdType: -> Number

  execute: (command, params, options, callback) ->
    client.execute command, params, callback


callLater = (fn) ->
  process.nextTick fn if 'function' is typeof callback

initialize = (dataSource, cb) ->
  client = gremlin.createClient settings = dataSource.settings
  dataSource.connector = new Gremlin client, settings
  callLater cb

module.exports = {Gremlin, initialize}
