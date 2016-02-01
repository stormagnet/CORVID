telnet = require 'telnet'
Session = require 'session'
Parsers = require 'parsers'

sessions = []

server = telnet.createServer (c) ->
  sessions.push new Session conn: c, parser: Parsers.login


  
