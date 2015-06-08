// No persistence or access control for now.

function ObjectDB(path) {
  if (!(this instanceof ObjectDB))
    return new ObjectDB(path);

  this.db = {};
  this.maxid = 0;
  this.initMinimal();
  // this.loadCore(path)
}

module.exports = ObjectDB;

ObjectDB.prototype = {
  initMinimal: function () {
    createSys(this);
    createRoot(this);
    createWiz(this);
  },


  get: function (id) { return this.db[id] },

  create: function (name) {
    this.maxid++;
    return this.db[this.maxid] = new CORVIDObject ({
        name: name,
        id: this.maxid,
        data: {},
        methods: {},
      });
  },

  destroy: function (id) {
    // Give the object a chance to clean itself up.
    try { this.db[id].sendMessage('dbDestroy'); }

    // Deleting hash elements is contra-indicated for performance reasons.
    this.db[id] = undefined;
  }
};

// Private functions below

function createSys(db) {
  var sys = db.create('sys');
  sys.
};

funciton createRoot(db) {
};

funciton createWiz(db) {
};
