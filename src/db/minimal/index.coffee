fs = require 'fs'
path = require 'path'

source = /\.coffee$/

loader = (db) ->
  here = path.dirname module.filename

  files = fs.readdirSync here

  files = files.filter (f) ->
    return false unless f.match source
    return false if f is 'index.coffee'
    true

  files.sort (a, b) ->
    for o in ['sys', 'root', 'wiz']
      return -1 if a is "#{o}.coffee"
      return  1 if b is "#{o}.coffee"
    a < b

  for file in files
    fullpath = path.join here, file
    (require fullpath) db

module.exports = loader
