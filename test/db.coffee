should = require 'should'
CorvidDB = require 'db'
EngineObj = require 'engine-obj'

db = new CorvidDB console.log
o = null

module.exports =
  'CorvidDB':
    '#new':
      'should return a db of some sort': ->
        should(db).be.ok()
        should(db.o).ok()

    '#create without name':
      before: -> o = db.create

      'should return a valid EngineObj': ->
        should(o instanceof EngineObj)

    '#create with name':
      before: -> o = db.create 'test'

      'should return a valid EngineObj': ->
        should(o instanceof EngineObj)
      'should register a name if such is provided': ->
        should(db.o.test).ok()

    'Minaimal DB':
      'should include a sys object': ->
        db = new CorvidDB () ->
          should(db.o.sys).ok()
      'should include a root object': ->
        should(db.o.root).ok()
      'should include a wiz object': ->
        should(db.o.wiz).ok()
      'should have a user': ->
        should(db.user).be.ok()
      'User':
        'should have a parser': ->
          should(db.user.parser).ok()
