process = require 'process'
Corvid = (require './corvid')()

CorvidCLI = (require './cli')
  readline: require 'readline'
  Corvid: Corvid

db = new Corvid.Db
app = new CorvidCLI
  inStream: process.stdin
  outStream: process.stdout
  db: db
  cmds: (require './commands')(db)
  throbber: ['/-\\|', 250]

console.log db

app.start
  greeting: """
    Welcome to another CORVID

    Don't expect too much

    """
