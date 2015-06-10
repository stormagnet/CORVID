module.exports = function (o) {
  var methods = {
    names: function () {
      return o.names;
    },

    addName: function (newName) {
      return db.addName(o, newName);
    },

    delName: function (name) {
      return db.delObjName(name);
    },
  };

  Object.getOwnPropertyNames(methods).forEach(function (methodName) {
    o.setMethod(methodName, methods[methodName]);
  });
};
