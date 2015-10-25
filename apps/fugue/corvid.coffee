util = require 'util'
nextId = 0

module.exports = (makeId = -> nextId++) ->
  class Referent
    constructor: (@db) ->
      @id = makeId()
      @behaviors = {}
      @as = {}

      @db.registerRef this

    addBehavior: (behavior, name = behavior.name) ->
      if util.isFunction name
        name = name()

      self = euclidic: this
      Object.setPrototypeOf self, behavior
      @behaviors[behavior.id] = self

      if name
        @as[behavior.name] = self

      behavior.as.behavior.init self

    delBehavior: (behavior) -> delete @behaviors[behavior.id]

    withBehavior: (behavior, methodName, args) ->
      self = @behaviors[behavior.id]
      method = behavior.methods[methodName]
      method.call self, args


  class Behavior extends Referent
    constructor: ->
      super
      @methods = {}

    addMethod: (name, code, compiler) ->
      @methods[name] = compiler(code).bind this
      @methods[name].code = code
      @methods[name].compiler = compiler

    delMethod: (name) -> delete @methods[name]


  class Relation extends Referent
    constructor: ({@subj, @rel, @obj, @params}) ->
      super
      @db.registerRel this

    relate: (subject, object, @params = {}) ->
      new Relation
        @rel = this
        @sub = subject
        @obj = object

    toString: ->
      "#{@subj.name} #{} #{@obj.name}"


  class Db
    constructor: (@namespace, @prefix = '$') ->
      @names = {}
      @o = {}
      @rel =
        bySub: {}
        byRel: {}
        byObj: {}
      @initDb()

    registerRef: (ref) ->
      @o[ref.id] = ref

    registerRel: (rel) ->
      @rel.bySub[rel.sub.id] = rel
      @rel.byRel[rel.rel.id] = rel
      @rel.byObj[rel.obj.id] = rel

    initDb: ->
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
      Db: Db
    }
