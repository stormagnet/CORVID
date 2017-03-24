app = require './server/server'

coreTree =
  euclidic:
    engine: ->
    entity:
      actor: ->
      group: ->
    relation:
      instanceOf: ->
      subsetOf: ->
      has: ->
      does: ->
    change:
      manifest: ->
      associate: ->
      morph: ->
      dissociate: ->
      destroy: ->
    dimension: ->

loadTree = (src, dest) ->
  todo = []

  for k, v of src
    console.log k

    app.models.Referent.findOrCreate name: k
      .then (ref) ->
        dest[k] = ref

        if 'function' is typeof v
          todo.push v
        else
          loadTree v, ref

  todo.forEach (item) -> item()

core = {}

loadTree coreTree, core

console.log "created core"

relate = (subj, rel, obj) ->
  subj = app.models.Referent.findOrCreate name: subj
  rel  = app.models.Referent.findOrCreate name: rel
  obj  = app.models.Referent.findOrCreate name: obj

  app.models.Relation.findOrCreate
    subjectId:      subj.id
    relationshipId: rel.id
    objectId:       obj.id

relations = """
  instanceOf  instanceOf  relation
  relation    instanceOf  euclidic
  engine      instanceOf  euclidic
  subsetOf    instanceOf  relation
  entity      instanceOf  euclidic
  actor       instanceOf  entity
  group       instanceOf  entity
"""

relate rel.trim().split ' ' for rel in relations.split '\n'

console.log "created relations"
