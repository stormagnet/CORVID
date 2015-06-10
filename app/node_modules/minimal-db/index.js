var fs = require('fs');

module.exports = function addMinimalDBObjects(db) {
  ['sys', 'root', 'wiz'].forEach(function (name) {
    var o = db.create(name);
    require(f)(o);
  });
};
