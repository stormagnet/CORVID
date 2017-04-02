gremlin = require 'gremlin'
g = require 'strong-globalize'
{Connector} = require 'loopback-connector'
debug = require('debug') 'loopback:connector:gremlin'

class ObjectID
  constructor: (@id) ->
    if @id instanceof ObjectID or 'string' isnt typeof @id
      return @id

exports.initialize = initializeDataSource = (dataSource, cb) ->
  { port = 8182
    host = 'localhost'
    session = false
  } = dataSource.settings

  dataSource.connector = gremlin.createClient port, host, session
  dataSource.ObjectID = ObjectID

  cb()
  
class Gremlin extends Connector
  constructor: (@settings, @dataSource) ->
    super 'gremlin', @settings

    if @debug = @settings.debug or debug.enabled
      @debug 'Settings: %j', @settings

  connect: (cb = ->) ->
    if @db
      return process.nextTick => cb null, @db

    if @dataSource.connecting
      return @dataSource.once 'connected', => cb null, @db

    
