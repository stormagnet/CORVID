util = require './string-util'

data = []
data.push name: 'Bartles', desc: 'old'
data.push name: 'James', desc: 'really old'
console.log data

console.log cols = util.scanData data

console.log util.tableHeaders cols, Object.getOwnPropertyNames cols

writeLines = (lines) ->
  lines.push ""
  process.stdout.write lines.join "\n"

writeLines util.tableFromObjectList data
#console.log util.tableFromObjectList data
