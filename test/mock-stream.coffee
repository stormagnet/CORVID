###

used by parser.coffee

###

Duplex = (require 'stream').Duplex

class MockStream extends Duplex
  input: []
  output: ''

  # source
  _read: ->
    if @input
      @push new Buffer @input.pop(), 'ascii'
    else
      @push null

  # sink
  _write: (chunk, encoding, callback) ->
    @output += chunk
    callback and callback()
