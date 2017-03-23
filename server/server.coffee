loopback = require 'loopback'
boot = require 'loopback-boot'

app = module.exports = loopback()

app.start = ->
  app.listen ->
    app.emit 'started'
    baseUrl =
      app
        .get 'url'
        .replace /\/$/, ''
    console.log "Web server listening at: #{baseUrl}"
    if app.get 'loopback-component-explorer'
      explorerPath = app.get('loopback-component-explorer').mountPath
      console.log "Browse your REST API at #{baseUrl}#{explorerPath}"

boot app, __dirname, (err) ->
  throw err if err

  app.start() if require.main is module

