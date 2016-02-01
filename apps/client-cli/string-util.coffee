util = module.exports =
  leftJustify: (s, w) ->
    s or= ''
    w = Math.max s.length, w
    s + (" ".repeat(w - s.length))

  scanData: (data) ->
    cols = {}

    for o in data
      for k, v of o
        cols[k] = Math.max cols[k] or 0,
                           k.toString().length,
                           v.toString().length

    cols

  tableFromObjectList: (data, colOrder) ->
    cols = util.scanData data

    colOrder ||= Object.getOwnPropertyNames cols

    util.formatTable cols, colOrder, data

  tableHeaders: (cols, colOrder) ->
    headings = []
    dividers = []

    for c in colOrder
      width = cols[c]
      headings.push util.leftJustify c, width
      dividers.push "-".repeat width

    [headings.join(" | "), dividers.join("-+-")]

  formatTable: (cols, colOrder, data) ->
    table = util.tableHeaders cols, colOrder

    for o in data
      row = (util.leftJustify o[c], cols[c] for c in colOrder)
      table.push row.join " | "

    table

