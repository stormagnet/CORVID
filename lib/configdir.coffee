# Slurp up a directory as an object. If there is a foo.json, add it to the
# directory object under foo:. If there is a foo/bar.json, it will show up as
# foo: bar: ...

fs = require 'fs'
path = require 'path'

readDirPromise = (dirPath) ->
  if 'string' isnt typeof dirPath
    throw new Error "readDirPromise called with non-string: " +
                    JSON.stringify dirPath

  new Promise (resolve, reject) ->
    fs.readdir dirPath, (err, entries) ->
      if err
        reject err
      else
        resolve entries

statPromise = (entryPath) ->
  new Promise (resolve, reject) ->
    fs.stat entryPath, (err, entryStat) ->
      if err
        reject err
      else
        resolve [entryPath, entryStat]

statEntries = (dir) -> (entries) ->
      Promise.all (
        entries
          .map (entryName) -> path.resolve dir, entryName
          .map statPromise
      )

processEntryStats = (entryStats) ->
  slurped = {}
  subDirs = []

  for [entryPath, entryStat] in entryStats
    entryName = path.basename entryPath, '.json'

    switch
      when entryStat.isFile()
        slurped[entryName] = require entryPath
      when entryStat.isDirectory()
        subDirs.push [entryName, entryPath]

  treeResults =
    Promise.all (
      for [entryName, entryPath] in subDirs
        do (entryName, entryPath) ->
          slurpDir entryPath
            .then (tree) -> [entryName, tree]
    )

  console.log treeResults

  treeResults.then (subTrees) ->
    for [name, tree] in subTrees
      slurped[name] = tree

    slurped

filterEntries = (entries) ->
  Promise.resolve entries.filter ([entryName, entryStat]) ->
    not entryName.startsWith '.' and
       (entryName.endsWith '.json' or
        entryStat.isDirectory())

module.exports = slurpDir = (dir) ->
  readDirPromise dir
    .then statEntries dir
    .then filterEntries
    .then processEntryStats
    .catch (err) -> console.log err
