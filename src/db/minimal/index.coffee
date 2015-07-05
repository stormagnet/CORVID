fs = require 'fs'

module.exports = (db, next) ->
  fs.readDir here, (e, files) ->
    throw e if e

    files.sort (a, b) ->
      for o in ['sys', 'root', 'user']
        return -1 if a is "#{o}.coffee"
        return  1 if b is "#{o}.coffee"

      a < b

    (require file)(db) for file in files when not file is 'index.coffee'
    next()
