readline = require 'readline'
repl = require 'repl'

handleLine = (line) ->
  matchResult = line.match /^(\s*)(\S+)(\s+)?(.*)/

  if matchResult is null
    if line
      writeln "warning: parse failure for #{line}"
  else
    [matched, leadingWhitespace, cmdstr, ignoredWhitespace, argstr] = matchResult

    if commands[cmdstr]
      try
        commands[cmdstr].invoke matched, cmdstr, argstr
      catch e
        showError e
    else
      unknownCommand cmdstr, matched

  rl.prompt()

startReadLine = ->
  rl = readline.createInterface
    input: process.stdin
    output: process.stdout
  rl.on 'close', commands.exit.invoke
  rl.setPrompt 'CORVID> '
  rl.prompt()
  rl.on 'line', handleLine
  rl

write = (l) -> process.stdout.write l
writeln = (l) -> write l + '\n'
writeLines = (lines...) -> writeln lines.join '\n'

# Prepend prefix and insert prefix after newlines
String.prototype.indent = (prefix = '  ') ->
  prefix + this
    .split '\n'
    .join '\n' + prefix

commands =
  help:
    help: "You're soaking in it!"
    invoke: (input, cmdStr, argStr) ->
      if argStr
        return write "There is no help for '#{argStr}'.\n ...yet.\n"

      cmdHelp = []

      for cmdStr, cmd of commands
        helpText = switch typeof cmd.help
          when 'function' then cmd.help()
          when 'string' then cmdStr + ": " + cmd.help
          else cmdStr + " (no help available)"
        cmdHelp.push helpText.indent()

      writeLines "You are currently in the CORVID debug console.",
          ""
          "Available commands:"
          cmdHelp...

  repl:
    help: "Drop into JavaScript console (good luck!)"
    invoke: (input, cmdStr, argStr) ->
      rl.setPrompt 'js> ' # XXX: ugly work-around
      write "Switching to JavaScript REPL. Enter ^D to return to Corvid.\n\n"
      rl.removeListener 'close', commands.exit.invoke
      rl.close()

      repl.start 'js> '
        .on 'exit', ->
          write "\n\nReturning from JavaScript REPL.\n"
          rl = startReadLine()

  exit:
    help: "For when it's all just _too much_"
    invoke: (input, cmdStr, argStr) ->
      rl.close()
      writeln 'Have a great day!'
      process.exit 0

  engine:
    help: """
      Dispatch a request to the CORVID engine (not yet implemented).

        engine help [query]
        engine list [pattern]
        engine inspect targetPattern
        engine create [name]
        engine set target.prop value
        engine delete target[.prop]

    """
    invoke: (input, cmdStr, argStr) ->
      [engineCmd, args] = argStr.trim().split /\s+/
      engine.send engineCmd, args, resultReporter engineCmd, argStr

resultReporter = (cmd, args) ->
  (err, data) ->
    writeLines "Results from your engine request: #{engineCmd} #{argStr}",
      "(...)"

unknownCommand = (cmdstr, line) ->
  write """
      You entered '#{line}', but '#{cmdstr}' wasn't recognized as a command."
      Maybe try 'help'?"
    """

showError = (e) ->
  write """
      There was an error:
        #{e.stack}

    """

rl = startReadLine()

