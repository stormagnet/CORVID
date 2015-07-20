should = require 'should'
CORVIDService = require 'service'
Telnet = CORVIDService.telnet
net = require 'net'

client = null
server = null
port = 3023
db = new CorvidDB console.log

module.exports =
  'Telnet':
    'an instance':
      before: (done) ->
        server = new Telnet
          port: 3023
          db: db
        server.on 'listening', done

      after: (done) ->
        client.end ->
          client = null
          server.close ->
            server = null
            done()

      'listens on a port': (done) ->
        client = net.connect {port: port}, done

      'creates sessions for clients': (done) ->
        server.on 'connect', ->
          server.sessions.should.be.ok()
          done()

      'data written to a session should be parsed': (done) ->
        
