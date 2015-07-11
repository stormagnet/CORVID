should = require 'should'
CorvidDB = require 'db'
EngineObj = require 'engine-obj'

db = new CorvidDB console.log

describe 'CorvidDB', ->
  describe '#new', ->
    it 'should return a db of some sort', ->
      should(db).be.ok()
      should(db.o).ok()

  describe '#create without name', ->
    o = db.create

    it 'should return a valid EngineObj', ->
      should(o instanceof EngineObj)

  describe '#create with name', ->
    o = db.create 'test'

    it 'should return a valid EngineObj', ->
      should(o instanceof EngineObj)
    it 'should register a name if such is provided', ->
      should(db.o.test).ok()

  describe 'Minaimal DB', ->
    it 'should include a sys object', ->
      db = new CorvidDB () ->
        should(db.o.sys).ok()
    it 'should include a root object', ->
      should(db.o.root).ok()
    it 'should include a wiz object', ->
      should(db.o.wiz).ok()
    it 'should have a user', ->
      should(db.user).be.ok()
    describe 'User', ->
      it 'should have a parser', ->
        should(db.user.parser).ok()
