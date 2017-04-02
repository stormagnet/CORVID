_compareVal = (a, b) -> b is undefined and a isnt undefined or a > b

serialize = (obj) ->
  if obj == null or obj == undefined
    return obj
  JSON.stringify obj

deserialize = (dbObj) ->
  if dbObj == null or dbObj == undefined
    return dbObj
  if typeof dbObj == 'string'
    JSON.parse dbObj
  else
    dbObj

getValue = (obj, path) ->
  if obj == null
    return undefined
  keys = path.split('.')
  val = obj
  i = 0
  n = keys.length
  while i < n
    val = val[keys[i]]
    if val == null
      return val
    i++
  val

applyFilter = (filter) ->
  where = filter.where

  toRegExp = (pattern) ->
    if pattern instanceof RegExp
      return pattern
    regex = ''
    # Escaping user input to be treated as a literal string within a regular expression
    # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#Writing_a_Regular_Expression_Pattern
    pattern = pattern.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, '\\$1')
    i = 0
    n = pattern.length
    while i < n
      char = pattern.charAt(i)
      if char == '\\'
        i++
        # Skip to next char
        if i < n
          regex += pattern.charAt(i)
        i++
        continue
      else if char == '%'
        regex += '.*'
      else if char == '_'
        regex += '.'
      else if char == '.'
        regex += '\\.'
      else if char == '*'
        regex += '\\*'
      else
        regex += char
      i++
    regex

  test = (example, value) ->
    `var i`
    if typeof value == 'string' and example instanceof RegExp
      return value.match(example)
    if example == undefined
      return undefined
    if typeof example == 'object' and example != null
      if example.regexp
        return if value then value.match(example.regexp) else false
      # ignore geo near filter
      if example.near
        return true
      if example.inq
        # if (!value) return false;
        i = 0
        while i < example.inq.length
          if example.inq[i] == value
            return true
          i++
        return false
      if example.nin
        i = 0
        while i < example.nin.length
          if example.nin[i] == value
            return false
          i++
        return true
      if 'neq' of example
        return compare(example.neq, value) != 0
      if 'between' of example
        return testInEquality({ gte: example.between[0] }, value) and testInEquality({ lte: example.between[1] }, value)
      if example.like or example.nlike or example.ilike or example.nilike
        like = example.like or example.nlike or example.ilike or example.nilike
        if typeof like == 'string'
          like = toRegExp(like)
        if example.like
          return ! !new RegExp(like).test(value)
        if example.nlike
          return !new RegExp(like).test(value)
        if example.ilike
          return ! !new RegExp(like, 'i').test(value)
        if example.nilike
          return !new RegExp(like, 'i').test(value)
      if testInEquality(example, value)
        return true
    # not strict equality
    (if example != null then example.toString() else example) == (if value != null then value.toString() else value)

  ###*
  # Compare two values
  # @param {*} val1 The 1st value
  # @param {*} val2 The 2nd value
  # @returns {number} 0: =, positive: >, negative <
  # @private
  ###

  compare = (val1, val2) ->
    if val1 == null or val2 == null
      # Either val1 or val2 is null or undefined
      return if val1 == val2 then 0 else NaN
    if typeof val1 == 'number'
      return val1 - val2
    if typeof val1 == 'string'
      return if val1 > val2 then 1 else if val1 < val2 then -1 else if val1 == val2 then 0 else NaN
    if typeof val1 == 'boolean'
      return val1 - val2
    if val1 instanceof Date
      result = val1 - val2
      return result
    # Return NaN if we don't know how to compare
    if val1 == val2 then 0 else NaN

  testInEquality = (example, val) ->
    if 'gt' of example
      return compare(val, example.gt) > 0
    if 'gte' of example
      return compare(val, example.gte) >= 0
    if 'lt' of example
      return compare(val, example.lt) < 0
    if 'lte' of example
      return compare(val, example.lte) <= 0
    false

  if typeof where == 'function'
    return where
  keys = Object.keys(where)
  (obj) ->
    keys.every (key) ->
      if key == 'and' or key == 'or'
        if Array.isArray(where[key])
          if key == 'and'
            return where[key].every((cond) ->
              applyFilter(where: cond) obj
            )
          if key == 'or'
            return where[key].some((cond) ->
              applyFilter(where: cond) obj
            )
      value = getValue(obj, key)
      # Support referencesMany and other embedded relations
      # Also support array types. Mongo, possibly PostgreSQL
      if Array.isArray(value)
        matcher = where[key]
        # The following condition is for the case where we are querying with
        # a neq filter, and when the value is an empty array ([]).
        if matcher.neq != undefined and value.length <= 0
          return true
        return value.some((v, i) ->
          `var filter`
          filter = where: {}
          filter.where[i] = matcher
          applyFilter(filter) value
        )
      if test(where[key], value)
        return true
      # If we have a composed key a.b and b would resolve to a property of an object inside an array
      # then, we attempt to emulate mongo db matching. Helps for embedded relations
      dotIndex = key.indexOf('.')
      subValue = obj[key.substring(0, dotIndex)]
      if dotIndex != -1
        subFilter = where: {}
        subKey = key.substring(dotIndex + 1)
        subFilter.where[subKey] = where[key]
        if Array.isArray(subValue)
          return subValue.some(applyFilter(subFilter))
        else if typeof subValue == 'object' and subValue != null
          return applyFilter(subFilter)(subValue)
      false

