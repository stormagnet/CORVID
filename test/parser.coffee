should = require 'should'
LineParser = require '../src/line-parser.coffee'

describe 'StreamInputAdapter', ->
  it 'buffer incomplete lines', ->
    lines = []

    parser = new LineParser (l) ->
      lines.push l

    parser.data 'partial line'

    l.length.should.equal 0
