# Dimension lookup function factory

globalCache = {}
alreadyLoading = {}

versionConflict = (name, want, have) ->
  "Currently loaded dimension '#{name}' version '#{have}' cannot act like version '#{want}'"

versionNotFound = (name, want) ->
  "Could not find dimension '#{name}' version '#{want}'"

alreadyLoaded = (name, version) ->
  if versions = globalCache[name]
    if dim = versions[version]
      return dim

    for ver, dim of versions
      if dim.doesVersion version
        return globalCache[name][version] = dim

dimensionLoader = (where, name, version, locator) ->
  loading = new Promise (resolve, reject) ->
    return resolve dim if dim = alreadyLoaded name, version

    return alreadyLoading.then resolve, reject if alreadyLoading[name]

    alreadyLoading[name] = loading

    attemptRequire name
      .catch (err) ->
        attemptInstall name, version
          .then -> attemptRequire name
      .then (dim) ->
        delete alreadyLoading[name]
        globalCache[name][v] = dim for v in dim.versions()
        resolve dim
      .catch reject

attemptRequire = (name, locator) ->
  new Promise (resolve, reject) ->
    try
      mod = require name
      dim = mod locator
      resolve dim
    catch err
      reject err

attemptInstall = (name, locator) ->
  new Promise (resolve, reject) ->
    npm.install where, name, (er, installed, display) ->
      if er
        delete alreadyLoading[name]
        reject er

      resolve installed, display

locatorFactory = (where) ->
  locator = (name, requestedVersion) ->
    if cached = this[name]
      if cached.doesVersion requestedVersion
        cached
      else
        new Promise.reject new Error versionConflict name, requestedVersion, cached.version
    else
      if match = dimensionLoader where, name, version, this
        resolve this[name] = match
      else
        new Promise.reject new Error versionNotFound name, requestedVersion

