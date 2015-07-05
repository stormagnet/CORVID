class Command
  constructor: (@pattern) ->

  match: (@input) -> false

module.exports = Command
