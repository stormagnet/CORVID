module.exports = function (o) {
  var methods = {
  };

  Object.getOwnPropertyNames(methods).forEach(function (methodName) {
    o.setMethod(methodName, methods[methodName]);
  });
};
