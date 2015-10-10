module.exports = ({readline, Corvid}) ->
  class CorvidCLI
    constructor: ({@inStream, @outStream, @db, @cmds, throbber}) ->
      @debugSettings = 10
      @busy = false
      if throbber
        @throbber =
          spinner: throbber[0]
          interval: throbber[1]
          idx: 0

    send: (text) ->
      @outStream.write text + '\n'

    nextLine: ->
      new Promise (resolve, reject) ->
        @captureNextLine = (line) ->
          @captureNextLine = false
          resolve line

    start: ({greeting}) ->
      @send greeting if greeting
      @setupTerminal()
      @setLineMode @startingLineMode()

    animatePrompt: ->
      mode = @lineMode
      idx = 0
      cli = this
      rePrompt = ->
        cli.terminal.setPrompt cli.lineMode.prompt cli
        cli.terminal.prompt true
      @throbber.id = setInterval rePrompt, @throbber.interval

    setLineMode: (mode) ->
      @lineMode = mode

      @terminal.setPrompt mode.prompt this
      @animatePrompt() if @throbber
      @terminal.prompt()

    startingLineMode: ->
      parser: @doCmd.bind this
      name: 'CORVID 0.2'
      prompt: (cli) ->
        try
          mode = cli.lineMode
          name = mode.name
          spinner = cli.busy and cli.throbber and cli.throbber.spinner
          live = (spinner and spinner[cli.throbber.idx++ % spinner.length]) or ' '
          "#{name} #{live} > "
        catch
          "prompt error> "

    setupTerminal: () ->
      @terminal = readline.createInterface
        input: @inStream
        output: @outStream
      @terminal.on 'close', @shutdown
      @terminal.on 'line', (l) => @lineMode.parser l
      @send 'Terminal ready. Probably'

    matchFailure: (cmd) ->
      (args, l) ->
        process.stdout.write 'No can do, boss.\n'

    matchCommand: (cmd) ->
      if matched = @cmds[cmd]
        matched.bind @cmds
      else
        @matchFailure

    shutdown: -> process.exit()

    debug: (info) ->
      if @debugSettings
        console.log 'DEBUG: ', info...

    doCmd: (l) ->
      if match = l.match /^ *debug(.*)/
        if match.length > 1 and match[1]
          @send "Debug was #{@debugSettings}"
          @debugSettings = match[1].trim()
        else
          @send "Debug is #{@debugSettings}"
        return

      [cmd, args...] = l.trim().split ' '

      #try
      action = @matchCommand cmd
      action args, l
      #catch e
      #  @send e.toString()

      @terminal.prompt()

