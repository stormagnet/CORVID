# Using Node readline interface exclusively as part of MVP

readline = require 'readline'

rl = readline.createInterface
  input: process.stdin
  output: process.stdout

Corvid = require 'corvid-engine'

engine = new Corvid

session = new engine.session

rl.setPrompt '> '
rl.prompt()

session.on 'data', (d) -> rl.write d

rl.on 'line', (l) -> session.lineInput l

rl.on 'SIGINT', -> engine.shutdown()

session.start()
