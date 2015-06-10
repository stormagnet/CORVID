// Prompting parser

module.exports = function makePromptingParser(session, next) {
  var pstr = '\n> ', newParser;

  session.write(pstr);

  return function (line) {
    newParser = next(line);

    if (newParser) {
      return newParser;
    }

    session.write(pstr);
  };
}
