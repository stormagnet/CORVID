{ History  } = require '../history'
{ Euclidic } = require '../euclidic'
{ Store    } = require '../store'
{ Core     } = require '../core'

class module.World
  constructor: (config) ->
    { @store      = Store.default()
      initializer = Core.defaultInitializer()
      @history    = new History
    } = config
