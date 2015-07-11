should = require 'should'

describe 'EngineObj', ->
  describe '#new', ->
    EngineObj = require 'engine-obj'
    CorvidDB = require 'db'
    return
    db = new CorvidDB
    o = db.create()
