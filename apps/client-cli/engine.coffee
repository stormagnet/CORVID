rest = require 'rest-js'

module.exports = class CorvidEngineClient
  constructor: (opts = {}) ->
    @api = new rest.Rest "http://#{opts.host or 'localhost'}:#{opts.port or 3000}/#{opts.apiPath or 'api'}",
             defaultFormat: ''

  config: (name, val) ->
    if not name
      return @api.read '/configs'

    data =
      name: name
      value: val

    if val
      @api.read '/configs/findOne', filter: where: name: name
        .then (conf) =>
          conf.value = val
          @api.update '/configs/' + conf.id, data: conf
        .catch =>
          @api.create '/configs', data: data
    else
      @api.read '/configs/findOne', filter: where: name: name

  create: (name, desc) ->
    @api.create '/locals', data: name: name, description: desc

  list: ->
    @api.read '/locals'

  delete: (id) ->
    @api.remove '/locals/' + id

  nameLookup: (name) ->
    @api.read '/locals/findOne', filter: where: name: name

  reDescribe: (id, desc) ->
    @api.read '/locals', data: id: id
      .then (data) =>
        data.description = desc
        @api.update '/locals/' + data.id, data: data

  relate: (subj, relation, obj, params = {}) ->
    @api.create '/relations', data:
      subjectId: subj
      relationType: relation
      objectId: obj
      parameters: params

  relationsOf: (id) ->
    @api.read '/relations', filter: where: subjectId: id

  props: (id) ->
    @api.read '/properties', filter: where: localId: id

  setProp: (id, name, value) ->
    @api.read '/properties/findOne', filter: where: localId: id, name: name
      .then (data) =>
        data.value = value
        @api.update '/properties/' + data.id, data: data
      .catch =>
        @api.create '/properties', data:
          localId: id
          name: name
          value: value
