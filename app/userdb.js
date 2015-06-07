module.exports = function (path) { return new UserDB(path); };

var makeParser = function (session) {
  return require('parser/line')(session,
         require('parser/user')(session));
};

function UserDB(path) {
  var path = path;
  var users = {};
  this.addUser('admin', 'admin');
}

UserDB.prototype = {
  addUser: function (userObject) {
    var name = userObject.name, password = userObject.password;

    this.users[name] = {
      name: name,
      password: password,
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

