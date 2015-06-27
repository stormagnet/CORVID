/* 

Abstract adapter class for various session types

Connets stream -> parser -> user -> outputFilter -> stream, where 'user' refers
to the object in the engine which holds the engine owner's info

*/

var Session = module.exports = function(stream, parser, outputFilter, user) {
  if (!(this instanceof Session))
    return new Session(stream, parser, outputFilter, user);

  this.user;
  this.stream = stream;
  this.parser = parser(stream, user);
  this.outputFilter = outputFilter(stream, user);
}

Session.prototype = {
  write: function (d) {
    this.stream.write(d);
  },

  writeLine: function (l) {
    this.write(l + this.newline);
  },

  writeLines: function (ll) {
    var lines = ll;

    if (typeof ll === 'string')
      lines = Array.prototype.slice.apply(arguments);

    this.writeLine(lines.join(this.newLine));
  },

  data: function (d) {
    this.parser(d);
  },

  connected: function () {
    this.writeLines("", "Welcome to !", "");
    this.parser = this.parserFactory(this);
    this.stream.on('data', this.data);
  }
};

  initStream: function () {
    // Currently assumes telnet socket. Should be made more flexible.
    var socket = this.stream;

    socket.do.transmit_binary();
    socket.do.window_size();
    socket.on('window_size', this.resize);
  },
  
  resize: function (e) {
    if (e.command == 'sb') {
      this.width = e.width;
      this.height = e.height;
    }
  },


