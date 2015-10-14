fs = require 'fs'
path = require 'path'

UNSUPPORTED_DIRENT_TYPE =
  new Error "Unsupported file type for '#{path.join @path, name}'"

class DirEnt
  constructor: ({@path, @stat}) ->
    if not @stat
      @stat = new Promise (resolve, reject) ->
        fs.lstat @path, (err, stat) ->
          reject err if err

          @stat = stat

class Dir extends DirEnt
  constructor: ({@path}) ->
    super

    @_scan()

  _scan: ->
    new Promise (resolve, reject) ->
      fs.readdir @path, (err, entries) ->
        reject err if err

        @_addEntry name for name in entries

  @_addEntry: (name) ->
    self = this
    new Promise (resolve, reject) ->
      fs.lstat path.join(@path, name), (err, stat) ->
        reject err if err

        klass = if stat.isDirectory() then Dir
          else if stat.isFile() then File
          else if stat.isSymbolicLink() then SymLink
          else throw UNSUPPORTED_DIRENT_TYPE

        o = new klass name: name, stat: stat
        Object.defineProperty self, name, value: o
        resolve o

class File extends DirEnt

class Link extends DirEnt

