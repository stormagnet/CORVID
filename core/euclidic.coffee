module.exports = ({app, waitFor, core, makeRef, relate}) ->
  name = (require 'path').baseName __filename, '.coffee'
  name[0] = name[0].toUpperCase()
  makeRef name
  $ = core
