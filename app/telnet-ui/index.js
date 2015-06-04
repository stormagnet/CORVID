/*

Telnet interface to (at least) server level, if not core, system, setting and world. But just server for now.

Usage:

  var telnetUi = require('telnet-ui');
  var commandInterpreter = ...;

  var uiService = telnetUi.create(commandInterpreter).listen(port);

*/

var telnet = require('telnet');
var servers = [];

module.exports = function TelnetService(sessionFactory) {
  if (!(this instanceof TelnetService))
    return new TelnetService(sessionFactory);

  var sessions = [];

  var server = telnet.createServer(function (socket) {
    var session = sessionFactory(socket);

    socket.do.transmit_binary();
    socket.do.window_size();

    if (typeof session.window_size === 'function') {
      socket.on('window_size', function (e) {
        if (e.command == 'sb') {
          socket.emit('resize', e.width, e.height);
        }
      });
    }

    sessions.push(session);

    try {
      session.connected();
    } catch (e) {
      sessions.pop();
      throw e;
    }
  });

  servers.push(server);
}

TelnetService.prototype = {
  wall: function (msg) {
    sessions.forEach(function (s) { s.writeLines(msg) })
  },
};
