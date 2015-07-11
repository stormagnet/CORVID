should = require 'should'
Command = require 'command'

lastAction = null

actor = (action) ->
  lastAction = action

class OurCmd extends Command
  name: 'test'

  pattern: 'test '

  help:
    usage: 'test <whatever>'
    description:
      """
        Description text
      """

  extractParams: (input) ->
    words = input.split /\s+/
    words[1..]

cmd = new OurCmd actor

module.exports =
  'Command':
    'has a name': ->
      should(cmd.name).be.ok()
    '...which is a string': ->
      (typeof cmd.name).should.equal 'string'
    '#do invokes an actor': ->
      cmd.do 'test param'
      should(lastAction).be.ok()
      lastAction.action.should.equal 'test'
      lastAction.parameters.should.eql ['param']
    '#match returns':
      'false for empty input': ->
        should(cmd.match '').not.be.ok()
      'false for non-match': ->
        should(cmd.match 'wrong').not.be.ok()
      'true for partial match': ->
        should(cmd.match 'te').be.ok()
      'true for full match': ->
        should(cmd.match 'test').be.ok()
    'has help': ->
      should(cmd.help).be.ok()
