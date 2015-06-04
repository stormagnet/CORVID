// No persistence for now

function ObjectDB(path) {
  if (!(this instanceof ObjectDB))
    return new ObjectDB(path);

  this.db = {};
  this.maxid = 0;
}

module.exports = ObjectDB;

ObjectDB.prototype = {
  get: function (id) { return this.db[id] },

  create: function (name) {
    this.maxid++;
    this.db[this.maxid] = {
      name: name,
    };
  },

  destroy: function (id) {
    this.db[id] = undefined;
  }
};
