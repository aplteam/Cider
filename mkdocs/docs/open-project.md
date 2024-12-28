---
title: Open a Cider project
description: A detailed account of what happens when Cider opens a project
keywords: api, apl, cider, dyalog, link, nuget, source, tatin
---

# Open project

!!! abstract "What happens when you open a project, in detail"

You open a project with either

-   user command [`]CIDER.OpenProject`](user-commands.md#open-project)
-   API function [`⎕SE.Cider.OpenProject`](api.md#open-project) 

The actions on opening a project are modified by, in ascending priority:

1. [global](configuration.md#global-configuration) config settings
1. [project](configuration.md#project-configuration) config settings
1. user-command options or API function parameters


## Create the project space

Cider creates the project space as a child of the parent namespace.

The parent namespace is specified in the [`parent`](configuration.md#parent) setting of the project config, and must exist. (It is `#` by default, but could be something like `⎕SE` or `#.Foo.Goo`.) 
You can override the project setting with the `parent` option or parameter.

The name of the project space is specified in the [`projectSpace`](configuration.md#projectspace) setting of the project config, but you can override it with the `projectSpace` option or parameter.

If the project space does not exist, Cider creates it.

If neither the project space nor the project folder is empty, Cider proposes to empty the project space.
(If you say not, Cider signals an error.)


## Set system variables

Cider sets in the project space the values of `⎕IO` and `⎕ML` and any other system variables specified in the [`SYSVARS`](configuration.md#sysvars) section of the project config.

!!! detail "System variables have priority"

	System variables must be set before code is brought into the workspace because defining classes or namespaces potentially entails executing code that relies on them.

If a setting in `SYSVARS` cannot be used to set a system variable, Cider prints a warning message.

!!! tip "Set system variables in your source code"

	You can also set system variables in your source code in files like `⎕IO.apla`.

	System variables are set as early as possible.
	Link sets the values of system variables defined in files before it brings other code into the workspace.


## Define objects in the project space

Cider uses Link to find all files in the project’s `source` folder (and its children) with [supported file extensions](FIXME) and define them in the project space.

Cider links the project space to the project folder according to the [`watch`](configuration.md#watch) setting of the project config, which may be overridden by 

-   the `-watch=` or `import` options of [`]CIDER.OpenProject`](user-commands.md#open-project)
-   the `watch` or `importFlag` parameters of [`⎕SE.Cider.OpenProject`](api.md#open-project)

:fontawesome-solid-bomb:
Troubleshooting: [How link watches for changes](troubleshooting.md#how-link-watches-for-changes)


## Check for empty package folders

Cider checks whether any of the Tatin installation folders (specified in the `dependencies` and `dependencies_dev` settings of the project config) is empty apart from a dependency file and a build list.

??? detail "Why the checks"

	Since version 0.21.0 Cider itself has an enhanced `.gitignore` file: it defines that the contents of the Tatin installation folder(s) but the two definition files shall be ignored. Only these two definition files are therefore uploaded to GitHub, but _none of the packages_.

	So when somebody downloads the Cider project now _the Tatin installation folder contains just those two definition files but no packages!_

	Note this is in line with the majority of other package managers.

If a Tatin installation folder contains the two definition files but no packages, Cider will ask you if it should re-install the packages.


## Check for later package versions

If the project has Tatin packages installed in one or more folders, Cider proposes to check for later versions of any of the principal packages. (This will not happen only if `importFlag` is set.)

If Cider finds a later version of a package it proposes to update it.

!!! warning "Tatin registries only"

	The check is offered only for packages loaded from a Tatin registry that is in your config file _and_ has a priority greater than 0. 

:fontawesome-solid-book:
[Tatin documentation](https://tatin.dev/v1/documentation)


## Load Tatin packages

Cider loads required Tatin packages unless the user-command option `-noPkgLoad` or the API parameter `noPkgLoad` is used.

Required Tatin packages are specified in the `tatin` subkeys of the [`dependencies`](configuration.md#dependencies) and [`dependencies_dev`](configuration.md#dependencies-dev) settings in the project config.

The packages are loaded into the project space unless the subkeys specify another destination.


## Load NuGet packages

Cider loads required NuGet packages.

Required NuGet packages are specified in the `nuget` subkey of the [`dependencies`](configuration.md#dependencies) setting in the project config.

The packages are loaded into the project space unless the subkeys specify another destination.

!!! warning "NuGet packages and generics"

	The ability to load NuGet packages is most useful for loading your own NuGet packages, written in C#.

	Packages that use [generics](https://learn.microsoft.com/en-us/dotnet/standard/generics/) cannot be used, as Dyalog’s .NET interface does not support them.
	This restriction may be removed in a future release.

NuGet packages can be included your application, but not loaded only as development tools, as only a single installation folder may be specified. 
(This restriction may be removed in a later release.)


## Inject the project config

Cider injects a namespace `CiderConfig` into the project space and

-   populates it with the project config as an APL array
-   sets a variable `HOME` with the project path


## Inject a `TatinVars` namespace

A file `apl-package.json` in the project folder indicates the project is to produce a Tatin package.

If `apl-package.json` is found, Cider injects a namespace `TatinVars` into the project space.
So while you work on the project, you can access `TatinVars` as if it had been loaded as a package.

You would also expect a namespace `TatinVars` in the root of the _package_. That _might_ be the project space, but is more likely to be a child namespace.

If so, specify it in the optional setting `tatinVars` in the `CIDER` section of the project config.
Cider will then create a reference `TatinVars` in that namespace, pointing to `TatinVars` in the project space.


## Change the current working directory

If neither `import`, `importFlag` nor `batch` is set, Cider checks the current working directory. 

If it’s not the project folder, Cider proposes to change to it.


## Initialise the project

If the project config specifies an [initialisation](configuration.md#init) function, Cider executes it unless the `suppressInit` option or parameter is set.


## Execute the global initialisation function

If the global config specifies an [initialisation](configuration.md#executeafterprojectopen) function, it applies to __all__ your projects.

Cider executes it unless the `ignoreUserExec` option or parameter is set.


## Check for `ToDo`

If neither `import`, `importFlag` nor `batch` is set; and the project space contains a non-empty variable `ToDo`, Cider prints it.


## Report Git status

If 

-   neither `import`, `importFlag` nor `batch` is set; and
-   the project is version-controlled by Git; and
-   the global config setting `ReportGitStatus` is greater than 0

Cider reports the current branch and its status.

