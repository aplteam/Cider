# Cider Project Manager

Cider offers some User commands that are useful to manage projects. In addition is also offers an API.


## Requirements

Cider requires 

* Dyalog 18.0 Unicode or better 
* Link 3.0.8 or better

If Tatin packages are part of a project then Tatin is required as well.

Cider is capable of collaborating with the [Git package](https://github.com/aplteam/APLGit2) but does not rely on it.


## Overview

These commands are available:

* `]Cider.OpenProject`
* `]Cider.CreateProject`
* `]Cider.CloseProject`
* `]Cider.Help`
* `]Cider.ListOpenProjects`
* `]Cider.ListAliases`
* `]Cider.Make`
* `]Cider.RunTests`
* `]Cider.Version`
* `]Cider.ViewConfig`

## Documentation

In this document only `OpenProject` is discussed in detail because that is the principal command.

For all other commands only basic information is provided, but there is a document "Cider-User-Guide.html" available that discusses all features in detail.

The user command help is also pretty exhaustive.

Regarding the API there is a document "Cider-API-Reference.html" available.


## Installation

The ZIP file contains a folder `Cider/`. That folder needs to go into any of the folders that Dyalog APL scans for user commands.

For example, a folder `MyUCMDs` will be scanned for user commands. The location where Dyalog tries to find such a folder depends on the operating system:

```
⍝ Windows:
(2 ⎕NQ'.' 'GetEnvironment' 'USERPROFILE'),'/Documents\MyUCMDs'
⍝ Non-Windows platforms:
(2 ⎕NQ'.' 'GetEnvironment' 'Home'),'/MyUCMDs'
```

Note that under Windows the folder `MyUCMDs` will be created as part of the installation process, but not under Linux and Mac-OS, although it will be scanned for user commands in case it exists.


## Methods


### OpenProject


#### Parameters

Accepts an optional parameter that must be one of:

* A folder that hosts a file `cider.config`
* An alias that points to such a folder

If no such parameter is specified then the current directory is searched for a file `cider.config`. 

* If such a file exists the user is asked whether she really wants to open that project
* If no such file exists then under Windows a dialog box is opened that allows the user to navigate to a Cider project

  On non-Windows platforms an error is thrown.


#### Actions 

Once a folder is established that holds a Cider config file, the user command performs the following actions:

1. Creates the project space (namespace)
1. Sets the system variables `⎕IO` and `⎕ML` in the project space
1. Brings all code and variables into the project space
1. Checks whether any Tatin install folders do not actually have any packages installed but have a non-empty dependency file.

   This may happen in case the package install folders are not uploaded to, say, GitHub (`.gitignore`) and the project was just downloaded.
1. Asks the user whether Cider should check all Tatin packages (if there are any) for later versions 
1. Loads all Tatin packages specified in the file `cider.config`, if any; see `tatinFolder`
1. Injects a namespace `CiderConfig` into the project space and...
   * populates it with the contents of the configuration file as APL arrays
   * adds a variable `HOME` that remembers the path the project was loaded from   
1. Checks whether the project's config file does carry a non-empty value for `init`. If that's the case it must be a function that is then called by Cider, typically for initializing the project
1. If the project is managed by Git and the user command `]APLGit` is around and the git bash is installed then Cider executes the `git status` command on the project folder and puts the result on view

Notes:

* The name of the project space is defined in the Cider config file, but this can be overwritten with the `-projectSpace=` option
* In case the `tatinFolder` parameter specifies one or more packages then the references pointing to those Tatin packages are all established in `projectSpace` by default.

  However, this can be overwritten by specifying a different target space by adding 

  `=SubNamespace`

  after the folder

  Example:

  ```
  tatinFolder: "packages,packages_dev=TestCases"
  ```

  * All principal packages found in `packages/` within the project folder are loaded into the project space because that is the default, and  the default was not overwritten

  * All principal packages found in `packages_dev/` within the project folder  are loaded into the project's sub namespace `TestCases` within the project space because the default _was_ overwritten

### CloseProject

Takes a folder or an alias and breaks the Link between the namespace and its folder.

You may specify the `-all` flag to close all projects in `#`, but check the user command's detailed help (`-??`) for details.


### CreateProject

Requires one mandatory parameter: a folder that is going to be a project. 

Creates a file `cider.config` in that folder.

 
### Help

Offers the user to view selected or all HTML documents with her standard browser.

### ListOpenProjects

Lists the project spaces of all currently linked projects together with the fully qualified paths of all projects currently open.


### ListAliases

Lists all Cider aliases together with their folders.


### Make

Prints an APL statement to the session which, when executed, will build a new version of the project.


### RunTests

Prints an APL statement to the session which, when executed, runs the project's test suite.


### Version

Returns a three-item-vector with "Name", "Version number" and "Version date".


### ViewConfig

Puts the config file of a project on display. 

By specifying the `-edit` flag the user might edit the file rather than just viewing it.
