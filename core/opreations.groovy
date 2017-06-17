/**

:load core/operations.groovy

core = new Core graph

(thing, container) = core.get 'thing', 'container'
(example, box)     = core.create example: thing, box: container

example.is inside box

*/ 

import org.janusgraph.graphdb.vertices.StandardVertex
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.DefaultGraphTraversal

class Core {
  graph = null

  Core(g) {
    graph = g
  }

  get(String name) {
    g.V().has('name', name).toList()
  }

  get(Long id) {
    g.V(id)
  }

  create(namesAndParents) {
    namesAndParents
      .keySet()
      .map { name ->
        o = new Euclidic name

        if (parent = resolveReference namesAndParents[name]) {
          o.setParent parent
        }

        o
      }
  }
}

class Euclidic {
  StandardVertex vertex
  StandardVertex parent

  Euclidic(StandardVertex v, StandardVertex p = null) {
    vertex = v
    parent = p
  }

  fromSelf() {
    g.V(vertex.id()).as 'self'
  }

  void removeParent() {
    t = fromSelf()

    if (parent) {
      t.out 'relation'
       .as  'relation'
       .out 'object'
       .id()
       .is parent.id()
       .select 'relation'
    }

    t
  }

  setParent(newParent) {
    if (!(newParent = Euclidic.get newParent)
       || newParent.is parent) {
      return this
    }

    addParent(removeParent(), newParent)
  }

  addParent(traversal, newParent) {
    traversal
      .V(newParent.id())
      .addE 'childOf'
      .from 'self'
  }

  ancestors() {
    pathsOut 'childOf'
  }

  pathsOut(relation) {
    fromSelf()
      .repeat out relation
      .simplePath()
      .path()
  }

  pathsIn(relation) {
    fromSelf()
      .repeat in relation
      .simplePath()
      .path()
}


