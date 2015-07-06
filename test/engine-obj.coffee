should = require 'should'

describe 'EngineObj', ->
  describe '#new', ->
    EngineObj = require '../src/engine-obj.coffee'
    CorvidDB = require '../src/db.coffee'
    return
    db = new CorvidDB
    o = db.create()
