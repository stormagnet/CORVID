module.exports = (db) ->
  db.user = o = db.create 'wiz'
  o.parser = (data) ->
