module.exports = function Observation(info) {
  if (!(this instanceof Observation)) {
    return Observation(info);

  function extractInfo (which) { this[which] = info[which]; };

  'observer context subject relation object details'.split().forEach(extractInfo);
};

Observation.prototype = {
  match: function () {},
};
