# Cider Project Manager

Cider offers some User commands that are useful to manage projects. An API is also available.

## Requirements

Cider requires 

* Dyalog 18.0 Unicode or better 
* Link 3.0.0 or better

If Tatin packages are part of a project then Tatin is required as well.

## Overview

Currently these commands are available:

* `]Cider.OpenProject`
* `]Cider.CreateProject`
* `]Cider.CloseProject`
* `]Cider.ListOpenProjects`
* `]Cider.ListAliases`
* `]Cider.Version`

In this document only `OpenProject` is discussed in detail because that is the principal command.

For all other commands only basic information is provided.

For details refer to the user command help. Regarding the API details are available from the document "Cider-API-Syntax".

## Methods

### OpenProject

#### Parameter

Accepts one optional parameter which may be one of:

* A folder that hosts a file `cider.config`
* An alias that points to such a folder

If no such parameter is specified then the current directory is searched for a file `cider.config`. If no such file exists then under Windows a dialog box is opened that allows the user to navigate to a Cider project. On non-Windows platforms an error is thrown.

#### Actions 

Once a folder is established that holds a Cider config file the user command performs the following actions:

1. Creates the project space (namespace); if it already exists it must be empty
1. Sets the system variables `⎕IO`, `⎕ML` and `⎕WX` in the project space
1. Brings all code and variables into the project space
1. Loads all Tatin packages if specified in the file `cider.config`
1. Injects a namespace `CiderConfig` into the project space and...
  * populates it with the contents of the configuration file as APL arrays
  * adds a variable HOME that remembers the path the project was loaded from

Notes:

* The project space is defined in the Cider config file, but this can be overwritten with the `-target=` option
* In case the `tatinLoad` parameter specified just one or more folders then those references pointing to the Tatin packages are all established in `projectSpace`

  However, this can be overwritten by specifying a different target space by adding 

  ```
  =#.TargetSpace.SubNamespace
  ```

  after the folder


### CloseProject

Takes a folder or an alias and breaks the Link between the namespace and its folder.

You may specify the `-all` flag to close all project in `#`.

### CreateProject

Requires one mandatory parameter: a folder to what is going to be a project. 

Creates a file `cider.config` in that folder.

 
### ListOpenProjects

This command lists the project spaces of all currently linked projects.


### ListAliases

This command lists all Cider aliase together with their folders.


### Version

Returns a three-item-vector with "Name", "Version number" and "Version date" regarding "Cider".

## Installation

The contents of the ZIP file needs to go in any of the folders that Dyalog APL scans for user commands.

For example, under Windows a folder `MyUCMDs` will be created in `%USERPROFILE%\Documents` when Dyalog is installed, and that is a good place for putting the `Cider\` folder.

However, note that under Linux and Mac-OS no such folder will be created, although it will be scanned for user commands in case it exists.
