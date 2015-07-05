Command = require '../src/command.coffee'
should = require 'should'

describe 'Command', ->
  describe '#match', ->
    cmd = new Command
      pattern: 'some-command'
      intent: true
    it 'should return something false on failed match', ->
      should not cmd.match 'wrong'
    it 'should return something true on partial match', ->
      should     cmd.match 'some'
