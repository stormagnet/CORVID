path                      = require 'path'
fs                        = require 'fs'

{ suite, test }           = require 'joe'

process.env.JOE_REPORTER ?= 'console'

module.paths.push path.resolve __dirname, '..', 'src'
module.paths.push path.resolve __dirname, '..', 'lib'

{ World }                 = require 'world'

suite 'CORVID World', (suite, test) ->
  suite '::constructor', (suite, test) ->
    test 'succeeds without args', ->

