nextId = 0

module.exports = (makeId = -> nextId++) ->
  behaviorFinder = (obj) ->
    (info) ->
      (info = {looseMatch: info}) if typeof info is 'string'

      return undefined unless typeof info is 'object'

      {looseMatch, name, id} = info

      lookupBehavior = obj.db.lookupBehavior.bind obj

      return o if id and o = obj.db.o[id]
      return o if name and o = obj.db.names[name]
      return o if o = lookupBehavior looseMatch
      return undefined

      return  (id and obj.db.o[id]) or
              (name and obj.db.names[name]) or
              (lookupBehavior looseMatch)

  class Referent
    constructor: (@db) ->
      @id = makeId()
      @behaviors = {}
      @db.registerRef this

    addBehavior: (behavior) ->
      self = {}
      Object.setPrototypeOf self, behavior
      @behaviors[behavior.id] = self

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
        relationship: @id
        subject: subject.id
        object: object.id

    toString: ->
      "#{@subj.name} #{@name} #{@obj.name}"


  class Db
    constructor: (@namespace, @prefix = '$') ->
      @names = {}
      @o = {}
      @relationships = {}
      @initDb()

    initDb: ->
      @create 'sys'
      @create 'root'
      @create 'behavior', Behavior
      @create 'relation', Relation

    addBehavior: (pkg) ->
      @names.behavior.spawn pkg

    relate: (subj, rel, obj) ->
      rel.relate subj, obj

    create: (name, klass = Referent) ->
      o = new klass db: this

      if name
        @addName o, name

    addName: (o, name) ->
      ns = @names
      [path..., name] = name.split '.'


      for part in path
        ns = (ns[part] or= {})

      ns[name] = o

    util:
      findOrCreate: ({name}) ->
        if not name
          throw new Error 'Can not look for empty (or falsy) name'

        @names[name] or @create arguments[0]

  return {
      Referent: Referent
      Db: Db
    }
