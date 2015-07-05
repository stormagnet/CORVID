Command = require '../src/command.coffee'
should = require 'should'

describe 'Command', ->
  describe '#match', ->
    cmd = new Command 'some-command', -> true
    it 'should return something false on failed match', ->
      result = cmd.match 'wrong'
      should(result).not.be.ok()
    it 'should return something true on full match', ->
      result = cmd.match 'some-command'
      should(result).be.ok()
    it 'should return something true on partial match', ->
      result = cmd.match 's'
      should(result).be.ok()
