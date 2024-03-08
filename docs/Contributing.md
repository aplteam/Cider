[parm]:title             = 'Contributing'
[parm]:leanpubExtensions = 1
[parm]:numberHeaders     = 2 3 4 5 6
[parm]:toc               = 2 3 4 5 6



# Contributing

## Overview

In ordert to contribute to Cider as a developer you need some pieces of information. 

W> This document is work in progress but useful nevertheless.

## Design

### The user commands and the API

Cider consists of an API and a user command script.

A couple of principles:


**API functions...**

* do not do any guessing, meaning they require precise parameters in order to work
* do not communicate with the user
* throw an error if they cannot fulfil their job

**User commands...**

* print useful messages if something goes wrong (though they do throw errors in case of missing or invalid parameters)
* They often do guess what the user is up to

  For example, if no project is specified, they check whether there is a single Cider project open. If that's the case, they act on that project. If multiple projects are open they ask the user which one to act on.


## Developing

### General

The user command script does not carry any of Cider's "business logic", it just works out whether it should execute code in `⎕SE` or in `#`, and then calls functions in either `⎕se.Cider.##.UC` (the default) or in `#.Cider.Cider.UC` (trace & develop).

I> See the discussion of the `DEVELOPMENT` variable further down for details

While the API functions live in `⎕SE.Cider` (and call stuff in `⎕SE.Cider.##`), the user command functions live in `⎕SE.Cider.##.UC`.

### Changing the user command script

In the unlikely event that the user command script needs changing, Link will record any changes only if you have specified 

```
   DYALOGSTARTUPKEEPLINK : 1,
```

in a dyalog configuration file, otherwise changes are **_not_** recorded. 

I> Regarding `DYALOGSTARTUPKEEPLINK`, see the "Installation and Configuration Guide" of Dyalog for your OS for details.

Make sure that you change the script either in the location it is started from or in the project, but not both. When you create a new version of Cider it will check whether the two versions are identical (when no action is taken) or not, when it will suggest to copy over the version that carries the latest changes.

### Changing the user command functions

The user command script calls functions in `#.Cider.UC` when developing (`⎕SE.Cider.##.UC` otherwise). Because that namespace is part of the project, with `DEVELOPMENT>0` changes are recorded, so developing is easy.

### Changing API functions

When a user command is issued, the Cider user command script calls a function in the `UC` namespace (see above), which will eventually call an API function in (with `DEVELOPMENT>0`) in `#.Cider.Cider` (`⎕SE.Cider` otherwise).

When Cider is opened as a Cider project, the user will be asked whether a variable `DEVELOPMENT` with a value greate than 0 should be established in the namespace `⎕SE.Cider`.

If such a variable exists and its values is not 0, then Cider establishes a reference not to `⎕SE.Cider` but to `#.Cider.Cider`.

The consequence of this is that when you change a function in the process of running it, it will be saved by Link _in the project_, meaning your changes are preserved.

In order to remind you what's happening, Cider prints a warning to the session whenever a user command is executed:

```
*** Warning: Code is executed in #.Cider.Cider rather than ⎕SE.Cider!
```

However, `⎕SE.Cider.DEVELOPMENT` is set to 2 by the test suite if it was 1. This has the same consequences except that the warnings are not printed, so the tests are not flooding the session window. 

The former value is re-established once the tests are done.

## Running the test suite

You may ask Cider for how to run the test cases:

```
]Cider.RunTests
```

.... (more to come)



## Building a new version

You may ask Cider for how to build a new version:

```
]Cider.Make
```

... (more to come)






