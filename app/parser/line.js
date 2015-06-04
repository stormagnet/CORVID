module.exports = function makeLineParser(next) {
  var buffer = '';

  return function (data) {
    var idx, line;
    var newLine = '\n';

    data = buffer + data;

    while (idx = data.indexOf(newLine)) {
      line = data.slice(0, idx);
      data = data.slice(idx + newLine.length);

      next = next(line) || next;
    }

    buffer = data;
  }
};
