<img src="https://github.com/aplteam/cider/blob/main/Assets/Cider-Logo.png?raw=true" width="100" height="100">


# Cider Project Manager

Cider offers some User commands useful for managing projects. It also offers an API.

It cooperates with [Tatin](https://github.com/aplteam/Tatin "Link to the Tatin repository on GitHub").


## Requirements

Cider requires 

* Dyalog 18.0 Unicode or better 
* Link 3.0.8 or better (part of a standard Dyalog installation from 18.2 onwards)
* The Tatin package manager (because Cider itself is a Tatin package)


## Overview

These commands are available:

* `]Cider.AddNuGetDependencies`
* `]Cider.AddTatinDependencies`
* `]Cider.CloseProject`
* `]Cider.Config`
* `]Cider.CreateProject`
* `]Cider.Help`
* `]Cider.ListAliases`
* `]Cider.ListNuGetDependencies`
* `]Cider.ListOpenProjects`
* `]Cider.ListTatinDependencies`
* `]Cider.Make`
* `]Cider.OpenProject`
* `]Cider.ProjectConfig`
* `]Cider.RunTests`
* `]UpdateCider`
* `]Cider.Version`

## Documentation

Only `OpenProject` is discussed in detail in this document because it is the main command.

For all other commands only basic information is provided, but there is a document "Cider-User-Guide.html" available that discusses all features in detail.

The user command help is also pretty exhaustive.

A User Guide is available as an HTML document, see [Cider-User-Guide.html](https://html-preview.github.io/?url=https://github.com/aplteam/Cider/blob/main/html/Cider-User-Guide.html).

Regarding the API, the document [Cider-API-Reference.html](https://html-preview.github.io/?url=https://github.com/aplteam/Cider/blob/main/html/Cider-API-Reference.html) is available.

## Installation

In version 19.0 Cider is part of a standard installation of Dyalog, although it needs activation before it is available. Therefore you only have to worry about installing it with versions 18.0 and 18.2. Cider does not run on earlier versions of Dyalog.

Cider can be activated with `]Activate Cider` (after first activating Tatin in a similar way because Tatin is required by Cider) or by activating Cider and Tatin in one step with `]Activate all`.

With version 0.23 Cider became a Tatin package. That simplifies the installation process: all you need to do is issue this command:

```
      ]Tatin.InstallPackages [tatin]Cider <targetFolder>
```

If it is installed into a folder that is scanned for user command scripts by Dyalog, then when a new instance of Dyalog is started,`]Cider` will be available. For an instance that was already running when Cider was installed, execute `]UReset`.

If it is installed into a folder that is not scanned for user command scripts, you need to add that folder to the `cmddir` parameter of SALT.

Example:

```
]SALT.Settings cmddir ",C:\Users\<⎕AN>\Documents\Dyalog APL 18.2 Unicode Files"
```

_**Watch out for the `,` in front of the path: it means that the folder is added!_**

However, the API only becomes available after executing any Cider user command. `]Cider.Version` is enough for that.

If that is not good enough for you, this article explains how to load user commands into `⎕SE` at a very early stage: <https://aplwiki.com/wiki/Dyalog_User_Commands>


## Methods


### `OpenProject`


#### Parameters

Accepts an optional parameter that must be one of:

* A folder that hosts a file `cider.config`
* An alias that points to such a folder

If no such parameter is specified, then the current directory is searched for a file `cider.config`. 

* If such a file exists the user is asked whether she really wants to open that project
* If no such file exists, then under Windows a dialog box is opened that allows the user to navigate to a Cider project

  On non-Windows platforms an error is thrown.


#### Actions 

Once a folder is established that holds a Cider config file, the user command performs the following actions:

1. Creates the project space (namespace)
1. Sets the system variables `⎕IO` and `⎕ML` in the project space
1. Brings all code and variables into the project space
1. Checks whether any Tatin install folders do not actually have any packages installed but have a non-empty dependency file.

   This may happen if the package install folders are not uploaded to, say, GitHub (`.gitignore`) and the project has just been downloaded.
1. Ask the user whether Cider should check all Tatin packages (if there are any) for later versions 
1. Load all Tatin packages specified in the file `cider.config`, if any; see `dependencies.tatin` and `dependencies_dev.tatin`
1. Inject a namespace `CiderConfig` into the project space and...
   * populates it with the contents of the configuration file as APL arrays
   * adds a variable `HOME` that remembers the path the project was loaded from   
1. Inject a namespace `TatinVars` in case the project ends up as a package
1. Check whether the project's config file does carry a non-empty value for `init`. If that's the case, it must be a function that is then called by Cider, typically for initializing the project
1. If there is a variable `ToDo` in the root of the project, and the variable is not empty, then this variable is printed to the session
1. Cider can check for Dropbox conflicts at this stage (configurable)
1. If the project is managed by Git, then Cider executes the `git status` command on the project folder and puts the result on view (configurable)

Notes:

* The name of the project space is defined in the Cider config file, but this can be overwritten with the `-projectSpace=` option
* In case the `dependencies.tatin` and `dependencies_dev.tatin` parameter specifies one or more packages, then the references pointing to those Tatin packages are all established in `projectSpace` by default.

  However, this can be overwritten by specifying a different target space by adding:

  `=SubNamespace`

  after the folder

  Example:

  ```
  dependencies {
     tatin: "packages"
  }
  dependencies_dev {
     tatin: "packages_dev=TestCases"
  }
  ```

  * All principal packages found in `packages/` within the project folder are loaded into the project space because that is the default, and  the default was not overwritten

  * All principal packages found in `packages_dev/` within the project folder  are loaded into the project's sub-namespace `TestCases` within the project space because the default _was_ overwritten

### `CloseProject`

Takes one or more folders or a aliases and breaks the Link between the namespace and its folder for all of them.

Separate projects with space or commas.

You may specify the `-all` flag to close all projects in `#` (*not* `⎕SE`!), but check the user command's detailed help (`-??`) for details.


### `CreateProject`

Requires one mandatory parameter: a folder that is going to be a project. 

Creates a file `cider.config` in that folder.

### `Config`

Allow the user to edit Cider's global config file.

 
### `Help`

Offers the user the ability to view selected or all HTML documents with her standard browser.

### `AddNuGetDependencies`

Use this to add NuGet dependencies

### `AddTatinDependencies`

Use this to add Tatin (and probably also load) Tatin dependencies.

### `ListOpenProjects`

Lists the project spaces of all currently linked projects together with the fully qualified paths of all projects currently open.

### `ListNuGetDependencies`

Lists all NuGet dependencies of the project.

### `ListTatinDependencies`

Lists all Tatin dependencies of the project.

### `ListAliases`

Lists all Cider aliases together with their folders.

### `ProjectConfig`

Puts a project's config file on display and allows the user to edit it.

### `Make`

Prints an APL statement to the session which, when executed, will build a new version of the project.


### `RunTests`

Prints an APL statement to the session which, when executed, runs the project's test suite.


### `Version`

Returns a three-item-vector with "Name", "Version number" and "Version date".


### `UpdateCider`

Update Cider in case a later version is available as a package on [https://tatin.dev](https://tatin.dev).
