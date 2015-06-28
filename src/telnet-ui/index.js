/*

Telnet interface to (at least) server level, if not core, system, setting and world. But just server for now.

Usage:

  var telnetUi = require('telnet-ui');
  var commandInterpreter = ...;

  var uiService = telnetUi.create(commandInterpreter).listen(port);

*/

var telnet = require('telnet');
var servers = [];

var TelnetService = module.exports = function(sessionFactory) {
  if (!(this instanceof TelnetService))
    return new TelnetService(sessionFactory);

  var that = this;

  this.sessions = [];
  this.sessionFactory = sessionFactory;
  this.server = telnet.createServer(function createServer(socket) {
    that.newConnection(socket);
  });

  servers.push(this.server);
}

TelnetService.prototype = {
  listen: function (port) {
    this.server.listen(port);
  },

  newConnection: function (socket) {
    var session = this.sessionFactory(socket);

    session.connected();

    this.sessions.push(session);
  },

  wall: function (msg) {
    this.sessions.forEach(function (s) { s.writeLines(msg) })
  },
};
