should = require 'should'
Server = require 'server'
net = require 'net'

myServer = null
myClient = null

TEST_PORT = 3666

module.exports = {}
not_exported =
  'Server':
    'has a telnet property': ->
      Server.should.have.ownProperty 'telnet'
    '...which is a function': ->
      (typeof Server.telnet).should.equal 'function'

  'Server.telnet':
    before: (done) ->
      myServer = Server.telnet.create
          onConnect: (socket) ->
      myServer.listen TEST_PORT
      myServer.on 'listening', -> done()

    after: (done) ->
      myClient.end ->
        myServer.close -> done()

    "should be listening on port #{TEST_PORT}":
      myClient = net.connect port: TEST_PORT, (done) -> done()
