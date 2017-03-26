module.exports =
  class DependencyManager
    constructor: (@stages...) ->
      if not @stages.length
        throw new Error "Need one or more stages to wait for processes to reach."

      [ @firstStage, @lastStage = @stages[0] ] = @stages

      @_initStage @stage = {}
      @_initStage @waiting = {}

    _initStage: (stage) -> stage[s] = {} for s in @stages

    markDone: (name) -> @stage[s][name] = true for s in @stages

    waitFor: (name, stage = @lastStage, deps..., andThen) ->
      @waiting[stage][name] = { name, deps, andThen }

      @checkProgress name

    checkProgress: (name, stage = @lastStage, checking = []) ->
      if @stage[stage][name]
        return true

      if not @waiting[name]
        return false

      if name in checking
        return false

      totalPending = 0

      for intermediateStage in @stages
        break if intermediateStage is stage

        if not (deps = @waiting[name][intermediateStage].deps)?.filter
          throw new Error "Dependency format error for dependent #{name}, stage #{stage}: ", deps

        totalPending += (
          @waiting[name][intermediateStage].deps =
            @waiting[name][intermediateStage].deps.filter (dep) => not @checkProgress dep, intermediateStage
        ).length

      if @stage[stage][name] = totalPending is 0
        @waiting[name][stage].andThen()
        @stage[nextStage = @_stageAfter stage][name] = true
        @checkProgress name, nextStage
        return true

    tryToFinish: (waiting = Object.getOwnPropertyNames @waiting) ->
      stillWaiting = waiting.filter (name) => not @checkProgress name

      if not stillWaiting
        return true

      if progress = waiting.length - stillWaiting.length
        tryToFinish stillWaiting
