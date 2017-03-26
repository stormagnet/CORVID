# CORVID
Consentual Objective Reality: Virtualized, Interpreted, Distributed

See [the wiki](https://github.com/stormagnet/CORVID) for introduction, news etc.

The current goal is to have something other people can play with as easily as possible. Instructions might look something like this:

    $ npm install
    $ npm install path/to/finch
    $ node world/finch
    > 


# SOME NOTES - ignore

```coffeescript

    relations = """
      instanceOf  instanceOf  relation
      relation    instanceOf  euclidic
      engine      instanceOf  euclidic
      subsetOf    instanceOf  relation
      entity      instanceOf  euclidic
      actor       instanceOf  entity
      group       instanceOf  entity
    """

    relate rel.trim().split ' ' for rel in relations.split '\n'

```
