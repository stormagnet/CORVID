uuid = require 'node-uuid'
makeId = -> uuid.unparse uuid.v4()

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
    @name = name # for now

class Db
  constructor: (@namespace, @prefix = '$') ->
    @names = {}
    @o = {}

    @create 'sys'
    @create 'root'

  findOrCreate: ({name}) ->
    if not name
      throw new Error 'Cannot match empty (or falsy) name'

    @names[name] or @create arguments[0]

  create: ({name}) ->
    console.log 'create: ', name
    o = new Euclidic name: name

    if name and (parts = name.split '.') and parts[0]
      @util.addName @names, parts, o

      if @namespace
        parts[0] = @prefix + parts[0]
        @util.addName @namespace, parts, o
      
    return @o[o.id] = o

  util:
    addName: (ns, parts, o) ->
      for part in parts[0 .. parts.length - 2]
        ns = (ns[part] or= {})

      ns[parts.pop()] = o

module.exports = () ->
  Euclidic: Euclidic
  Db: Db

