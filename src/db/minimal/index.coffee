fs = require 'fs'
path = require 'path'

loader = (db, next) ->
  here = path.dirname module.filename
  console.log fs.readdir

  fs.readdir here, (e, files) ->
    files.sort (a, b) ->
      for o in ['sys', 'root', 'wiz']
        return -1 if a is "#{o}.coffee"
        return  1 if b is "#{o}.coffee"

      a < b

    for file in files when not file is 'index.coffee'
      (require file)(db)

    next()

module.exports = loader
