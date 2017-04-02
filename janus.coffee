util = require 'util'

{Client} = require 'node-rest-client'

client = new Client

class RequestError extends Error
  constructor: (@response, message = @response.statusMessage, fileName, lineNumber) ->
    super message, fileName, lineNumber

config =
  host: 'localhost'
  port: 8182
  proto: 'http'

config.url = "#{config.proto}://#{config.host}:#{config.port}/"

request = (method, query) ->
  args =
    data: gremlin: query
    headers:
      "Content-Type": "application/json"

  {url} = config

  new Promise (resolve, reject) ->
    client[method] url, args, (data, response) ->
      switch response.statusCode
        when 200 then resolve data
        else          reject  new RequestError response

get = (path, data) ->
  global.requested = get: [path, data]
  request 'get', path, data
    .then (ret) -> ret.result.data

post = (path, data) ->
  global.posted = post: [path, data]
  request 'post', path, data
    .then (ret) -> ret.result.data

if false
  get()
    .catch (e) -> console.log e
    .then  (d) -> console.log d

p = (promise) ->
  promise
    .then  (d) -> console.log util.inspect global.d = d, colors: true
    .catch (e) -> console.log "error", (global.e = e).response?.statusMessage or util.inspect e, colors: true

englishList = (l, conjunction) ->
  [first..., last] = l

  (switch l.length
    when 0 then []
    when 1 then [l[0]]
    when 2 then [l[0], conjunction, last]
    else        [first.join(", "), conjunction, last]
  ).join " "

expectOneOf = (value, types...) ->
  if t = typeof value not in types
    throw new TypeError "Wanted one of #{englishList types, 'or'}, got #{t}"

expectString = (value...) ->
  value.forEach (v) ->
    if 'string' isnt t = typeof v
      throw new TypeError "Wanted string, got #{t}"

property = (key, value) -> util.format '.property(%j, %j)', key, value

has = (propName, propValue) -> util.format ".has('%j', '%j')"

lookup = (propName, propValue) -> ".V()" + has 'name', propValue

named = (name) -> lookup 'name', name

as = (alias) ->
  expectString alias
  util.format ".as(%j)", alias

create = (subjects) ->
  expectOneOf subjects, 'string', 'object'

  if 'string' is typeof subjects
    subjects = "#{subjects}": {}

  for type, instances of subjects
    for name, properties of instances
      q = util.format "g.addV(%j)", type

      properties.name = name

      for key, value of properties
        q += property key, value

      post q

connect = (a, dir, type, b, props) ->
  expectString a, b
  q = "g" + named(a) + as('a') + named(b)
  q += util.format ".addE(%j).%s('a')", type, dir

  if props
    for key, value of props
      q += property key, value

  post q

connectTo   = (a, type, b, props) -> connect a, 'to',   type, props
connectFrom = (a, type, b, props) -> connect a, 'from', type, props

list = (regex) ->
  select =
    if regex
      (v) -> v.properties.name.filter(({id, value}) -> value.match regex).length
    else
      -> true

  post "g.V()"
    .then (data) ->
      data.filter select

Object.assign global, module.exports =
  {
    Client, client, RequestError, config, request
    get, post, p
    create, connect, connectTo, connectFrom
    list
  }

