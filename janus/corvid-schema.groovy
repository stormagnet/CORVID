import Schema

def CORVIDSchema = [

  // Vertex labels
  // 
  // All vertexes are Euclidics, but we label some specifically for indexing
  // and simplified traversal.

  vertexLabel: [
    referent : [],
    relation : [],
    event    : [],
    change   : [],
    refType  : []
  ],

  edgeLabel: [
    // Euclidic

    subject       : MANY2ONE,
    object        : MANY2ONE,
    relType       : MANY2ONE,

    // Relation
    parent        : MANY2ONE,

    // Type 

    // Event
    priorEvent    : ONE2ONE
    
  ],

  // Euclidic
  propertyKey: [
    name: [],
    description: [ type: String, cardinality: Cardinality.SINGLE ]
  ],

  compositeIndex: [
    referentsByName: [
      class: Vertex,
      keys: [ 'name' ],
      indexOnly: [ 'referent' ]
    ],
    typesByName: [
      class: Vertex,
      keys: [ 'name' ],
      indexOnly: [ 'type' ]
    ]
  ],
  mixedIndex: [
    eventsByTimeUTC: [
      class: Vertex,
      keys: [ 'timeUTC' ],
      indexOnly: 'event'
    ],
    eventsByInstant: [
      class: Vertex,
      keys: [ 'instant' ],
      indexOnly: 'event'
    ]
  ]
]


