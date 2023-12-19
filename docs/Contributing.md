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

### Changing API functions

When a user command is issued, the Cider script establishes a reference pointing to Cider in `⎕SE`, and uses that pointer to call any functions in the API.

When Cider is opened as a Cider project however, it asks the user whether a variable `DEVELOPMENT` should be established in the namespace `⎕SE.Cider`.

If such a variable exists and its values is not 0, then Cider's user command script establishes a reference not to `⎕SE.Cider` but to `#.Cider.Cider`.

The consequence of this is that when you change a function in the process of running it, it will be saved by Link _in the project_, meaning your changes are preserved.

In order to remind you what's happening, Cider prints a warning to the session whenever a user command is executed:

```
*** Warning: Code is executed in #.Cider.Cider rather than ⎕SE.Cider!
```

However, `⎕SE.Cider.DEVELOPMENT` is set to 2 by the test suite if it was 1. This has the same consequences except that the warnings are not printed, so the tests are not flooded by them. 

The former value is re-established once the tests are done.

### Changing the script `Cider.dyalog`

For the following to work you must put this into `config.dcfg` (see the "Installation and Configuration Guide" of Dyalog for your OS for details):

 
```
{
    Settings: {    
        DYALOGSTARTUPKEEPLINK : 0,
    }
}
```

This setting ensures that when you make changes to a user command script, then those changes will be saved by Link, not as part of the project but in the folder is was loaded from by the user command framework.

*That means that after such a change the script in the project is not up-to-date anymore!*

However, when a new version is build the code will check whether the two scripts differ, and if they do it will ask the user whether the later one should be copied over, ensuring that no code will be lost.

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





