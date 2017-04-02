- vertex lables
 - type: template, defaults, definition
  - euclidic     : all Vertices are euclidics
  - entity       : source and destination of events
  - relation     : description of the difference between a subject and an object
  - aspect       : slice of entity differentiation (color, location, etc)
  - detail       : relation between an aspect of a subject and the aspect's reference value
  - matcher      : hypothetical (testable) detail
  - hypothetical : euclidic wrapped with zero or more matchers for parameters
  - event        : a collection of events and changes
  - behavior     : transforms events into zero or more cascading events and changes if the whole chain succeeds
  - change       : pre-requisites and results
 - instance
  - each intance has
   - a 'type' edge referencing its blahType
   - zero or more 'detail' relations overriding the defaults of its type
  - details of specific instance types:
   - euclidic: an atom of reality and/or fantasy
   - entity: 
   - relation: subject, object, details
   - aspect:
   - detail: aspect/reference, multiplier
   - matcher: aspect/reference, constraints
   - hypothetical: subgraph of matcher-laden euclidics
   - event: who, what, where, when, why, how, etc
   - behavior
   - change

relations, events and changes are all valid euclidics

- edge labels:
 - one per major relation type
  - subject, object
  - relationType
  - createdBy (event reference)

"open door"

translation


impact

- MovementType
 - isan EventType
 - is Interruptable
 - has Duration
 - visibility lineOfSightOrSound
- MovementInstance
 - has EventType
 - hasOptional parentEventList
 - has startTime
 - hasOptional subEventList
- player$2345
 - isan Actor
 - initiated event$1234 
  - isan OpenPortalEvent
  - hasSteps CompoundEventSteps
   - reachTowardsPortal -> then ->
   - graspControl -> then ->
   - operateControl
