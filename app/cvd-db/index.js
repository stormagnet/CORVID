/*

No persistence or access control for now.

"Why not just index the objects by number?"

Because then you couldn't replace something by renaming the old one.

"Why are you preserving so much of the ColdMUD semantics?"

_"I have no idea..."_

*/

module.exports = function ObjectDB(worldGen, path) {
  if (!(this instanceof ObjectDB))
    return new ObjectDB(worldGen, path);

  if (!path) {
    path = worldGen;
    worldGen = undefined;
  }

  // EngineID -> EngineObject
  this.db = [];

  // lookup by name
  this.names = {};

  // Bootstrapping framework
  initMinimal(this);

  // this.initWorld(path, worldGen)
}

ObjectDB.prototype = {
  get: function (id) { return this.db[id] },

  lookup: function (name) { return this.names[name] },

  create: function (name) {
    var id = this.db.length;
    var o = new EngineObject (this, name, id);

    this.db.push(o);

    return o;
  },

  destroy: function (id) {
    // Give the object a chance to clean itself up.
    try { this.db[id].sendMessage('dbDestroy'); }

    // Deleting hash elements is contra-indicated for performance reasons.
    this.db[id] = undefined;
  },
};

// Private functions below

function initMinimal (db) {
  ['sys', 'root', 'user'].forEach(function (name) {
    require('engine/' + name)(db);
  });
};
