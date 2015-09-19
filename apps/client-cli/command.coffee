###

A CommandMatcher implements .matchCommand(inputString) returning a MatchedCommand

A MatchedCommand implements .invoke()

###

class MatchedCommand extends Command
  constructor: (@fn, @inputStr, @cmdStr, @argStr) ->
    # XXX: Later we'll use this hook for logging, undo, whatever
    @invoke = ->
      @fn
        inputStr: @inputStr
        cmdStr: @cmdStr
        argStr: @argStr

  ###
  invoke: ->
    @fn this
  ###

class CommandMatcher
  constructor: (@dict = {}) ->

  add: (name, cmd) ->
    @dict[name] = cmd

  matchCommand: (inputStr) ->
    [leadingWhitespace, firstWord, whitespace, rest] = inputStr.match /^(\s*)(\S*)(\s*)?(.*)/

    if @dict[firstWord]
      return new MatchedCommand @dict[firstWord], inputStr, firstWord, rest

module.exports =
  CommandMatcher: CommandMatcher
  MatchedCommand: MatchedCommand
