/*

  Proxy for local or remote EngineObject.

*/

module.exports = function CoreObject (id, engine) {
  if (!(this isinstanceof CoreObject))
    return new CoreObject();

  if (Object.hasOwnProperty(engine, ''))
    return new LocalObject(id);

  this.id = id;
  this.engine = engine;
};

CoreObject.prototype = {
};

function LocalObject(id) {
  this.o = 
