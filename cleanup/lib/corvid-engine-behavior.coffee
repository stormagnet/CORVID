###

How to fetch, load, unload and publish modules in CORVID.

Definitions

  import: invoke a module via its require mechanism
  load: The extra CORVID step for linking a module in to a Core

  (Later:)
    unload: The extra CORVID step for converting a 'live' Core object into something static which conforms to the CommonJS spec
    publish: Exposing an unloaded module via URI or something

Linkages

  * A Euclidic which is associated with a behavior has a URI from which to fetch the module implementing that behavior.
  * When the engine loads (fetches from storage) a Euclidic it 'requires' the module referenced by that URI
  * The returned object must implement the corvid/engine/behavior module's interface, which looks like...

...

  Behavior - extends core objects

  EditableBehavior - can be modified in flight and saved out to be reloaded later

###

define 'corvid/engine/behavior', [], ->
  class Behavior
    constructor: (@engine, @model) ->
      # Called as model.behavior = new (require 'some-behavior')(engine, model)
      # Sets up model to have this module's behavior

define 'corvid/engine/behavior/mutable', ['corvid/engine/behavior'], (Behavior) ->
  class MutableBehavior extends Behavior

