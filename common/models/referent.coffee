module.exports = (Referent) ->
  Referent::cvd_emit = (event) ->

  Referent::cvd_recv = (event) ->

  Referent::cvd_subject_of = (relationType) ->
    relId = relationType.id

    Referent.app.models.Relation.find
      filter:
          and:
            subject: @id
            relation: relId

  Referent::cvd_relations_to = (otherReferent) ->
    otherId = otherReferent.id

    Referent.app.models.Relation.find
      filter:
        or:
          and:
            subject: @id
            object: otherId
          and:
            subject: otherId
            object: @id

