
/* 
 * Sample usage in a gremlin.sh session:
 *
 * gremlin> :load data/corvid-schema.groovy
 * ==>true
 * ==>true
 * gremlin> t = JanusGraphFactory.open('conf/janusgraph-cassandra-es.properties')
 * ==>standardjanusgraph[cassandrathrift:[127.0.0.1]]
 * gremlin> new CORVIDSchema(t).define()
 * ==>null
 * gremlin> t.close()
 * ==>null
 * gremlin>
 */


class Schema {
  def schema = [
    kindOrder: [
      'vertexLabel',
      'edgeLabel',
      'propertyKey',
      'compositeIndex',
      'mixedIndex'
    ]
    vertexLabel: [
      // example: []
    ],
    edgeLabel: [
      // example: ONE2ONE
    ],
    propertyKey: [
      // example: [ String, SINGLE ]
    ],
    compositeIndex: [
      // example: [ 
      //   name: "exampleIndex",
      //   class: Vertex,
      //   keys: [
      //     'exampleKeyName'
      //   ]
      //   indexOnly: [ 'example' ]
      // ]
    ],
    mixedIndex: [
      // example: [ 
      //   name: "exampleIndex2",
      //   class: Vertex,
      //   keys: [
      //     'exampleKeyName'
      //   ]
      //   indexOnly: [ 'example' ]
      //   backend: "search"
      // ]
    ]
  ]
  def graph
  def mgmt

  def created = [
    label: {},
    edge: {},
    index: {}
  ]

  kind = [
    get: [
      vertexLabel: mgmt.&getVertexLabel,
      edgeLabel: mgmt.&getEdgeLabel
    ],
    make: [
    ]
  ]

  Schema(janusGraph) {
    graph = janusGraph
  }

  def getOrMake(kindName, name, info) {
    created[kindName][name] =
      kind[kindName].get(name) ||
      kind[kindName].make(name, info)
  }

  void define() {
      m = graph.openManagement()

      for (kindName in schema.kindOrder) {
        kind = schema[kindName]

        for (instance in kind) {
          getOrMake kindName, instance.key, instance
        }
      }

      m.commit()
  }

  def defineVertexLabels() {
    for (labelName in schema.vertexLabels) {
      getOrMake 'vertexLabel', labelName
    }
  }

  def getOrMakeVertexLabel (name) {
    getOrMake m.?getVertexLabel,
        { name -> m.makeVertexLabel(name).make() },
        name
        null
  }

  def getOrMakeEdgeLabel (name, multiplicity) {
    getOrMake(
        m.?getEdgeLabel,
        { name, multiplicity -> m.makeEdgeLabel(name).multiplicity(multiplicity).make() },
        name, multiplicity
  }
}

//        /**
//         * Vertex labels
//         * 
//         * All vertexes are Euclidics, but we label some specifically for indexing
//         * and simplified traversal.
//         */
//  
//        def vLabelNames = [ "referent", "relation", "event", "change", "refType" ]
//        def vLabels = {}
//  
//        for (name in vLabelNames) {
//          if (! vLabels[name] = m.getVertexLabel(name)) {
//            vLabels[name] = m.makeVertexLabel(name).make()
//          }
//        }
//  
//  
//  
//        // Edge labels
//        //   Euclidic
//  
//        //   Relation
//        subject      = m.makeEdgeLabel("subject").multiplicity(MANY2ONE).make()
//        object       = m.makeEdgeLabel("object").multiplicity(MANY2ONE).make()
//        relType      = m.makeEdgeLabel("relType").multiplicity(MANY2ONE).make()
//  
//        //   Type 
//        parent       = m.makeEdgeLabel("parent").multiplicity(MANY2ONE).make()
//  
//        //   Event
//        priorEvent   = m.makeEdgeLabel("priorEvent").multiplicity(ONE2ONE).make()
//  
//  
//        // Vertex and edge properties
//        //   Euclidic
//        name         = m.getPropertyKey("name")
//        description  = m.makePropertyKey("description").dataType(String).cardinality(Cardinality.SINGLE).make()
//  
//        //   Type
//  
//        //   Event
//        instant      = m.makePropertyKey("instant").dataType(Long).cardinality(Cardinality.SINGLE).make()
//        timeUTC      = m.makePropertyKey("timeUTC").dataType(Date).cardinality(Cardinality.SINGLE).make()
//  
//  
//        // Global indices
//        m.buildIndex("referentsByName", Vertex).addKey(name).indexOnly(referent).buildCompositeIndex()
//        m.buildIndex("typesByName",     Vertex).addKey(name).indexOnly(type).buildCompositeIndex()
//        m.buildIndex("eventsByTimeUTC", Vertex).addKey(timeUTC).indexOnly(event).buildMixedIndex("search")
//        m.buildIndex("eventsByInstant", Vertex).addKey(instant).indexOnly(event).buildMixedIndex("search")
//  
//        m.commit()
//    }
