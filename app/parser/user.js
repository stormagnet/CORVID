module.exports = makeUserParser;

function makeUserParser(session, db) {
  var next = db.user.commandHandler;

  session.prompt = '\n> ';

  return function (line) {
    return (function () {
      var idx, cmd = line;

      if (idx = line.indexOf(' ')) {
        cmd = line.slice(0, idx);
        line = line.slice(idx + 1);
      }

      if (commands[cmd]) {
        next = next(commands[cmd], line) || next;
      } else {
        session.writeLine("Unknown command '{}'".replace('{}', cmd));
      }
    })();
  };
}
    
