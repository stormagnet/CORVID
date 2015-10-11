nextId = 0

module.exports = (makeId = -> nextId++) ->
  contextFinder = (obj) ->
    (info) ->
      (info = {looseMatch: info}) if typeof info is 'string'

      return undefined unless typeof info is 'object'

      {looseMatch, name, id} = info

      lookupContext = obj.db.lookupContext.bind obj

      return o if id and o = obj.db.o[id]
      return o if name and o = obj.db.names[name]
      return o if o = lookupContext looseMatch
      return undefined

      return  (id and obj.db.o[id]) or
              (name and obj.db.names[name]) or
              (lookupContext looseMatch)

  class Euclidic
    constructor: ({name}) ->
      @id = makeId()
      @isSubjOf = @isObjOf = @defines = {}
      @util.initContexts this
      @ctx.engine.name = name
      @methods

    name: -> @ctx.engine.name

    # XXX: we don't care about these yet
    isSubjOf: ->
    defines: ->
    isObjOf: ->

    addMethod: (name, code, compiler) ->
      @methods[name] = compiler(code).bind this
      @methods[name].code = code
      @methods[name].compiler = compiler

  class Relation extends Euclidic
    constructor: ({@subj, @rel, @obj, @params}) ->
      super arguments[0]
      @subj.isSubjOf this
      @rel.defines this
      @obj.isObjOf this

    relate: (subject, object) ->
      rel = new Relation
        relationship: this
        subject: subject
        object: object

    toString: ->
      "#{@subj.name} #{@name} #{@obj.name}"

  class Context extends Euclidic
    constructor: ({name}) ->
      super arguments[0]



  class Db
    constructor: (@namespace, @prefix = '$') ->
      @names = {}
      @o = {}
      @relationships = {}
      @contexts = {}

      @create 'sys'
      @create 'root'
      @create name: 'context', klass: Context
        .spawn 'engine'
        .spawn 'core'
      @create name: 'relation', klass: Relation

    addContext: ->
      @names.context.spawn arguments[0]

    relate: (subj, rel, obj) ->
      @names.relation.spawn
        subj: subj
        rel: rel
        obj: obj

    create: ({name, klass = Euclidic}) ->
      name or= arguments[0]
      o = new klass name: name

      if name and (parts = name.split '.') and parts[0]
        @util.addName @names, parts, o

        if @namespace
          parts[0] = @prefix + parts[0]
          @util.addName @namespace, parts, o

      return @o[o.id] = o

    util:
      initContexts: (o) ->
        o.ctx =
          engine: {}
          core: {}

      findOrCreate: ({name}) ->
        if not name
          throw new Error 'Can not look for empty (or falsy) name'

        @names[name] or @create arguments[0]

      addName: (ns, parts, o) ->
        for part in parts[0 .. parts.length - 2]
          ns = (ns[part] or= {})

        ns[parts.pop()] = o

  return Euclidic: Euclidic, Db: Db
