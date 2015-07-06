should = require 'should'
CorvidDB = require '../src/db.coffee'

describe 'CorvidDB', ->
  db = new CorvidDB

  describe '#new', ->
    it 'should return a db of some sort', ->
      should(db).be.ok()
###
    it 'should initialize a minimal db', ->
      should(db.o).exist()
      should(db.o.sys).exist()
      should(db.o.root).exist()
      should(db.o.wiz).exist()
    it 'should include a valid user', ->
      should(user = db.o.wiz).be.ok()
      should(user.parser).exist()
###
