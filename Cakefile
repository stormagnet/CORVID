###

Specific actions defined in build/actions/

###

runOnce = (name, fn) -> return runOnce.alreadyRan[name] ?= fn()
runOnce.alreadyRan = {}

fs   = require 'fs'
path = require 'path'

actionDir = path.resolve __dirname, 'build', 'actions'

for dir in ['lib', 'src']
  module.paths.push path.resolve __dirname, dir

wrappedRequire = (requested) ->
  require requested

# The meat: try to load everything in 'build/actions' as an action

fs.readDir actionDir, (err, entries) ->
  for entry in entries when entry.match /^[^.]/
    fullPath = path.resolve actionDir, entry
    [parts..., ext] = entry.split '.'

    parts.push ext unless parts.length

    actionName = parts.join '.'

    try
      (require fullPath) {
          task, option
          invoke:  wrappedInvoke
          after:   makeAfter actionName
          require: wrappedRequire
        }
    catch e
      console.warn "Caught an error trying to require #{fullPath}:\n#{e}"

