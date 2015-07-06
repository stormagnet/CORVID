class Command
  constructor: (@pattern, @intent) ->

  match: (input) ->
    return 0 unless input

    words = input.split /\s+/
    cmd = words[0]
    prefix = @pattern.slice(0, cmd.length)

    if cmd is prefix
      return cmd.length

module.exports = Command
