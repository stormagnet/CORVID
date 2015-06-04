module.exports = CORVIDSession;

function CORVIDSession(stream, parserFactory) {
  if (!(this instanceof CORVIDSession)) {
    return new CORVIDSession(stream, parser);

  var newline = '\n';

  stream.on('data', this.data);

  var parser;
}

CORVIDSession.prototype = {
  write: function (d) {
    stream.write(d);
  },

  writeLine: function (l) {
    stream.write(l + this.newline);
  },

  writeLines: function (ll) {
    ll.forEach(writeLine);
  },

  data: function (d) {
    this.parser(d);
  },

  connected: function () {
    this.writeLines("", "Welcome to CORVID!", "");
    parser = parserFactory(this, stream);
  }
};

