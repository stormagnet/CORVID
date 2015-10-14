# simple

## invoke

  ! name.prop args...

## create

  = name description...

## edit

  = name.prop value...

## relate

  > subject relation object

# advanced

## program

  . name.prop args...
    ... code ...
  .

## load module

  @ name url

Acts like (require(url))(db[name])

## query

  ? name
  ? name.prop
  ? subject > [relation]

