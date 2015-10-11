# invoke

  ! name.prop args...

# create

  = name description...

Also

  = name < parent

Is shorthand for

  = name
  > name IsA parent

# edit

  = name.prop value...

# program

  . name.prop args...
    ... code ...
  .

# load module

  @ name url

Acts like (require(url))(db[name])

# relate

  > subject relation object

# query

  ? name
  ? name.prop
  ? subject > [relation]

