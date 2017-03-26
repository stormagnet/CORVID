app = require './server/server'

{core, makeRef, relate} = require './lib/core-builder'

depMan = new (require './lib/dependency-manager') 'loading', 'finished'

real = { makeRef, relate }

nameOf = (o) -> if 'string' is typeof o then o else o.name

relate = (subject, relation, object) ->
  relation = nameOf relation
  subject  = nameOf subject
  object   = nameOf object

  waitFor null, 'loading', 'Relation', subject, relation, object, ->
    real.relate core[subject], core[relation], core[object]

{serialize, serializeNoStop } = require './lib/serialize.coffee'

loadReferent = serialize (path) ->
  name = waiting = false

  waitFor = (name, stage, deps..., andThen) ->
    waiting = true
    console.log "#{name}@#{stage} is waiting for #{deps.join ", "}"
    depMan.waitFor name, stage, deps, andThen

  makeRef = (refName) ->
    name = refName
    real.MakeRef refName

  Promise.resolve require(path) {app, core, waitFor, makeRef, relate}
    .then (created) ->
      if name and not waiting
        depMan.markDone name

(require './core') {loadReferent, app, core}

loadReferent.chain
  .then -> depMan.tryToFinish()
  .catch (e) -> console.log "Error while loading core:", e
  .then -> console.log "created core"
