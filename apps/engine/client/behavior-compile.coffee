# (foo.someBehavior).compile name, code[, interp]

(name, code) ->
  coffee = require 'coffee-script'
  fn = coffee.eval code
  @package.methods[name] =
    code: code
    fn: fn
  @save()
