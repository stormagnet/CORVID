module.exports = ({app, waitFor, core, makeRef, relate}) ->
  referents = [
    "./euclidic/change/associate"
    "./euclidic/change/destroy"
    "./euclidic/change/dissociate"
    "./euclidic/change/manifest"
    "./euclidic/change/morph"
    "./euclidic/change"
    "./euclidic/dimension"
    "./euclidic/engine"
    "./euclidic/entity/actor"
    "./euclidic/entity/group"
    "./euclidic/entity"
    "./euclidic/relation/does"
    "./euclidic/relation/has"
    "./euclidic/relation/instanceOf"
    "./euclidic/relation/subsetOf"
    "./euclidic/relation"
    "./euclidic"
  ]

  for ref in referents
    require(ref) {app, waitFor, core, makeRef, relate}
