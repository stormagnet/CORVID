module.exports = function makeLoginParser(session, userdb) {
  var expectPassword = false, nameEntered;
  session.prompt = 'username: ';

  return function (line) {
    var user, pass;

    if (expectPassword) {
      pass = line;
      user = userdb.getUser(nameEntered, line);
      if (user) {
        return user.parserFactory(session);
      } else {
        session.writeln('Incorrect user name or password.');
        session.echoOn();
        session.prompt = 'username: ';
      }
    } else {
      nameEntered = line;
      session.echoOff();
      session.prompt = 'password: ';
    }
  };
};
