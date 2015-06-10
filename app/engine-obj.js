// Wrapper for objects as seen by engines.

module.exports = function EngineObject (db, id) {
  if (!(this isinstanceof EngineObject))
    return new EngineObject(db, id);

  // for db.lookup(name), db.get(id), etc
  this.db = db;
  this.names = [];
  this.id = id;

  // Actual code. Name anticipates method cache (sigh)
  this.ownMethods = {};

  // Instance data
  this.data = {};

  // Yes, I know, multiple inheritance is 'dead'. Whatever. Pplplpltttt!
  this.parents = [];
};

EngineObject.prototype = {
  send: function (msg, vargs) {
    var method = this.lookupMethod(msg), 
        args = Array.prototype.slice.call(arguments).slice(1);

    return method.apply(this, args);
  },

  getVar: function (context, name) {
    return this.data[context][name];
  },

  setVar: function (context, name, value) {
    this.data[context][name] = value;

    return this;
  },

  lookupMethod: function (msg) {
    var p, m;

    if (m = this.ownMethods[msg])
      return m;

    for (p = 0; p < this.parents.length; p++) {
      try {
        if (m = this.parents[p].lookupMethod(msg))
          return m;
      }
    }

    throw "Method not found";
  },

  setMethod: function (methodName, fn) {
    this.ownMethods[methodName] = fn;
  },

  compile: function (methodName, argNames, code) {
    this.setMethod(methodName, wrapMethod(code, argNames));
  },
};

/*

To compile 'arg x, y; return this[x]() + this[y]()', wrap it like...

  return (function () {
    return function (x, y) {
      // the code goes here
    }
  })();

*/

function header(argNames) {
  var argList = argNames.join(", ");

  return "return (function () { return function (" + argList + ") {";
}

var footer = "}})();";

function wrapMethod (code, argNames) {
  var fullCode = header(argNames) + code + footer;

  return eval(fullCode);
}
