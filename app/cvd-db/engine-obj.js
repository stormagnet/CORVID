// Wrapper for objects as seen by engines.

module.exports = function EngineObject (db, name, id) {
  if (!(this isinstanceof EngineObject))
    return new EngineObject(db, name, id);

  // for db.lookup(name), db.get(id), etc
  this.db = db;

  // Actual code. Name anticipates method cache (sigh)
  this.ownMethods = {};

  // Instance data
  this.data = {};
};

EngineObject.prototype = {
  send: function (msg, args) { return this.methods[msg].apply(this, args) },

  get: function (context, name) { return this.data[context][name] },

  set: function (context, name, value) { this.data[context][name] = value; return this },

  setMethod: function (name, fn) { this.ownMethods[name] = fn },

  compile: function (name, argNames, code) { this.setMethod(name, wrapMethod(code, argNames)) },
};

function wrapMethod (code, argNames) {
  var fullCode = header(argNames) + code + footer;

  return eval(fullCode);
}
