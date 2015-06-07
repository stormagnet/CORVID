module.exports = function (path) { return new UserDB(path); };

var makeParser = function (session) {
  return require('parser/line')(session,
         require('parser/user')(session));
};

function UserDB(objectdb) {
  var db = objectdb;
  var users = {};
}

UserDB.prototype = {
  addUser: function (name, pass) {
    this.users[name] = {
      name: 'user',
      password: 'password',
      parserFactory: makeParser
    };
  },
};

UserDB.prototype.getUser = function (name, password) {
  if (users[name] && users[name].password === password) {
    return users[name];
  }

  return false;
}

UserDB.prototype.addUser = function (o) {
  function chk(s) { return typeof s === 'string' && s }

  if (!(chk(o.name) && chk(o.password))) {
    throw "Invalid username and password.";
  }

  users[o.name] = o;
  o.parser = o.parser || adminParser;
}

