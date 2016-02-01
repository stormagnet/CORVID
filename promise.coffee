ctrl =
  then: {}

required = {}
installed = {}

attemptLoad = (name) ->
  new Promise (resolve, reject) ->
    attemptRequire name
      .catch (err) ->
        attemptInstall name
          .then (ret) ->
            attemptRequire name
      .then resolve
      .catch reject
 
attemptRequire = (name) ->
  if ctrl.require
    throw new Error 'looping?'

  if installed[name]
    return new Promise.resolve installed[name]

  new Promise (resolve, reject) ->
    ctrl.require =
      resolve: (ret) ->
        console.log "Resolving require with #{ret}"
        delete ctrl.require
        resolve ret
      reject: (reason) ->
        console.log "Rejecting require with #{reason}"
        delete ctrl.require
        reject reason

attemptInstall = (name) ->
  if ctrl.install
    throw new Error 'looping?'

  new Promise (resolve, reject) ->
    ctrl.install =
      resolve: (ret) ->
        console.log "Resolving install with #{ret}"
        delete ctrl.install
        resolve ret
      reject: (reason) ->
        console.log "Rejecting install with #{reason}"
        delete ctrl.install
        reject reason

load = (name) ->
  attemptLoad name
    .then (yay) -> console.log "Loaded #{name}: #{yay}"
    .catch (nay) -> console.og "Abort #{name}: #{nay}"

thenable = (whenIgetMyNextBreak) ->
  then: (cb) ->
    ctrl.then[whenIgetMyNextBreak] = (a...) ->
      cb a...

module.exports =
  ctrl: ctrl
  load: load
  thenable: thenable
