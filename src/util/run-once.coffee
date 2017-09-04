alreadyRun = new Map

module.exports =
  runOnce: (fn) ->
    if alreadyRun.has fn
      return alreadyRun.get fn

    alreadyRun.put fn, fn()
