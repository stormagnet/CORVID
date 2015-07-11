should = require 'should'
LineParser = require '../src/line-parser.coffee'

describe 'LineParser', ->
  it 'should buffer incomplete lines', ->
    lines = []

    parser = new LineParser (l) ->
      lines.push l

    parser.data 'partial line'

    lines.length.should.equal 0

  it 'should pass complete lines to a consumer', ->
    lines = []

    parser = new LineParser (l) ->
      lines.push l

    parser.data 'beginning of line '
    parser.data '| end of line\n'

    lines.length.should.equal 1

  it 'should buffer excess data beyond ends of all lines', ->
    lines = []

    parser = new LineParser (l) ->
      lines.push l

    parser.data 'line1\nline2\nline3'

    lines.length.should.equal 2
    console.log JSON.stringify parser
    parser.buffer.length.should.equal 5

 
