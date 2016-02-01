/*

No persistence or access control for now.

"Why not just index the objects by number?"

Because then you couldn't replace something by renaming the old one.

On the other hand... we can replace numbered objects by renumbering them...
More thought needed here.

"Why are you preserving so much of the ColdMUD semantics?"

_"I have no idea..."_

*/

var EngineObject = require('engine-obj');

var ObjectDB = module.exports = function (worldGen, path) {
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

  this.initWorld(path, worldGen);
}

ObjectDB.prototype = {
  initWorld: function (path, worldGen) {
  },

  get: function (id) { return this.db[id] },

  lookup: function (name) {
    if (!this.names[name])
      throw "Object name not found";

    return this.names[name] 
  },

  create: function () {
    var id = this.db.length;
    var o = new EngineObject(this, id);

    this.db.push(o);

    return o;
  },

  destroy: function (id) {
    var o = this.db[id], names;

    if (o && o.names) {
      o.names.forEach(function (name) { this.delName(name) });

      // Give the object a chance to clean itself up.
      try {
        o.sendMessage('dbDestroy');
      } catch (e) {
        console.log("Error notifying object of destruction: \n", e);
      }
    }

    this.db[id] = undefined;
  },

  addName: function (o, name) {
    if (this.names[name])
      throw "Name already in use";

    this.names[name] = o;
  },

  delName: function (name) {
    if (!this.names[name])
      throw "Name not found";

    this.names[name] = undefined;
  },
};

function initMinimal (db) {
  require('minimal-db')(db);
};