merge = (base, update) ->
  if !base
    return update
  # We cannot use Object.keys(update) if the update is an instance of the model
  # class as the properties are defined at the ModelClass.prototype level
  for key of update
    val = update[key]
    if typeof val == 'function'
      i++
      continue
      # Skip methods
    base[key] = val
  base

'use strict'

### global window:false ###

g = require('strong-globalize')()
util = require('util')
Connector = require('loopback-connector').Connector
geo = require('../geo')
utils = require('../utils')
fs = require('fs')
async = require('async')

###*
# Initialize the Gremlin connector against the given data source
#
# @param {DataSource} dataSource The loopback-datasource-juggler dataSource
# @param {Function} [callback] The callback function
###

exports.initialize = (dataSource, callback) ->
  (dataSource.connector = new Gremlin null, dataSource.settings)
    .connect callback
  return

exports.Gremlin = Gremlin
exports.applyFilter = applyFilter

class Gremlin extends Connector
  constructor: (gremlin, settings) ->
    if gremlin instanceof Gremlin
      @isTransaction = true
      super 'gremlin', settings
      @_models = gremlin._models
    else
      @cache = {}
      @isTransaction = false
      super 'gremlin', settings

  getDefaultIdType: -> Number

  getTypes: -> [ 'gremlin' ]

  connect: (callback) ->
    if @isTransaction
      @onTransactionExec = callback
      return

    @gremlin = gremlin.createClient @settings.port, @settings.host
    @queries = gremlin.bindForClient @gremlin,
      getByProp: (pName, pVal) =>
        gremin: "g.V().has(pName, pVal)"
        bindings: { pName, pVal }
    callback()
    return

  getCollection: (model) ->
    modelClass = @_models[model]

    if modelClass and modelClass.settings.memory
      model = modelClass.settings.memory.collection or model

    model

  initCollection: (model) ->
    @collection model, {}
    @collectionSeq model, 1
    return

  collection: (model, val) ->
    model = @getCollection model

    if arguments.length > 1
      @cache[model] = val
      @queries....

    @cache[model]

  collectionSeq: (model, val) ->
    model = @getCollection(model)
    if arguments.length > 1
      @ids[model] = val
    @ids[model]

  define: (definition) ->
    @constructor.super_::define.apply this, [].slice.call(arguments)
    m = definition.model.modelName
    if !@collection(m)
      @initCollection m
    return

  _createSync: (model, data, fn) ->
    # FIXME: [rfeng] We need to generate unique ids based on the id type
    # FIXME: [rfeng] We don't support composite ids yet
    currentId = @collectionSeq(model)
    if currentId == undefined
      # First time
      currentId = @collectionSeq(model, 1)
    id = @getIdValue(model, data) or currentId
    if id > currentId
      # If the id is passed in and the value is greater than the current id
      currentId = id
    @collectionSeq model, Number(currentId) + 1
    props = @_models[model].properties
    idName = @idName(model)
    id = props[idName] and props[idName].type and props[idName].type(id) or id
    @setIdValue model, data, id
    if !@collection(model)
      @collection model, {}
    if @collection(model)[id]
      return fn(new Error(g.f('Duplicate entry for %s.%s', model, idName)))
    @collection(model)[id] = serialize(data)
    fn null, id
    return

  create: (model, data, options, callback) ->
    @_createSync model, data, (err, id) =>
      if err
        return process.nextTick(=>
          callback err
          return
        )
      @saveToFile id, callback
      return
    return

  updateOrCreate: (model, data, options, callback) ->
    @exists model, @getIdValue(model, data), options, (err, exists) =>
      if exists
        @save model, data, options, (err, data) =>
          callback err, data, isNewInstance: false
          return
      else
        @create model, data, options, (err, id) =>
          @setIdValue model, data, id
          callback err, data, isNewInstance: true
          return
      return
    return

  upsertWithWhere: Gremlin::patchOrCreateWithWhere = (model, where, data, options, callback) ->
    primaryKey = @idName(model)
    filter = where: where
    nodes = @_findAllSkippingIncludes(model, filter)
    if nodes.length == 0
      return @_createSync(model, data, (err, id) =>
        if err
          return process.nextTick(=>
            callback err
            return
          )
        @saveToFile id, (err, id) =>
          @setIdValue model, data, id
          callback err, @fromDb(model, data), isNewInstance: true
          return
        return
      )
    if nodes.length == 1
      primaryKeyValue = nodes[0][primaryKey]
      @updateAttributes model, primaryKeyValue, data, options, (err, data) =>
        callback err, data, isNewInstance: false
        return
    else
      process.nextTick =>
        error = new Error('There are multiple instances found.' + 'Upsert Operation will not be performed!')
        error.statusCode = 400
        callback error
        return
    return

  findOrCreate: (model, filter, data, callback) ->
    nodes = @_findAllSkippingIncludes(model, filter)
    found = nodes[0]
    if !found
      # Calling _createSync to update the collection in a sync way and to guarantee to create it in the same turn of even loop
      return @_createSync(model, data, (err, id) =>
        if err
          return callback(err)
        @saveToFile id, (err, id) =>
          @setIdValue model, data, id
          callback err, data, true
          return
        return
      )
    if !filter or !filter.include
      return process.nextTick(=>
        callback null, found, false
        return
      )
    @_models[model].model.include nodes[0], filter.include, {}, (err, nodes) =>
      process.nextTick =>
        if err
          return callback(err)
        callback null, nodes[0], false
        return
      return
    return

  save: (model, data, options, callback) ->
    id = @getIdValue(model, data)
    cachedModels = @collection(model)
    modelData = cachedModels and @collection(model)[id]
    modelData = modelData and deserialize(modelData)
    if modelData
      data = merge(modelData, data)
    @collection(model)[id] = serialize(data)
    @saveToFile data, (err) =>
      callback err, @fromDb(model, data), isNewInstance: !modelData
      return
    return

  exists: (model, id, options, callback) ->
    process.nextTick =>
      callback null, @collection(model) and @collection(model).hasOwnProperty(id)

  find: (model, id, options, callback) ->
    process.nextTick =>
      callback null, id of @collection(model) and @fromDb(model, @collection(model)[id])

  destroy: (model, id, options, callback) ->
    exists = @collection(model)[id]
    delete @collection(model)[id]
    @saveToFile { count: if exists then 1 else 0 }, callback
    return

  fromDb: (model, data) ->
    if !data
      return null
    data = deserialize(data)
    props = @_models[model].properties
    for key of data
      val = data[key]
      if val == undefined or val == null
        i++
        continue
      if props[key]
        switch props[key].type.name
          when 'Date'
            val = new Date(val.toString().replace(/GMT.*$/, 'GMT'))
          when 'Boolean'
            val = Boolean(val)
          when 'Number'
            val = Number(val)
      data[key] = val
    data

  _findAllSkippingIncludes: (model, filter) ->
    nodes = Object
      .keys @collection model
      .map (key) => @fromDb model, @collection(model)[key]

    sorting = (a, b) ->
      for i in [..@length]
        key = @[i].key
        aVal = getValue(a, @[i].key)
        bVal = getValue(b, @[i].key)
        if _compareVal aVal = getValue(a, key), bVal = getValue(a, key)
          return 1 * @[i].reverse
        else if _compareVal bVal, aVal
          return -1 * @[i].reverse
        i++
      0

    if filter
      if !filter.order
        idNames = @idNames(model)
        if idNames and idNames.length
          filter.order = idNames
      # do we need some sorting?
      if filter.order
        orders = filter.order
        if typeof filter.order == 'string'
          orders = [ filter.order ]
        orders.forEach (key, i) ->
          reverse = 1
          m = key.match(/\s+(A|DE)SC$/i)
          if m
            key = key.replace(/\s+(A|DE)SC/i, '')
            if m[1].toLowerCase() == 'de'
              reverse = -1
          orders[i] =
            'key': key
            'reverse': reverse
          return
        nodes = nodes.sort(sorting.bind(orders))
      nearFilter = geo.nearFilter(filter.where)
      # geo sorting
      if nearFilter
        nodes = geo.filter(nodes, nearFilter)
      # do we need some filtration?
      if filter.where and nodes
        nodes = nodes.filter(applyFilter(filter))
      # field selection
      if filter.fields
        nodes = nodes.map(utils.selectFields(filter.fields))
      # limit/skip
      skip = filter.skip or filter.offset or 0
      limit = filter.limit or nodes.length
      nodes = nodes.slice(skip, skip + limit)
    nodes

  all: (model, filter, options, callback) ->
    nodes = @_findAllSkippingIncludes(model, filter)
    process.nextTick =>
      if filter and filter.include
        @_models[model].model.include nodes, filter.include, options, callback
      else
        callback null, nodes
      return
    return

  destroyAll: (model, where, options, callback) ->
    cache = @collection(model)
    filter = null
    count = 0
    if where
      filter = applyFilter {where}
      Object
        .keys cache
        .forEach (id) =>
          if !filter or filter(@fromDb(model, cache[id]))
            count++
            delete cache[id]
          return
    else
      count = Object.keys(cache).length
      @collection model, {}
    @saveToFile { count: count }, callback
    return

  count: (model, where, options, callback) ->
    cache = @collection(model)
    data = Object.keys(cache)
    if where
      filter = where: where
      data = data
        .map (id) => @fromDb model, cache[id]
        .filter applyFilter filter
    process.nextTick ->
      callback null, data.length
      return
    return

  updateAll: Gremlin::update = (model, where, data, options, cb) ->
    cache = @collection(model)
    filter = null
    where = where or {}
    filter = applyFilter(where: where)
    ids = Object.keys(cache)
    count = 0
    async.each ids, ((id, done) =>
      inst = @fromDb(model, cache[id])
      if !filter or filter(inst)
        count++
        # The id value from the cache is string
        # Get the real id from the inst
        id = @getIdValue(model, inst)
        @updateAttributes model, id, data, options, done
      else
        process.nextTick done
      return
    ), (err) =>
      if err
        return cb(err)
      @saveToFile { count: count }, cb
      return
    return

  updateAttributes: (model, id, data, options, cb) ->
    if !id
      err = new Error(g.f('You must provide an {{id}} when updating attributes!'))
      if cb
        return cb(err)
      else
        throw err
    # Do not modify the data object passed in arguments
    data = Object.create(data)
    @setIdValue model, data, id
    cachedModels = @collection(model)
    modelData = cachedModels and @collection(model)[id]
    if modelData
      @save model, data, options, cb
    else
      cb new Error(g.f('Could not update attributes. {{Object}} with {{id}} %s does not exist!', id))
    return

  replaceById: (model, id, data, options, cb) ->
    if !id
      err = new Error(g.f('You must provide an {{id}} when replacing!'))
      return process.nextTick(=>
        cb err
        return
      )
    # Do not modify the data object passed in arguments
    data = Object.create(data)
    @setIdValue model, data, id
    cachedModels = @collection(model)
    modelData = cachedModels and @collection(model)[id]
    if !modelData
      msg = 'Could not replace. Object with id ' + id + ' does not exist!'
      return process.nextTick(=>
        cb new Error(msg)
        return
      )
    newModelData = {}
    for key of data
      val = data[key]
      if typeof val == 'function'
        i++
        continue
        # Skip methods
      newModelData[key] = val
    @collection(model)[id] = serialize(newModelData)
    @saveToFile newModelData, (err) =>
      cb err, @fromDb(model, newModelData)
      return
    return

  replaceOrCreate: (model, data, options, callback) ->
    idName = @idNames(model)[0]
    idValue = @getIdValue(model, data)
    filter = where: {}
    filter.where[idName] = idValue
    nodes = @_findAllSkippingIncludes(model, filter)
    found = nodes[0]
    if !found
      # Calling _createSync to update the collection in a sync way and
      # to guarantee to create it in the same turn of even loop
      return @_createSync(model, data, (err, id) =>
        if err
          return process.nextTick(=>
            callback err
            return
          )
        @saveToFile id, (err, id) =>
          @setIdValue model, data, id
          callback err, @fromDb(model, data), isNewInstance: true
          return
        return
      )
    id = @getIdValue(model, data)
    @collection(model)[id] = serialize(data)
    @saveToFile data, (err) =>
      callback err, @fromDb(model, data), isNewInstance: false
      return
    return

  transaction: ->
    new Gremlin(this)

  exec: (callback) ->
    @onTransactionExec()
    setTimeout callback, 50
    return

  buildNearFilter: (filter) ->
    # noop
    return

  automigrate: (models, cb) ->
    if !cb and 'function' == typeof models
      cb = models
      models = undefined
    # First argument is a model name
    if 'string' == typeof models
      models = [ models ]
    models = models or Object.keys(@_models)
    if models.length == 0
      return process.nextTick(cb)
    invalidModels = models.filter((m) =>
      !(m of @_models)
    )
    if invalidModels.length
      return process.nextTick(=>
        cb new Error(g.f('Cannot migrate models not attached to this datasource: %s', invalidModels.join(' ')))
        return
      )
    models.forEach (m) =>
      @initCollection m
      return
    if cb
      process.nextTick cb
    return
