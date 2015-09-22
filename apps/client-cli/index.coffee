readline = require 'readline'
repl = require 'repl'
CorvidEngineClient = require './engine'

module.exports = class ShellClient
  constructor: ->
    @engine = new CorvidEngineClient
    @startReadLine @prompt, @lineHandler.bind this
    @bindCommands()

  bindCommands: ->
    for cmdName, cmd of @commands
      cmd.invoke = cmd.invoke.bind this

  prompt: 'CORVID> '

  setLineHandler: (@prompt, @lineHandler) ->
    @rl.on 'line', @lineHandler
    @rl.setPrompt @prompt
    @rl.prompt()

  makePrefixHandler: (prefix) ->
    prevHandler = [@prompt, @lineHandler]

    newHandler = (line) =>
      if line.length
        prevHandler[1] prefix + " " + line
      else
        @setLineHandler prevHandler...

    newHandler.name = "#{prevHandler.name}('#{prefix} ' + line)"

    return newHandler

  lineHandler: (line) ->
    matchResult = line.match /^(\s*)(\S+)(\s+)?(.*)/

    if matchResult is null
      if line.trim()
        @writeln "warning: parse failure for '#{line}'"
    else
      [matched, leadingWhitespace, cmdstr, ignoredWhitespace, argstr] = matchResult

      if @commands[cmdstr]
        try
          @commands[cmdstr].invoke matched, cmdstr, argstr
        catch e
          @showError e
      else
        @unknownCommand cmdstr, matched

    @rl.prompt()

  startReadLine: (prompt, handler) ->
    @rl = readline.createInterface
      input: process.stdin
      output: process.stdout
    @rl.on 'close', => @lineHandler 'exit'
    @setLineHandler prompt, handler

  write: (l) -> process.stdout.write l
  writeln: (l) -> @write l + '\n'
  writeLines: (lines...) -> @writeln lines.join '\n'

# Prepend prefix and insert prefix after newlines
  indent: (s, prefix = '  ') ->
    prefix + s
      .split '\n'
      .join '\n' + prefix

  commands:
    help:
      help: "You're soaking in it!"
      invoke: (input, cmdStr, argStr) ->
        if argStr
          return @write "There is no help for '#{argStr}'.\n ...yet.\n"

        cmdHelp = []

        for cmdStr, cmd of @commands
          helpText = switch typeof cmd.help
            when 'function' then cmd.help()
            when 'string' then cmdStr + ": " + cmd.help
            else cmdStr + " (no help available)"
          cmdHelp.push @indent helpText

        @writeLines "You are currently in the CORVID debug console.",
            ""
            "Available commands:"
            cmdHelp...

    mode:
      help: """
          Usage:
          
              mode prefix

          Prefixes following commands with 'prefix'. Canceled by a blank line.
          
          For example:

              CORVID> mode engine

              CORVID engine> connect example.com 1234
              CORVID engine> list name:euclid*
              CORVID engine>

              CORVID>

        """

      invoke: (input, cmdStr, argStr) ->
        if argStr
          pushMode "CORVID [#{modes.length + 1}] #{argStr}> ", @makePrefixHandler argStr
        else
          popMode()

    repl:
      help: "Drop into JavaScript console (good luck!)"
      invoke: (input, cmdStr, argStr) ->
        prevHandler = [@prompt, @lineHandler]

        @write "Switching to JavaScript REPL. Enter ^D to return to Corvid.\n\n"
        @setLineHandler 'js> ', ->

        repl.start 'js> '
          .on 'exit', =>
            @write "\n\nReturning from JavaScript REPL.\n"
            @startReadLine prevHandler...

    exit:
      help: "For when it's all just _too much_"
      invoke: (input, cmdStr, argStr) ->
        @rl.close()
        @writeln "\n\nIt's rough out there."
        process.exit 0

    engine:
      help: -> """
        Dispatch a request to the CORVID engine. Items prefixed with '!' have not
        been implmented yet.

          Basics:
              engine help
            ! engine help [query]
            ! engine config [name [:|=] [value]]
            ! engine install url
              engine connect [host [port]]

          Object tools:
              engine list [pattern]
            ! engine inspect targetPattern
            ! engine create [name]
            ! engine set target.prop value
            ! engine delete target[.prop]

          Relation tools:
            ! engine relate subject relation object [params]

          Tricks:
            ! engine alias from [to]

      """

      invoke: (input, cmdStr, argStr) ->
        if not argStr
          return popMode()

        [engineCmd, args...] = argStr.trim().split /\s+/

        if fn = @commands.engine[engineCmd]
          fn args, @resultReporter engineCmd, args.join " "
        else
          popMode()

      connect: (args, cb) ->
        engine = new CorvidEngineClient

      list: (pattern, cb) ->
        engine.list cb

  resultReporter: (cmd, args) ->
    (data) =>
      @writeLines "Results from your engine request: #{cmd} #{args}",
        JSON.stringify data

  unknownCommand: (cmdstr, line) ->
    @write """
        You entered '#{line}', but '#{cmdstr}' wasn't recognized as a command."
        Maybe try 'help'?"
      """

  showError: (e) ->
    @write """
        There was an error:
          #{e.stack}

      """
