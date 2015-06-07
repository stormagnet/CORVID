// No persistence for now
/*

"Why not just index the objects by number?"

Because then you couldn't replace something by renaming the old one.

*/

function ObjectDB(path, core) {
  if (!(this instanceof ObjectDB))
    return new ObjectDB(path);

  this.db = {};
  this.nameToId = {};
  this.nextid = 0;
  this.init(core);
}

module.exports = ObjectDB;

ObjectDB.prototype = {
  get: function (id) { return this.db[id] },

  create: function (name, data) {
    data.name = name;
    data.id = this.nextid;

    this.db[this.nextid] = data;
    this.names[name] = this.nextid;

    this.nextid++;
  },

  destroy: function (id) {
    this.db[id] = undefined;
  },

  init: function (core) {
  },
};

