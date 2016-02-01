telnet = require 'telnet'
Session = require 'session'

class Telnet extends telnet
  constructor:
    @sessions = []
    @port = null
    @server = telnet.createServer (conn) ->
      @sessions.push ses = new Session socket: conn

  listen: (@port) ->
    @server.listen @port
    

module.exports = Telnet
