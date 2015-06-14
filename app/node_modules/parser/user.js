var UserParser = module.exports = function makeUserParser(session, db) {
  var next = db.user.commandHandler;

  session.prompt = '\n> ';

  return function (line) {
    var idx, cmd = line;

    if (idx = line.indexOf(' ')) {
      cmd = line.slice(0, idx);
      line = line.slice(idx + 1);
    }

    try {
      next = next(cmd, line) || next;
    } catch (e) {
      console.log(e);
      session.writeLine("Something went wrong:");
      session.log(e);
    }
  };
}
    
