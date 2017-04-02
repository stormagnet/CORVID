
/* 
 * Sample usage in a gremlin.sh session:
 *
 * gremlin> :load data/corvid-schema.groovy
 * ==>true
 * ==>true
 * gremlin> t = JanusGraphFactory.open('conf/janusgraph-cassandra-es.properties')
 * ==>standardjanusgraph[cassandrathrift:[127.0.0.1]]
 * gremlin> defineGratefulDeadSchema(t)
 * ==>null
 * gremlin> t.close()
 * ==>null
 * gremlin>
 */

def defineGratefulDeadSchema(janusGraph) {
    m = janusGraph.openManagement()

    // vertex labels
    referant  = m.makeVertexLabel("referant").make()
    relation  = m.makeVertexLabel("relation").make()
    event     = m.makeVertexLabel("event").make()

    // edge labels
    reference = m.makeEdgeLabel("reference").make()
    transform = m.makeEdgeLabel("transform").make()
    change    = m.makeEdgeLabel("change").make()

    // vertex and edge properties
    //   referant
    name      = m.makePropertyKey("name").dataType(String.class).make()
    desc      = m.makePropertyKey("desc").dataType(String.class).make()

    //   relation
    relation  = m.makePropertyKey("relation").dataType(String.class).make()

    //   change
    instant   = m.makePropertyKey("instant").dataType(String.class).make()

    // global indices
    m.buildIndex("referantsByName", Vertex.class).addKey(name).indexOnly(referant).buildCompositeIndex()

    // vertex centric indices
    m.buildEdgeIndex(followedBy, "followedByWeight", Direction.BOTH, Order.decr, weight)
    m.commit()
}
