# About Sessions

A session is a streaming dialog between a user and an object representing that
user in the server. Sessions are spawned with an I/O stream, initial parser. 

# Notes

session contains
  stream
  parser
  buffer

session implements
  write, writeLine, writeLines

parsers are a function (data)
  created with makeParser(session, next, [more])
    session object exposes .echoOn and such
  any true value a parser returns replaces it in the chain
    must be enforced by all parsers via
    'next = next(data) || next';
  
 
Parsers:
  login
    On success calls next(userObject)
  admin
  repl

# Scratch

    var user = userdb.validUser(name, pass)
    var adminParser = AdminParser(user)
    var loginParser = LoginParser(session.logIn)
