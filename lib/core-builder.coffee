app = require '../server/server'

module.exports =
  core: core = {}

  makeRef: makeRef = (name) ->
    core[name] = app.models.Referent.findOrCreate {name}

  relate: (subj, rel, obj) ->
    subj = makeRef name: subj
    rel  = makeRef name: rel
    obj  = makeRef name: obj

    app.models.Relation.findOrCreate
      subjectId:      subj.id
      relationshipId: rel.id
      objectId:       obj.id


