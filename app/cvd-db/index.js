/*

No persistence or access control for now.

"Why not just index the objects by number?"

Because then you couldn't replace something by renaming the old one.

"Why are you preserving so much of the ColdMUD semantics?"

_"I have no idea..."_

*/

function ObjectDB(path, core) {
  if (!(this instanceof ObjectDB))
    return new ObjectDB(path);

  // EngineID -> EngineObject
  this.db = {};

  // Number of last object added to DB
  this.maxid = -1;

  // Bootstrapping framework
  initMinimal(this);

  // this.initWorld(path, core)
}

module.exports = ObjectDB;

ObjectDB.prototype = {
  get: function (id) { return this.db[id] },

  create: function (name) {
    this.maxid++;
    return this.db[this.maxid] = new CVDObject ({
        name: name,
        id: this.maxid,
      });
  },

  destroy: function (id) {
    // Give the object a chance to clean itself up.
    try { this.db[id].sendMessage('dbDestroy'); }

    // Deleting hash elements is contra-indicated for performance reasons.
    this.db[id] = undefined;
  },

  init: function (path) {
    var worldGen;

    if (arguments.length > 1) {
      worldGen = path;
      path = arguments[1];
      genWorld(this, worldGen, path);
    } else {

    }
  },
};

// Private functions below

function initMinimal (db) {
  ['sys', 'root', 'user'].forEach(function (name) {
    require('engine/' + name)(db);
  });
};
