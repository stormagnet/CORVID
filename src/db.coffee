module.exports = CorvidDB

EngineObj = require 'engine-obj'

class CorvidDB
  constructor: (next) ->
    @db = []
    @o = {}
    initMinimal this, next || -> true
    
initMinimal = (db, next) ->
  (require 'db/minimal')(db, next)
