spinnerFactory = (chg, phases) ->
  idx = 0
  loop
    yield chg phases[idx]
    idx = (idx + 1) % phases.length

# Or without .next sillyness...

spinnerFactory = (chg, phases) ->
  s = (->
    idx = 0
    loop
      yield chg phases[idx]
      idx = (idx + 1) % phases.length)()

  -> s.next().value

# Usage in readline

readline = require 'readline'

rl = readline.createInterface input: process.stdin, output: process.stdout

chgPrompt = (p) ->
  rl.setPrompt p
  rl.prompt false

spinPrompt = spinnerFacotry chgPrompt, [ "o >", "O >" ]

setInterval spinPrompt, 250
