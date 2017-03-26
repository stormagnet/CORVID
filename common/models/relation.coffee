module.exports = (Relation) ->
  Relation::toString = ->
    Promise.all rel.getAsync.apply @ for rel in [@subject, @relation, @object]
      .then ->
        "Relation[#{@$subject.name} #{@$relation.name} #{@$object.name}]"
