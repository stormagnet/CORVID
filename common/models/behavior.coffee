class Parameter
  constructor: ({@name, @default}) ->

  init: ({args, behavior}) ->
    if @name in Object.getOwnPropertyNames args
      args[@name]
    else
      @default

class Variable
  constructor: ({@name, @context, @behavior}) ->
    if 'function' is typeof @[initFn = "_#{@context?.type}_context_init"]
      @init = @[initFn]()

  _behavior_context_init: ->
    ({args}) => @value = @behavior._getContextData @

  _named_object_context_init:
    contextRef = @_db?.lookup @context.objectName
    ({args}) => @value = contextRef._getContextData @


module.exports = (Behavior) ->
  Behavior::invoke = (args = {}) ->
    vars = @_getState args

    results = @_compiled vars

    @_atomicTxn {results, vars}

  Behavior::_atomicTxn ({results, vars}) ->
    txn =
      id: @_atomicTxn.getId()
      behavior: @

    results
      .concat(vars)
      .forEach (e) -> e.updateTxn txn

    txn.execute()

  Behavior::_get_state = (args) ->
    vars = {}

    for paremeter in @_parameters
      argument = parameter.init {args, behavior: @}
      vars[parameter.name] = argument

    for variable in @_variables
      vars[variable.name] = variable.init {args, behavior: @}

    return vars

  Behavior.observe 'after save', (context, next) ->
    self = context.instance

    try
      self._parameters = self.parameters.map (p) -> new Parameter Object.assign p, behavior: self
      self._variables  = self.variables.map  (p) -> new Variable  Object.assign p, behavior: self

    next()
