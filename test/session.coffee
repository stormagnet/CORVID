should = require 'should'
Session = require 'session'

stream = require 'stream'

class Socket extends stream.Duplex
  mockInput: ''
  mockOutput: ''

  _read: -> ((ret, @mockInput) = (@mockInput, ''))[0]

  _write: (chunk, encoding, callback) ->
    @mockOuput += chunk
    callback and callback()

class Parser
  received: []

  responses: []

  data: (d) ->
    @received.push d
    return responses.pop if responses

mockSocket = new Socket
mockParser = new Parser

mySession = new Session conn: mockSocket

module.exports =
  'Session':
    'passes input to a parser':


