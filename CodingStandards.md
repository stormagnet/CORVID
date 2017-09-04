# Project code, dev and doc standards

## Best Practices

- Tests first

## Style

- project layout
 - bin/
  - CLI entry points for the deliverable artifact(s)
 - doc/
  - Does not exist because we use the github wiki for this
  - This file is an exception:
   - It needs to be easy to find when looking at the project root
 - scripts/
  - development scripts
 - src/
  - code to be "built" to produce the artifacts
  - 
 - test/
  - tests and test configuration information, if any

- code
 - see EditorConfig

- modules
 - Never over-write module.exports
 - Always modify its members
 - A module which exports one class should do something like:

```coffee
    class exports.Example
      constructor: (info) ->
        { @foo
          @bar
        } = info
```

## Tools

- Test
 - joe
 - chai
- Build
 - Cakefile
 - build/actions
- 
