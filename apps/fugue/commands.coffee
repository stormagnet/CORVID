class CommandDb
  constructor: ({@db, @terminal}) ->

  send: (text) -> @terminal.write text

  help: (args) ->
    @send 'no'

  '>': ([subj, rel, obj]) ->
     if not (subj and rel and obj)
       throw new Error '> requires three names'

     [subj, rel, obj] = arguments[0].map (o) -> util.matchOrMakeObject name: o
     rel.relate subj, obj

  '=': ([name, value...], l) ->
    if not name
      return @send "DB so far contains:\n  " + Object.keys(@db.names).join ' '

    [o, p, rest...] = name.split '.'
    return @send 'Not so fast' if rest.length

    o = util.matchOrMakeObject name: o

    [matched, value] = l.match /^\s*=\s+\S+\s*(.*)/

    if p
      if value
        db[o].ctx.sys.prop p, value
      else
        @send "= #{o}.#{p} #{db[o][p]}"
    else
      if value
        db[o].ctx.sys.name value
      else
        @send JSON.stringify db[o]

module.exports = (env) -> new CommandDb env

