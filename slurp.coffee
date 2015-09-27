class DirEnt
  constructor: (@name, @stats) ->

class Dir extends DirEnt
  constructor: (args...) ->
    @data: {}
    super args...

  addEnt: (ent) ->
    if @data[ent.name]
      throw new Error 'name already exists'

    @data[ent.name] = ent

  dirList: ->
    Object.getOwnPropertyNames @data

class File extends DirEnt
  constructor: (args...) ->
    @data: ""
    super args...

  setData: (@data) ->

class Link extends DirEnt
  constructor: (args...) ->
    @target: ""
    super args...

  setTarget: (@target) ->

fs = require 'fs'
path = require 'path'

slurpAny = (fullPath, failure, success) ->
  fs.lstat fullPath, (err, stats) ->
    if err
      failure err

    else if stats.isFile()
      slurpFile fullPath, failure, (f) ->
        f.stats = stats
        success f

    else if stats.isDirectory()
      slurpDir fullPath, failure, (d) ->
        d.stats = stats
        success d

    else if stats.isSymbolicLink()
      slurpLink fullPath, failure, (l) ->
        l.stats = stats
        success l

slurpDir = (fullPath, success, failure) ->
  fs.readdir fullPath, (err, entries) ->
    if err
      failure err
    else
      slurpEntries dir, entries, success, failure

slurpEntries = (dir, entry, entries..., success, failure) ->
  slurpAny dir, entry, failure, (e) ->
    dir.addEnt e

    if entries
      slurpEntries dir, entries, success, failure
    else
      success dir

slurpFile = (fullPath, failure, success) ->
  fs.readFile fullPath, (err, data) ->
    if err
      failure err
    else
      ent = new File path.basename fullPath
      ent.setData data
      success ent

slurpLink = (fullPath, failure, success) ->
  fs.readLink fullPath, (err, target) ->
    if err
      failure err
    else
      link = new Link path.basename fullPath
      link.setTarget target
      success link
