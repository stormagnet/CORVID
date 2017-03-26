# Promise serializer
#
# Array::last = -> @[-1..][0]
#
# aStep = serializePromises fn
# 
# aStep args...
#   calls fn args...
#
# aStep el for el in list
# aStep.chain
#   .then (result) -> console.log "Chain finished"
#   .catch   (err) -> console.log "Chain failed:", err
#   .results (list) -> result from each step

_serializePromises = (fn, stopOnError = false) ->
  chain = Promise.resolve()
  results = []
  errors  = []
  stopped = false

  aStep = (args...) ->
    return aStep.chain if stopped

    aStep.chain =
      aStep
        .chain
        .then -> fn args...
        .then (result) ->
          aStep.results.push result
          aStep.errors.push undefined
        .catch (err) ->
          aStep.results.push undefined
          aStep.errors.push err
          stopped = stopOnError

  Object.assign aStep, {chain, results, errors, stopped}
  aStep

serialize       = (fn) -> _serializePromises fn, true
serializeNoStop = (fn) -> _serializePromises fn, false

module.exports = {
  serialize
  serializeNoStop
}
