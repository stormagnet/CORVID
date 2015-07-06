EngineObj = require './engine-obj.coffee'

module.exports = class CorvidDB
  constructor: (next) ->
    @db = []
    @o = {}
    initMinimal this, next || -> true

  create: (name) ->
    o = new EngineObj this, @db.length
    @addName name, o if name
    o

  addName: (name, obj) ->
    if @o[name]
      throw new Error 'Name already in use'

    @o[name] = obj
    obj.names.push name

  destroy: (o) ->
    if o instanceOf EngineObj
      @destroy o.id

    @db[o] = undefined

initMinimal = (db, next) ->
  (require './db/minimal')(db, next)
