# Unfiled commentary

Set without a value instantiates the referent.

# command quick reference

pfx | meaning | usage
--- | ------- | -----
 ?  | get     | ? reference
 =  | set     | = reference value
 !  | call    | ! reference args...
 >  | relate  | > subject relation object
 @  | pull    | @ reference url
 .  | program | . reference [language]
    |         |   code
    |         | .

# syntax

## Comments

Commands start at column one. Anything with leading whitespace that is not part of a program is a comment.

## quotes work like shell

but no interpolation

    "foo\"bar"
    'foo"bar'

## referents by name

A bareword without other specification refers to a referent with the given name

    Referent.find(name)

## referent.property

The dot operator refers to an engine property belonging to the left side and named by the right side

    foo.bar

is /referents/{fooId}/properties/{barId}

## !(expr)

# simple

## invoke

  ! name.prop args...

## set

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

