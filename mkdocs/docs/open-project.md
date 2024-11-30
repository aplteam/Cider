# Open project

!!! abstract "The detail of what happens when you open a project"

The actions of opening a project are modified by configuration settings and by user-command options and API function parameters.
In ascending priority:

1. global configuration settings
1. project configuration settings
1. user-command options or API function parameters


:fontawesome-solid-gear: &nbsp;
[Global](configuration.md#global-configuration) and [project](configuration.md#project-configuration) configurations<br>
:fontawesome-solid-terminal: &nbsp;
User command [`OpenProject`](user-commands.md#open-project)<br>
:fontawesome-solid-code: &nbsp;
API function `OpenProject` [parameters](api.md#parameters) 

## Create the project space

Create a child namespace within the parent namespace, which must exist.

The parent namespace is specified in the [`parent`](configuration.md#parent) setting of the project config. (It is `#` by default, but could be something like `⎕SE` or `#.Foo.Goo`.) 
You can override the project setting with 

-   the user-command option `-parent=`
-   the API parameter] `parent`

The name of the project space is specified in the [`projectSpace`](configuration.md#projectspace) setting of the project config, but  you can override it with

-   the user-command option `-projectSpace=`
-   the API parameter `projectSpace`

If the project space does not exist, Cider creates it.

If neither the project space nor the project folder is empty, Cider asks you whether it can empty the project space.
If you say not, Cider signals an error.


## Set system variables

Cider sets in the project space the values of `⎕IO` and `⎕ML` and any other system variables specified in the [`SYSVARS`](configuration.md#sysvars) section of the project config.

!!! detail "System variables have priority"

	These variables must be set before code is brought into the workspace because defining classes or namespaces potentially entails executing code which might rely on them.

If a setting in `SYSVARS` cannot be used to set a system variable, a warning message is printed in the session.

!!! tip "Set system variables in your source code"

	You can also set system variables in your source code in files like `⎕IO.apla`.

	System variables are set as early as possible.
	Link sets the values of system variables defined in files before it brings other code into the workspace.


## Define objects in the project space

Cider uses Link to find all files in the project’s `source` folder (and its children) with [supported file extensions](FIXME) and define them in the project space.

Cider links the project space to the project folder according to the [`watch`](configuration.md#watch) setting of the project config, which may be overridden by 

-   the `-watch=` or `import` options of the user command
-   the `watch` or `importFlag` parameters of the API function


## Check for empty package folders

Cider checks whether any of the Tatin installation folders (specified in the `dependencies` and `dependencies_dev` settings of the project config) is empty apart from a dependency file and a build list.

??? detail "Why the checks"

	Since version 0.21.0 Cider itself has an enhanced `.gitignore` file: it defines that the contents of the Tatin installation folder(s) but the two definition files shall be ignored. Only these two definition files are therefore uploaded to GitHub, but _none of the packages_.

	So when somebody downloads the Cider project now _the Tatin installation folder contains just those two definition files but no packages!_

	Note this is in line with the majority of other package managers.

If a Tatin installation folder contains the two definition files but no packages, Cider will ask you if it should re-install the packages.


## Check for later package versions

If the project has Tatin packages installed in one or more folders, Cider will ask you whether it should check for any later versions of any of the principal packages. (This will not happen only if `importFlag` is set.)

If Cider finds a later version of a package it will ask you whether it should update it.

!!! warning "Tatin registries only"

The check is offered only for packages loaded from a Tatin registry that is in your config file _and_ has a priority greater than 0. 

:fontawesome-solid-book:
[Tatin documentation](https://tatin.dev/v1/documentation)


## Load Tatin packages

Cider loads required Tatin packages unless the user-command option `-noPkgLoad` or the API parameter `noPkgLoad` is used.

Required Tatin packages are specified in the `tatin` subkeys of the [`dependencies`](configuration.md#dependencies) and [`dependencies_dev`](configuration.md#dependencies-dev) settings in the project config.

The packages are loaded into the project space unless the subkeys specify another destination.


## Loading NuGet packages

Your application or tool might depend on a NuGet[^nuget] package. By assigning a folder hosting NuGet packages to the `nuget` sub-key in `dependencies` you can make sure that Cider will load those installed packages into the root of your project or the assigned sub-namespace.

> On NuGet packages
>
> Note that for the time being the ability to load NuGet packages is most useful for loading your own NuGet packages written in C#.
>
> Beyond that, it depends on whether the package uses [generics](https://learn.microsoft.com/en-us/dotnet/standard/generics/). Many packages do, and that makes them unusable for the time being, because Dyalog's .NET interface does not support generics right now.
>
> However, this restriction of the .NET interface is likely to be lifted in a future release.

See the config property `dependencies` details.

Note that NuGet packages can currently become part of your application, but they cannot be loaded as development tools. This restriction is likely to be lifted in a later release of Tatin.

## Injecting a namespace `CiderConfig`

In this step `]Cider.OpenProject` injects a namespace `CiderConfig` into the project space and...

* populates it with the contents of the configuration file as an APL array
* adds a variable `HOME` that remembers the path the project was loaded from

## Injecting a namespace `TatinVars`

Whether a project is going to be a package depends on the presence of a file `apl-package.json` in the root of the project.

If such a file is present, Cider injects a namespace `TatinVars` into the root of the project, containing exactly the same pieces of information as if it were loaded as a package. This allows a developer to access `TatinVars` as if it was loaded as a package while working on the project.

However, a programmer would expect a namespace `TatinVars` in the root of the _package_. That might be the root of a project, but it might as well be a _sub-namespace_ of the project. In fact, that is more likely.

This can be addressed by adding the optional property "tatinVars" into the `CIDER` section of the Cider config file, holding the name of a sub-namespace that will eventually become the package. 

If a property "tatinVars" does exist and points to a sub-namespace, then Cider will create a reference `TatinVars` in that namespace that points to `TatinVars` in the root of the project.

## Changing the current directory

If the project was opened (rather than imported!) **_and_** `batch` is 0, then Cider checks at this point the current (or working) directory. If it's different from the project's directory, the user is asked whether she wants to change the current directory to the project's directory.

## Initialising a project

There might well be demand for executing some code to initialise your project.

This can be achieved by assigning the name of a function to `init`. The name must be relative to the root of your project.

The function will be executed unless `suppressInit` is 1.

The function should not return a result. If it does anyway it should be shy. Any result would be ignored.

Such a function may be niladic, monadic, ambivalent or dyadic:

* A monadic function receives a namespace with the project configuration as the right argument
* A dyadic or ambivalent function receives in addition the parameter space passed to `OpenProject`

Note that such a function will be executed no matter whether the project was opened or imported.

## Executing user-specific code

You might want to execute some general code (as opposed to project-specific code) after a project was opened (rather than imported). "General" means that this code is executed whenever a project (any project!) is opened. 

You can suppress the execution of such a function by setting `ignoreUserExec` to 1.

This can be achieved by specifying the fully qualified name of a function that must be monadic, most likely in `⎕SE`. A namespace with the configuration data of the project is passed as the right argument.

The function may or may not return a result, but when it does the result will be discarded.

The fully qualified name of the function must go into the file that is returned by the function `GetCiderGlobalConfigFilename`, which is available only via the API, not as a user command. This is the global Cider config file, not a Cider project config file.

That file already contains a definition of the keyword `ExecuteAfterProjectOpen`, but it is empty:

```json
{
    ExecuteAfterProjectOpen: "",
}
```

What is this application for you may ask? Well, let's assume that you are not using Git but a different version control software. With Git, Cider would execute the "status" command and show the result to the user. With your version control software, it can't do something similar because it does not know what to do.

You can easily achieve that by yourself: just add the required code to a function you load early into `⎕SE`, and then make sure that `ExecuteAfterProjectOpen` is calling that function and you are done.

Another application could be to bring in non-Tatin dependencies defined in the `dependencies` and/or the `dependencies_dev` properties.

Note that you may use the `ignoreUserExec` flag to tell `OpenProject` to ignore the global setting. This is certainly useful when Cider's test suite is executed.

## Check for `ToDo`

If the project was opened (rather than imported!) **_and_** `batch` is 0, then Cider checks whether there is a variable `ToDo` in the root of your project that is not empty. If that's the case then the contents of that variable is printed to the session.

You may use this to keep track of:

* Steps that need to be executed before the project can be committed or published etc.
* A variable, config property, or setting that has just been deprecated, but should be removed with the next major release.
* Or anything else you might want to note.

## Git Status

If the project was opened (rather than imported!) **_and_** the project is version-controlled by Git **_and_** `batch` is 0 **_and_** the global configuration parameter `ReportGitStatus` is greater than 0, then Cider will report the current branch and its status.

