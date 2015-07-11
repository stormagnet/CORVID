fs = require 'fs'
path = require 'path'

sourcePattern = /^[^.].*\.coffee$/

loader = (db) ->
  here = path.dirname module.filename

  files = fs.readdirSync path.join here, 'o'

  files.sort (a, b) ->
    for o in ['sys', 'root', 'wiz']
      return -1 if a is "#{o}.coffee"
      return  1 if b is "#{o}.coffee"
    a < b

  for file in files
    modulePath = path.join 'db', 'minimal', 'o', file
    (require modulePath) db

module.exports = loader
