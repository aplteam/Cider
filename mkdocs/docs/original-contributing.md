# Contributing

## Overview

In order to contribute to Cider as a developer you need some pieces of information. 

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

  For example, if no project is specified, they check whether there is a single Cider project open. If that's the case, they act on that project. If multiple projects are open, they will ask the user which one to act on.


## Developing

### General

The user command script does not carry out any of Cider's "business logic", it just works out whether it should execute code in `⎕SE` or in `#`, and then calls functions in either `⎕se.Cider.##.UC` (the default) or in `#.Cider.Cider.UC` (trace & develop).

> See the discussion of the `DEVELOPMENT` variable further down for details

While the API functions live in `⎕SE.Cider` (and call stuff in `⎕SE.Cider.##`), the user command functions live in `⎕SE.Cider.##.UC`.

### Changing the user command script

The user command script is a thin cover that directs calls to (usually) `⎕SE.Cider.UC`. It is therefore pretty unlikely that there will every be a need for changing that script.

In the unlikely event that the user command script needs changing anyway, Link will record any changes only if you have specified 

```
   DYALOGSTARTUPKEEPLINK : 1,
```

in a dyalog configuration file, otherwise changes are **_not_** recorded. 

> Regarding `DYALOGSTARTUPKEEPLINK`, see the "Installation and Configuration Guide" of Dyalog for your OS for details.

Make sure that you change the script either in the location it is started from or in the project, but not both. When you create a new version of Cider it will check whether the two versions are identical (when no action is taken) or not, when it will suggest to copy over the version that carries the latest changes.

### Changing the user command functions

The user command script calls functions in `#.Cider.UC` when developing and in `⎕SE.Cider.##.UC` otherwise. Because that namespace is part of the project, with `DEVELOPMENT>0` changes are recorded, so developing is easy.

### Changing API functions

When a user command is issued, the Cider user command script calls a function in the `UC` namespace (see above), which will eventually call an API function in `#.Cider.Cider` (with `DEVELOPMENT>0`) or in `⎕SE.Cider`

When Cider is opened as a Cider project, the user will be asked whether a variable `DEVELOPMENT` with a value greater than 0 should be established in the namespace `⎕SE.Cider`.

If such a variable exists and its values is not 0, then Cider establishes a reference not to `⎕SE.Cider` but to `#.Cider.Cider`.

The consequence of this is that when you change a function in the process of running it, it will be saved by Link _in the project_, meaning your changes are preserved.

In order to remind you what's happening, Cider prints a warning to the session whenever a user command is executed:

```
*** Warning: Code is executed in #.Cider.Cider rather than ⎕SE.Cider!
```

However, `⎕SE.Cider.DEVELOPMENT` is set to 2 by the test suite in case it was 1. This has the same consequences except that the warnings are not printed, so the tests are not flooding the session window with those warnings.

The former value is re-established once the tests are done.

## Running the test suite

You may ask Cider for how to run the test cases:

```
]Cider.RunTests
```

That gives you a statement that will execute all tests, and report to the session. That includes tests that will attempt to interact with the user.

If you need to execute the test suite in batch mode (no reporting to the session, and returning a single boolean indicating success (1) or failure (0)) you must run:

```
#.Cider.TestCases.RunTestsInBatchMode
```


### NuGet tests

Note that running the NuGet tests requires .NET (rather than .NET Framework) to be used by Dyalog.

The test cases check that and don't execute in case .NET is not available.

## Building a new version

You may ask Cider for how to build a new version:

```
]Cider.Make
```

Before executing that statement you should check both `#.Cider.Cider.Version` and `#.Cider.Cider.History` for being up-to-date.

Cider's `Admin.Make` function will create a new version and save it as a ZIP file in the `Dist/` folder within the project folder.

In a final step it will ask whether the new version should be installed as a user command. 

If the answer is "yes" it will install Cider into the folder where it has previously been installed, or, if it has not been previously installed, ask the user whether it should be installed into the version-specific or the version-agnostic folder for Dyalog files on your operating system.


## Making a new version ready for Dyalog

In order to make a new version available for Dyalog for bundling purposes, Cider needs to be installed from the `[tatin]` Registry in a first step. In a second and last step, the contents of the installation folder needs to be zipped into a file with the name

```
Installed-aplteam-Cider-<major>.<minor>.<patch>
```

There is a function available that executes both steps; it requires a 1 to be passed as right argument:

```
#.Cider.Admin.MakeZipForDyalog 1
```

That file needs to go onto the release page for that version where Dyalog can fetch and process it.



