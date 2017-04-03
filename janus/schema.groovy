/* 
 * Sample usage in a gremlin.sh session:
 *
 * gremlin> :load data/corvid-schema.groovy
 * gremlin> :load data/schema.groovy
 * gremlin> t = JanusGraphFactory.open('conf/janusgraph-cassandra-es.properties')
 * gremlin> new Schema(t, CORVIDSchema).define()
 * gremlin> t.close()
 */

class Schema {
  def graph = null
  def mgmt = null
  def schema = null
  def kindOrder = [ 'vertexLabel', 'edgeLabel', 'propertyKey', 'compositeIndex', 'mixedIndex' ]

  def created = [
    label : {},
    edge  : {},
    index : {}
  ]

  def kind = [
    get: [
      vertexLabel    : mgmt.&getVertexLabel,
      edgeLabel      : mgmt.&getEdgeLabel,
      propertyKey    : mgmt.&getPropertyKey,
      compositeIndex : mgmt.&getGraphIndex,
      mixedIndex     : mgmt.&getGraphIndex
    ],

    make: [
      vertexLabel: { name -> m.makeVertexLabel(name).make() },

      edgeLabel:   { name, multiplicity ->
          mgmt.makeEdgeLabel name
              .multiplicity multiplicity
              .make()
      },

      propertyKey: { name, info -> 
          mgmt.makePropertyKey name
              .dataType        info.type
              .cardinality     info.cardinality
              .make()
      },

      compositeIndex: { name, info -> makeIndex name, info, mgmt.&buildCompositeIndex },

      mixedIndex: { name, info -> makeIndex(name, info).buildMixedIndex(info.backend || "search") }
    ]
  ]

  Schema(janusGraph, janusSchema) {
    graph  = janusGraph
    schema = janusSchema
  }

  void define() {
      m = graph.openManagement()

      for (kindName in kindOrder) {
        kind = schema[kindName]

        for (instance in kind) {
          getOrMake kindName, instance.key, instance
        }
      }

      m.commit()
  }

  private startMakingIndex(name, info) {
    ( i = mgmt.buildIndex name, info.type
              .indexOnly info.indexOnly )

    for (k in info.keys) {
      i.addKey k
    }

    return i
  }
 
  private getOrMake(kindName, name, info) {
    created[kindName][name] =
      kind[kindName].get(name) ||
      kind[kindName].make(name, info)
  }
}

