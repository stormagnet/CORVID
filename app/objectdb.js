<<<<<<< HEAD
// No persistence for now
/*
=======
// No persistence or access control for now.
>>>>>>> af95a11cbefaafd07fbf674a22ca739d0e388d7a

"Why not just index the objects by number?"

Because then you couldn't replace something by renaming the old one.

*/

function ObjectDB(path, core) {
  if (!(this instanceof ObjectDB))
    return new ObjectDB(path);

  this.db = {};
<<<<<<< HEAD
  this.nameToId = {};
  this.nextid = 0;
  this.init(core);
=======
  this.maxid = 0;
  this.initMinimal();
  // this.loadCore(path)
>>>>>>> af95a11cbefaafd07fbf674a22ca739d0e388d7a
}

module.exports = ObjectDB;

ObjectDB.prototype = {
  initMinimal: function () {
    createSys(this);
    createRoot(this);
    createWiz(this);
  },


  get: function (id) { return this.db[id] },

<<<<<<< HEAD
  create: function (name, data) {
    data.name = name;
    data.id = this.nextid;

    this.db[this.nextid] = data;
    this.names[name] = this.nextid;

    this.nextid++;
=======
  create: function (name) {
    this.maxid++;
    return this.db[this.maxid] = new CORVIDObject ({
        name: name,
        id: this.maxid,
        data: {},
        methods: {},
      });
>>>>>>> af95a11cbefaafd07fbf674a22ca739d0e388d7a
  },

  destroy: function (id) {
    // Give the object a chance to clean itself up.
    try { this.db[id].sendMessage('dbDestroy'); }

    // Deleting hash elements is contra-indicated for performance reasons.
    this.db[id] = undefined;
  },

  init: function (core) {
  },
};

<<<<<<< HEAD
=======
// Private functions below

function createSys(db) {
  var sys = db.create('sys');
  sys.
};

funciton createRoot(db) {
};

funciton createWiz(db) {
};
>>>>>>> af95a11cbefaafd07fbf674a22ca739d0e388d7a
