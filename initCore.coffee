app = require './server/server'

{core, makeRef, relate} = require './lib/core-builder'

depMan = new (require './lib/dependency-manager') 'loading', 'finished'

real = { makeRef, relate }
chain = Promise.resolve()

nameOf = (o) -> if 'string' is typeof o then o else o.name

relate = (subject, relation, object) ->
  relation = nameOf relation
  subject  = nameOf subject
  object   = nameOf object

  waitFor null, 'loading', 'Relation', subject, relation, object, ->
    real.relate core[subject], core[relation], core[object]

loadReferent = (path) ->
  chain.then ->
    name = waiting = false

    waitFor = (name, stage, deps..., andThen) ->
      waiting = true
      depMan.waitFor name, stage, deps, andThen

    makeRef = (refName) ->
      real.MakeRef refName
        .then (created) ->
          name = refName
          created

    Promise.resolve require(path) {app, core, waitFor, makeRef, relate}
      .then (created) ->
        if name and not waiting
          depMan.markDone name


(require './core') {loadReferent, app, makeRef, core, relate}

chain
  .then -> depMan.tryToFinish()
  .catch (e) -> console.log "Error while loading core:", e

console.log "created core"
