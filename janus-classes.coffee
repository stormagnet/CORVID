util = require 'util'

module.exports = (client) ->
  class QueryBuilder
    @parameters: Object.assign {},
      ("addV addE as from to hasKey".split(' ').map (f) -> "#{f}": 1)...
      V: [0, 1]
      property: 2
      properties: [0, 1]
      hasLabel: [1, Infinity]
      has: [2, 3]
      hasId: [1, Infinity]

    constructor: (@soFar = "g") ->

    submit: ->
      client.post @soFar

    fn: (qInfo) ->
      for name, args of qInfo
        if not Array.isArray args
          args = [args]

        if not paramCount = QueryBuilder.templates[name]
          throw new Error "No template for function '#{name}'"

        if 'number' is paramCount and args.length isnt paramCount
          throw new Error "Wrong number of args (#{args.length}) for function #{name} (#{paramCount})"

        if Array.isArray paramCount and paramCount.length is 2 and not paramCount[0] <= args.length <= paramCount[1]
          throw new Error "Wrong number of args (#{args.length}) for function #{name} (#{paramCount.join ".."})"

        paramStr = new Array args.length
            .fill '%j'
            .join ','

        @soFar += util.format ".#{name}(#{paramStr})", args...

  class Property
    @create: (queryBuilder, name, values) ->
      values.forEach (v) -> queryBuilder.fn property: [name, v]
      return queryBuilder

    constructor: (@attachedTo, @name, @values) ->
      @first = @values[0]

    values: -> @values.map (v) -> v.value

    addValues: (values) ->
      query = new QueryBuilder
        .fn V: @attachedTo.id

      for v in values
        query.fn property: [@name, v]

      query.submit()
        .then ->
          query = @attachedTo.query()
            .fn properties: @name
            .fn valueMap: true
            .then (valueMap) ->

  class Vertex
    @create: (type, name, properties) ->
      query = new QueryBuilder
        .fn addV: type

      properties.name = name
      for k, v of properties
        Property.create query, k, v
      
      query.submit()
        .then (created) ->
          created = new Vertex created

    constructor: ({@id, @label, @type, properties}) ->
      @properties = {}
      @_addProp name, values for name, values of properties

    _addProp: (name, values) ->
      @properties[name] = new Property @, name, values

    setProp: (name, values) ->
      if not @properties[name]
        @property name, values
      else
        @properties[name].addValues values

    getProp:   (propName) -> @properties[propName]
    allValues: (propName) -> @properties[propName].map (p) -> p.value
    firstVal:  (propName) -> @properties[propName].first.value
    propNames:            -> Object.getOwnPropertyNames @properties

    name: (nameToAdd) ->
      if nameToAdd
        if p = @properties.name
          p.addValue nameToAdd
          @allValues 'name'
        else
          @property 'name', nameToAdd
      else
        @firstVal 'name'

    property: (name, value) ->
      client.post 'g.V(%j).property(%j,%j)', @id, name, value
        .then (prop) ->
          @props[name] = new Property name, prop

    connectTo: (other) ->
      new Edge @, to

    query: ->
      new QueryBuilder
        .fn V: @id

  class Edge extends Vertex
    constructor: (from, to, props = {}) ->
      from.query
        .fn as: 'a'

  {Vertex, Property, QueryBuilder, Edge, client}
