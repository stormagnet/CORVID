# ANOTHER non-wiki documentation page? UGH!

Yeah, sorry, I needed to "think out loud" and this was the best option for me.

# ObjectDB interface

    var db = require('objectdb')(dbLayerList);

Creates a minimal db ($sys, $root, $wiz), then loads each supplied layer. Each
element of dbLayerList is a path to a directory following the serialized db
protocol to be defined next...

# Serialized DB protocol

## DBLayerLibraries

The Core, System and Setting can be split into multiple parts, all of which
qualify as DBLayerLibraries (DBLL).

### Platonics

Any library may declare platonic objects, but objects declaring platonics will generally fall within the 'core' layer. Domain admins should be suspicious of non-core libraries including platonics.

### Observations

Non-platonic state is captured in Observations as described in the wiki.

### On-disk format of libraries

 * platonics/

## World state

A stored world captures the results of everything that has happened to it
since it came into being. A world includes a log of all of the events which
created it, but some of the results of those events will be missing in the
latest stored version in cases where a later event obviates an earlier one.
Fill a bucket, empty a bucket, the 'full' version of the bucket only exists in
the memories of those who experienced and cared to remember it.

### Format

  * log/YYYY-MM-DD-hh-mm.log, log/pending.log
    * A concatenation of JSON objects, each representing an event which might have happened in this world (non-canonical events are persisted).
    * When the canonicity of an event changes, that chage is itself another event which is appened to the log.
    * pending.log contains activity which has not been published to world/canon yet.
  * world/
    * lib/NN-Name
      * The DBLayerLibraries which were used to compose this world are stored separately from the original libraries to make the world state directory self-contained.
      * Their form here is identical to their distribution form, described above.
      * The NN portion is a number controlling the order in which the libraries are loaded.
      * The Name portion is whatever the library wants to be called.
    * canon/
      * NN.json
 
 
