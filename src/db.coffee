EngineObj = require './engine-obj.coffee'

module.exports = class CorvidDB
  constructor: ->
    @db = []
    @o = {}
    initMinimal this

  create: (name) ->
    @db.push obj = new EngineObj this, @db.length
    @addName name, obj if name
    return obj

  addName: (name, obj) ->
    if @o[name]
      throw new Error "Name '#{name}' already in use by #{@o[name].toString}"

    @o[name] = obj
    obj.names.push name

  destroy: (obj) ->
    if obj instanceOf EngineObj
      @destroy obj.id

    @db[obj] = undefined

initMinimal = (db) ->
  (require './db/minimal')(db)
