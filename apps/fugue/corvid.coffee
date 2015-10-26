util = require 'util'
nextId = 0

Referent = require 'referent'
Behavior = require 'behavior'
Relation = require 'relation'

module.exports = (makeId = -> nextId++) ->
  class Db
    constructor: (@namespace, @prefix = '$') ->
      @names = {}
      @o = {}
      @rel =
        bySub: {}
        byRel: {}
        byObj: {}
      @compilers = {}
      @initDb()

    addCompiler: (name, factory) ->
      @compilers[name] = factory

    registerRef: (ref) ->
      @o[ref.id] = ref

    registerRel: (rel) ->
      @rel.bySub[rel.sub.id] = rel
      @rel.byRel[rel.rel.id] = rel
      @rel.byObj[rel.obj.id] = rel

    initDb: ->
      @addCompiler 'coffeescript', ->
        coffee = require 'coffee-script'
        (code) -> coffee.eval code

      @create 'sys'
      @create 'root'
      @create 'behavior', Behavior
      @create 'relation', Relation

    relate: (subj, rel, obj) ->
      rel.relate subj, obj

    create: (name, klass = Referent) ->
      o = new klass db: this

      if name
        @addName o, name

    _addName = (ns, name, value, prefix) ->
      [path..., name] = name.split '.'

      if prefix
        path[0] = prefix + path[0]

      for part in path
        ns = (ns[part] or= {})

      ns[name] = value

    addName: (o, name) ->
      _addName @names, name, o
      
      if @prefix
        _addName module, name, o, @prefix

    findOrCreate: ({name}) ->
      if not name
        throw new Error 'Can not look for empty (or falsy) name'

      @names[name] or @create arguments[0]

  return {
      Referent: Referent
      Relation: Relation
      Behavior: Behavior
      Db: Db
    }
