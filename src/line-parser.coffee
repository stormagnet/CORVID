class LineParser
  constructor: (@consumer) ->

  lineEnd: '\n'

  buffer: ''
  lines: []

  data: (d) ->
    @buffer += d
    lastEOL = buffer.lastIndexOf @lineEnd

    if lastEOL > -1
      @lines += @buffer[..lastEOL].split @lineEnd
      @buffer = @buffer[lastEOL + lastEOL.length..]

    try
      @consumer l for l in @lines
    catch e
      console.log 'Uncaught exception from LineParser.consumer:', e, 'Further buffered input, if any, ignored.'
