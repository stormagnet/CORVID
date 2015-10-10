response = ''
lastSent = ''

mockDb = {}

mockTerm =
  send: (text) -> lastSent = text
  query: (prompt) -> new Promise.resolve response
  getLines: (prompt) -> new Promise.resolve response

cmds = (require '../commands') db: mockDb, terminal: mockTerm

