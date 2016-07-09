ls = window.localStorage

e =
  NoSuchObject: (v) -> new Error "Object id '#{v}' is invalid"
  NotAnObject:  (v) -> new Error "Value '#{v}' is not an object"

objectKey = (id) -> "obj-#{id}"

methodKey = (objId, methodName, version) ->
  "method-#{objId}-#{methodName}" +
    if 'number' is typeof version
      "-#{version}"
    else
      ""

getObject = (id) ->
  if not oStr = ls.getItem objectKey id
    throw e.NoSuchObject id

  JSON.parse oStr

setObject = (id, data) ->
  if 'object' isnt typeof data
    throw e.NotAnObject data

  if 'number' isnt typeof id
    throw e.NoSuchObject id

  ls.setItem objectKey(id), JSON.stringify data

getMethodVersions = (objId, methodName) ->
  versions = ls.getItem methodKey objId, methodName
  
  if versions
    JSON.parse versions
  else
    {top: -1, vers: []}

setMethod = (objId, methodName, version, fn) ->
  localStorage.setItem methodKey(objId, methodName, version), fn.toString()
  
addMethod = (objId, methodName, fn) ->
  {top, vers} = getMethodVersions objId, methodName

  vers.push ++top
  saveMethod objId, methodName, top, fn

getMethod = (objId, methodName, version) ->
  if 'number'
    ...
  code = localStorage.getItem methodKey objId, methodName, version
  if 'string' isnt typeof

lookupMethod = (obj, methodName) ->
  

freeze = (water) ->
  ice =
    id: water.id()
    ctor: water.constructor
    proto: Object.getPrototypeOf water
    refs: {}
    functions: {}
    data: {}

  for k of Object.getOwnPropertyNames water
    info = Object.getOwnPropertyDescriptor water, k
    v = info.value

    switch typeof v
      when 'function' then
        info.value = info.value.toString()
        info.get ?= info.get.toString()
        info.set ?= info.set.toString()
        ice.functions[k] = info
      when 'object'   then ice.refs[k] = v.id()
      else                 ice.data[k] = v

  JSON.stringify ice

thaw = (iceJson) ->
  ice = JSON.parse iceJson
  water = Object.create ice.proto




