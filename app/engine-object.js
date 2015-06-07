module.exports = EngineObject;

function EngineObject(objectDb, name) {
  if (!(this instanceof EngineObject))
    return new EngineObject(name);

  this.name = name;
}

EngineObject.prototype = {
  //create: 
};
