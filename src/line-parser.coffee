module.exports = class LineParser
  constructor: (@consumer) ->

  buffer: ''
  lineEnd: '\n'

  data: (d) ->
    @buffer += d
    lastEOL = @buffer.lastIndexOf @lineEnd

    if lastEOL > -1
      lines = @buffer[..lastEOL - 1].split @lineEnd
      rest = lastEOL + @lineEnd.length
      @buffer = @buffer[rest .. ]

      try
        @consumer l for l in lines
      catch e
        console.log 'Uncaught exception from LineParser.consumer:\n', e.toString(), '\nFurther buffered input, if any, ignored.'


