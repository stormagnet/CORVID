http = require 'http'
querystring = require 'querystring'

module.exports = class CorvidEngineClient
  constructor: (opts = {}) ->
    @host = opts.host or 'localhost'
    @port = opts.port or '3000'
    @apiPath = opts.apiPath or 'api'

  send: (method, model, id, data, callback) ->
    options =
      hostname: @host
      port: @port
      method: method
      path: "/#{@apiPath}/#{model}"

    postData = querystring.stringify data

    if id
      options.path += '/' + id

    if method is 'GET' and postData
      options.path += '?' + postData

    if method is 'POST' or method is 'PUT'
      options.headers =
        'Content-Type': 'application/x-www-form-urlencoded'
        'Content-Length': postData.length

    request = http.request options, (result) =>
      fullResponse = ""
      result.setEncoding 'utf8'
      result.on 'data', (chunk) -> fullResponse += chunk
      result.on 'end', -> callback JSON.parse fullResponse

    request.on 'error', (e) ->
      console.log "\n\nclient.send error: ", e
      callback undefined, e

    if method is 'POST' or method is 'PUT'
      request.write postData

    request.end()

  create: (name, desc, cb) ->
    @send 'POST', 'locals', false, {name: name, description: desc}, cb

  list: (cb) ->
    @send 'GET', 'locals', false, false, cb

  delete: (id, cb) ->
    @send 'DELETE', 'locals', id, undefined, cb
