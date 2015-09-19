readline = require('readline')
rl = readline.createInterface process.stdin, process.stdout

rl.setPrompt 'OHAI> '
rl.prompt()

rl.on 'line', (line) ->
  switch line.trim()
    when 'hello' then console.log 'world!'
    else console.log 'Say what? I might have heard `' + line.trim() + '`'
  rl.prompt()
rl.on 'close', ->
  console.log 'Have a great day!'
  process.exit 0
