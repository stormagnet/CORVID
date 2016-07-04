objectKey = (id) -> "obj-#{id}"

e =
  NoSuchObject: (id) -> new Error "Object id '#{id}' is invalid"
  NotAnObject: (o) -> new Error "Value '#{o}' is not an object"

getObject = (id) ->
  if not oStr = localStorage.getItem objectKey id
    throw e.NoSuchObject id

  JSON.parse oStr

setObject = (id, data) ->
  if 'object' isnt typeof data
    throw e.NotAnObject data

  if 'number' isnt typeof id
    throw e.NoSuchObject id

  localStorage.setItem objectKey(id), JSON.stringify data

methodKey = (objId, methodName, version) ->
  if 'number' isnt typeof version
    "method-#{objId}-#{methodName}"
  else
    "method-#{objId}-#{methodName}-#{version}"

getMethodVersions = (objId, methodName) ->
  versions = localStorage.getItem methodKey objId, methodName

addMethod = (objId, methodName, fn) ->
  existing = getMethodVersions objId, methodName

lookupMethod = (obj, methodName) ->
  
