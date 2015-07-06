should = require 'should'
CorvidDB = require '../src/db.coffee'
EngineObj = require '../src/engine-obj.coffee'

describe 'CorvidDB', ->
  describe '#new', ->
    db = new CorvidDB

    it 'should return a db of some sort', ->
      should(db).be.ok()
    it 'should initialize a minimal db', ->
      should(db.o).ok()
  describe '#create without name', ->
    db = new CorvidDB
  describe '#create with name', ->
    o = db.create 'test'
    it 'should return a valid EngineObj', ->
      should(o instanceof EngineObj)
    it 'should register a name if such is provided', ->
      should(db.o).exist 'test'

###
  describe 'Minaimal DB', ->
    console.log db.o
    it 'should include a sys object', ->
      should(db.o.sys).ok()
    it 'should include a root object', ->
      should(db.o.root).ok()
    it 'should include a wiz object', ->
      should(db.o.wiz).ok()
    it 'should include a valid user', ->
      should(user = db.o.wiz).be.ok()
      should(user.parser).exist()
###
