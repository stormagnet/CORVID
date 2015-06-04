module.exports = makeUserParser;

function makeUserParser(session, next, commands) {
  session.prompt = '\n> ';

  next = next || session.user.doCommand;

  return function (line) {
    var idx = line.indexOf(' ');
    var cmd = line;
    
    if (idx) {
      cmd = line.slice(0, idx);
      line = line.slice(idx + 1);
    }

    if (commands[cmd]) {
      next = next(commands[cmd], line) || next;
    }
  };
}
    
