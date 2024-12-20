---
title: Contributing to Cider
description: How to contribute to Cider, the project manager for Dyalog APL software authors
keywords: api, apl, cider, dyalog, link, source, tatin, versions
---

# Contributing


!!! abstract "How to contribute to Cider"


Cider exposes an API and some user commands.

API functions

-   make no guesses: they require exact arguments and parameters
-   do not communicate with you
-   signal an error if they fail

User commands

-   print helpful messages if something goes wrong (but signal errors for missing or invalid parameters)
-   often guess what you want; e.g. if no project is specified but one is open, the command uses it; if several are open, Cider asks you to select one


## Namespaces

The only namespace a Cider user needs to refer to (for the API) is `⎕SE.Cider`.

Developers understand:

`#.Cider`
: holds the project.

`#.Cider.Cider`
: holds what will eventually become the Cider package.

`#.Cider.Cider.UC`
: holds the functions called by the user-command framework. 
    They potentially communicate with the user, prepare arguments and eventually call functions in `#.Cider.Cider`.

`⎕SE.Cider`
: is a ref pointing to the Cider package’s API namespace, for example:
    `⎕SE._tatin.aplteam_Cider_0_44_0.API`

`⎕SE._tatin`
: holds all packages loaded into `⎕SE`, while `#._tatin` holds all Tatin packages loaded into `#`.

The API namespace
: (the name can be configured in the project’s config file) holds thin covers for calling the real thing in the parent,, hence `##` or `⎕SE.Cider.##`

`⎕SE.Cider.##.UC`
: is the same as `#.Cider.Cider.UC` but as part of the user-command package rather than the project.

When you execute a user command like
`]Cider.ListOpenProjects`
it is executed in `⎕SE`. 

When you run tests, you might want to make changes to the code.
That would not work well when user commands are tested because changes in `⎕SE` are
not tracked! 
That’s why the tests ask whether you would prefer the code to be executed in `#.Cider` rather than `⎕SE.Cider`, because then they *are* tracked.


## Develop

__Development Mode__ (DM) is set in variable `⎕SE.Cider.DEVELOPMENT`:

    0 - off
    1 - on (verbose)
    2 - on (silent)


If DM is 2, reports and warnings are suppressed.


### User commands and the API

Cider’s core logic is in the API functions.

The user-command script works out whether it should execute code in `⎕SE` or in `#`,  then calls functions according to the DM:

    off - ⎕SE.Cider.##.UC
    on  - #.Cider.Cider.UC

<!-- FIXME Is `a.b.##.c` not a ref to `a.c`? -->

The API functions are in `⎕SE.Cider`, and call objects in `⎕SE.Cider.##`

The user-command functions are in `⎕SE.Cider.##.UC`


### The user-command script

The user-command script is a thin cover for calls to (usually) `⎕SE.Cider.UC`. 
<!-- FIXME Really? Namespace not previously mentioned. -->
You will rarely need to change it.

If you do, Link records your changes __only__ if you have specified environment variable

    DYALOGSTARTUPKEEPLINK : 1,

in a Dyalog configuration file.

!!! tip "How to set environment variables"
    See the Dyalog installation and configuration guides for how to set environment variables.

    :fontawesome-solid-globe: 
    [Dyalog Documentation Centre](https://www.dyalog.com/documentation_190.htm)

Change the script either in the location it is started from, or in the project, but not in both. 

When you create a new version, Cider checks whether the two versions are identical.
If not, it proposes copying over the version that carries the latest changes.
<!-- FIXME I don’t understand this. -->


### Changing user-command functions

The user-command script calls functions in `#.Cider.UC` when DM is on, and in `⎕SE.Cider.##.UC` when DM is off.

Because that namespace is part of the project, with DM on, your changes are recorded, and developing is easy.


### Changing API functions

A Cider user command calls a function in the `UC` namespace (see above), which eventually calls an API function in

    #.Cider.Cider   ⍝ DM on
    ⎕SE.Cider       ⍝ DM off

When Cider opens Cider as a project, it proposes setting DM on in `⎕SE.Cider`.

If DM is on, Cider establishes a reference not to `⎕SE.Cider` but to `#.Cider.Cider`.
<!-- FIXME Establishes a reference? -->

The consequence is that when you change a function in the course of running it, Link will save it _in the project_, preserving your changes.

To remind you what’s happening, Cider prints a warning whenever a user command is executed:

    *** Warning: Code is executed in #.Cider.Cider rather than ⎕SE.Cider!




## Test

Cider can tell you how to run the test cases:

    ]Cider.RunTests

That prints an expression that, if executed, runs all the tests (interactive included) and reports to the session.

If DM is 1, the test suite sets it to 2 while running, so as not to flood the session window.

To execute the test suite in batch mode (no reports, and returns a single flag indicating success):
<!-- FIXME Why a batch mode if the test suite sets DM to 2 while running? -->

    #.Cider.TestCases.RunTestsInBatchMode

!!! warning "NuGet tests require .NET"

    Running the NuGet tests requires .NET, rather than .NET Framework.

    The test cases execute only if .NET is available.
    <!-- FIXME Just the Nuget tests, or all tests? -->


## Build

Cider can tell you how to build a new version. 
User command

    ]Cider.Make

prints an expression that builds a new version. 

Before executing it, check both `#.Cider.Cider.Version` and `#.Cider.Cider.History` are up-to-date.

Cider’s `Admin.Make` function creates a new version and saves it as a ZIP file in the distribution folder specified in the project config.

Finally, Cider proposes installing the new version.

Doing so installs Cider over the current version.
Restart Dyalog to use the new version.

<!-- 
FIXME How can Cider not be installed if it is running?

  , or, if it has not been previously installed, ask the user whether it should be installed into the version-specific or the version-agnostic folder for Dyalog files on your operating system.
 -->


## Distribute

To release a new version to Dyalog for bundling:

1.  Install Cider from the `tatin` Registry
1.  Zip the contents of the installation folder into a file with the name 

        Installed-aplteam-Cider-<major>.<minor>.<patch>

This function takes an argument of 1 and executes both steps:

    #.Cider.Admin.MakeZipForDyalog 1

Upload the ZIP file to the release page for the version, where Dyalog can fetch and process it.



*[DM]: Development Mode