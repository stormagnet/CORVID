stream = require 'stream'

class MockSocket extends stream.Duplex
  @mockInput: ''
  @mockOutput: ''

  @_read: -> ((ret, @mockInput) = (@mockInput, ''))[0]

  @_write: (chunk, encoding, callback) ->
    @mockOuput += chunk
    callback and callback()

module.exports = MockSocket
