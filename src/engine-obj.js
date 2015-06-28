// Wrapper for objects as seen by engines.

module.exports = EngineObject;

function EngineObject (db, id) {
  if (!(this instanceof EngineObject))
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

  // Core interface
  this.localProxy = undefined;

  this.context = new Context(this);
};

EngineObject.prototype = {
  query: function () {
    this.context.query.apply(this, arguments);
  },

  proxy: function () {},

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
      } catch (e) { }
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

function Context(entity) {
  this.entity = entity;

  this.relations = {
    all: [],

    byObserverId: {},
    bySubjectId: {},
    byObjectId: {},

    byDegreeFilter: function (filter) {},
    byContextFilter: function (filter) {},
  };
}

Context.prototype = {
  now: function () {},

  simpleQuery: function (constraints) {
    var candidates =
      ['observer', 'subject', 'object', 'relation'].find(function (aspect) {
        if (constraints[aspect]) {
          return this.queries[aspect](constraints);
        }
      });

    if (candidates) {
      return this.filter(candidates, constraints);
    }
  },
};
