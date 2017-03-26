module.exports = ({app, waitFor, core, makeRef, relate}) ->
  name = (require 'path').basename __filename
  name[0] = name[0].toUpperCase()
  makeRef name
  $ = core
