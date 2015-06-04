/*

Telnet interface to (at least) server level, if not core, system, setting and world. But just server for now.

Usage:

  var telnetUi = require('telnet-ui');
  var commandInterpreter = ...;

  var uiService = telnetUi.create(commandInterpreter).listen(port);

*/

var telnet = require('telnet');
var clients = [];
var servers = [];

module.exports = {
  create: function (interp) {
      var server = telnet.createServer(function (newConn) {
        var client = {
          socket: newConn,
        };
        client.prototype = interp;

        newConn.do.transmit_binary();
        newConn.do.window_size();
        newConn.on('window_size', function (e) {
          if (e.command == 'sb') {
            client.resize(e.width, e.height);
          }
        });
        newConn.on('data', client.data);
        client.connected();
      });

      servers.push(server);

      return server;
    },
};


