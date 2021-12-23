# Cider Project Manager

Cider offers some User commands that are useful to manage projects. It comes as a set of Dyalog user commands, but an API is also available.


## Requirements

Cider requires 

* Dyalog 18.0 Unicode or better 
* Link 3.0.8 or better

If Tatin packages are part of a project then Tatin is required as well.


## Overview

Currently these commands are available:

* `]Cider.OpenProject`
* `]Cider.CreateProject`
* `]Cider.CloseProject`
* `]Cider.ListOpenProjects`
* `]Cider.ListAliases`
* `]Cider.Help`
* `]Cider.Version`
* `]Cider.ViewConfig`

In this document only `OpenProject` is discussed in detail because that is the principal command.

For all other commands only basic information is provided.

For details refer to the user command help. Regarding the API details are available from the document "Cider-API-Syntax".


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


#### Parameter

Accepts an optional parameter that must be one of:

* A folder that hosts a file `cider.config`
* An alias that points to such a folder

If no such parameter is specified then the current directory is searched for a file `cider.config`. 

* If such a file exists the user is asked whether she really wants to open that project.
* If no such file exists then under Windows a dialog box is opened that allows the user to navigate to a Cider project. 

  On non-Windows platforms an error is thrown.


#### Actions 

Once a folder is established that holds a Cider config file, the user command performs the following actions:

1. Creates the project space (namespace); if it already exists it must be empty
1. Sets the system variables `⎕IO` and `⎕ML` in the project space
1. Brings all code and variables into the project space
1. Asks the user weather Cider should check all Tatin packages for later versions (if there are any)
1. Loads all Tatin packages specified in the file `cider.config`, if any
1. Injects a namespace `CiderConfig` into the project space and...
   * populates it with the contents of the configuration file as APL arrays
   * adds a variable `HOME` that remembers the path the project was loaded from   

Notes:

* The name of the project space is defined in the Cider config file, but this can be overwritten with the `-projectSpace=` option
* In case the `tatinFolder` parameter specifies one or more folders then the references pointing to the Tatin packages are all established in `projectSpace`

  However, this can be overwritten by specifying a different target space by adding 

  `=#.TargetSpace.SubNamespace`

  after the folder

  Example:

  ```
  tatinFolder: "packages,packages_dev=TestCases",:"packages_dev=TestCases",
  ```

  References for all principal packages found in `packages/` are established in the project space because that is the default, and  the default was not overwritten.

  References for all principal packages found in `packages_dev/` are established in the `TestCases` sub namespace within the project space because the default was overwritten.

### CloseProject

Takes a folder or an alias and breaks the Link between the namespace and its folder.

You may specify the `-all` flag to close all projects in `#`.


### CreateProject

Requires one mandatory parameter: a folder that is going to be a project. 

Creates a file `cider.config` in that folder.

 
### ListOpenProjects

Lists the project spaces of all currently linked projects together with the fully qualified names of the namespace holding the project's code.


### ListAliases

Lists all Cider aliases together with their folders.


### Version

Returns a three-item-vector with "Name", "Version number" and "Version date".


### ViewConfig

Puts the config file of a project on display. 

By specifying the `-edit` flag the user might edit the file rather then just viewing it.