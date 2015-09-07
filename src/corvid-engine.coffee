CorvidSession = require 'corvid-session'

initCanon = -> {}

module.exports = class Corvid
  constructor: ->
    @canon = initCanon()

  session: -> new CorvidSession this

