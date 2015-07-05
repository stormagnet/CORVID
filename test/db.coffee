should = require 'should'
CorvidDB = require '../src/db.coffee'

describe 'CorvidDB', ->
  describe '#new', ->
    it 'should initialize a minimal db', ->
      db = new CorvidDB
      should(db).be.ok()
      should(db.o).exist()
      should(db.o.sys).exist()
      should(db.o.root).exist()
      should(db.o.wiz).exist()

      user = db.o.wiz
      should(user.parser).exist()
