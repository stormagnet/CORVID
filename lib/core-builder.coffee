
module.exports =
  class Engine
    constructor: (@settings = {}) ->
      @_tp = (require './tinker-pop.coffee')
      @core = null

    start: ->
      @tp.init()
      @core = @tp.core()

    makeRef: makeRef = (name) ->
      @core.findOrAddVertex {name}

    relate: (subject, relation, object) ->
      subject  = makeRef name: subject
      relation = makeRef name: relation
      object   = makeRef name: object

      @core.relate {subject, relation, object}


