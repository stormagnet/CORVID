module.exports = class EngineObj
  constructor: (@db, @id) ->
    @names = []
    @ownMethods = {}
    @data = {}
    @ownData = {}
    @parents = []

  ancestors: ->
    anc = [this]
    for p in parents
      anc.push a for a in p.ancestors() when a not in anc
    return anc

  addParent: (parent) ->
    @parents.push parent
    @data[parent.id] = {}

    for a in ancestors
      @data[a.id] ?= {}

      for own p of a.data
        @data[a.id][p] ?= 0

  setMethod: (name, code) ->
    @ownMethods[name] = code

  setData: (parent, name, value) ->
    @data[parent.id][name] = value

  getData: (parent, name) ->
    @data[parent.id][name]

  getMethod: (name) ->
    for a in @ancestors
      return a[name] if a[name]

    return false
