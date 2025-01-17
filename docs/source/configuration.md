---
title: Configuring Cider
description: How to configure the global and project settings for Cider, the project manager for Dyalog APL software authors.
keywords: api, apl, cider, configuration, dyalog, key, link, setting, source, subkey, tatin
---

# Configuration

!!! abstract "Project settings, and settings that apply to all your projects"

## Global configuration

Cider’s global configuration settings apply to __all__ your projects. 

Non-default settings can be saved in a folder `.cider` in your home folder. 

For example, for user JohnDoe:

	Linux     /home/JohnDoe/.cider
	macOS     /Users/JohnDoe/.cider
	Windows   C:\Users\JohnDoe\.cider

The default name for the global configuration is  `config.json`.

Example:

```json
{
  AskForDirChange: 1,
  CheckForDropboxConflicts: 1,
  ExecuteAfterProjectOpen: "⎕SE.Path.To.Function",
  ReportGitStatus: 1,
  verbose: 1,
}
```

:fontawesome-solid-code:
[`GetCiderGlobalConfigFilename`](api.md#getciderglobalconfigfilename)<br>
:fontawesome-solid-code:
[`GetCiderGlobalConfigHomeFolder`](api.md#getciderglobalconfighomefolder)

This folder also contains

-   alias definitions in `aliases.txt`
-   your project template in `cider.config.template`


-----


### :fontawesome-solid-gear: `AskForDirChange`

On opening the first project in the current workspace

	0 - Take no action
	1 - Change the current directory to the project root (default)
	2 - Ask me if I want to change the directory



### :fontawesome-solid-gear: `CheckForDropboxConflicts`

If this flag is set, when opening and closing projects Cider will report files where the name contains the string "conflicted copy".

Absent this flag, if your home folder contains a folder `Dropbox/`, Cider will perform the check.

!!! detail "How Dropbox reports conflicts"

	If Dropbox cannot decide what the last version of a file is, it will create a file with "conflicted copy" in its name. Dropbox leaves it to you to compare such files and resolve the conflict. 

	Dropbox does not actually alert you to such conflicts, it just silently creates the files. So you can configure Cider to look for them.


:fontawesome-solid-terminal:
[`CIDER.CloseProject`](user-commands.md#close-project)<br>
:fontawesome-solid-terminal:
[`CIDER.OpenProject`](user-commands.md#open-project)<br>



### :fontawesome-solid-gear: `ExecuteAfterProjectOpen`

If defined and not empty, the fully qualified name of a monadic function. 

    ExecuteAfterProjectOpen: "⎕SE.Path.To.Function",


Cider will execute the function after you open __any__ project, unless the `ignoreUserExec` option or parameter is set.

The function’s argument is the project config as a namespace.
Any result it returns is ignored.

!!! tip "Use cases"

	Suppose you use a source code manager (SCM) other than Git. 
	With Git, Cider would execute the `status` command and show you the result.
	With another SCM, it does not know what to do.

	You can fix that: add the required code as a function you load early into `⎕SE`, then have `ExecuteAfterProjectOpen` call it.

	Or, your initialisation function couild bring in non-Tatin dependencies defined in the `dependencies` and/or the `dependencies_dev` settings.




### :fontawesome-solid-gear: `ReportGitStatus`

On opening a Git-controlled project without a clean working tree Cider reports its status acccording to the `ReportGitStatus` setting:

	0 - Don't report
	1 - Report in a read-only edit window (default)
	2 - Print it to the session
	3 - Ask me what to do

If the project path has no `.git` folder, or if the `batch` flag is set, nothing is reported.


### :fontawesome-solid-gear: `verbose`

Setting this flag increases the information Cider prints.

:fontawesome-solid-terminal:
[`]CIDER.OpenProject`](user-commands.md#open-project) and the `-verbose` option.



## Project configuration

When a Cider project is created, a copy of the file `cider.config.template` in the [global configuration folder](#global-configuration) is copied into the project root as `cider.config`.


The Cider configuration file comes with four sections: `CIDER`, `LINK`, `SYSVARS`, `USER`.


### `CIDER`

#### :fontawesome-solid-gear: `dependencies`

The setting has two subkeys: `tatin` and `nuget`:

```json
dependencies: {
    tatin: "tatin-packages",
    nuget: "nuget-packages",
},
```

The subkey `tatin` defaults to `"tatin-packages"`, which must be a folder in the project folder.

On opening a project Cider loads all Tatin and NuGet packages (installed in the project’s subfolders `tatin-packages` and `nuget-packages` respectively) into the project space.

To load the packages into child spaces of the project space, e.g. `Foo` and `Goo`:

```json
dependencies: {
    tatin: "tatin-packages=Foo",
    nuget: "nuget-packages=Goo",
}
```

Cider will ignore any other subkeys of `dependencies`.


#### :fontawesome-solid-gear: `dependencies_dev`

As for `dependencies`, but with dependencies required only for development and testing, not for producing the final package or application.

These dependencies are usually loaded into a child of the project space:

```json
dependencies_dev: {
    tatin: "tatin-packages_dev=Testcases",
}
```

Above, all packages in folder `tatin-packages_dev` (a child of the project folder) are loaded into the  space `Testcases`, a child of the project space.

??? warning "There is no  `nuget` subkey in `dependencies_dev`."

	This restriction may be removed in a future release.


#### :fontawesome-solid-gear: `distributionFolder`

The default destination for the ZIP file produced by Tatin’s `BuildPackage` function: either empty or the path to a folder, usually relative to the project root.
There is no default. 

If you always create your package ZIP files in the same  child folder of each project, define this in the project config template file.


#### :fontawesome-solid-gear: `init`

Empty, or the name of a function in the project space.

After the project is opened or imported, the function will be executed.

The function may be niladic, monadic or ambivalent.
Any right argument is the project config as a namespace.

Any result should be shy.


#### :fontawesome-solid-gear: `make`

Empty, or an expression (relative to the project) that would create a new version.

See how to create a new version of the project, e.g.

```
      ]Cider.Make
#.Cider.Admin.Make 1 ⍝ Execute this for creating a new version
```

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.make`, and the comment then added.

However, if the first non-white space character of `make` is a `]`, its definition would just be printed to the session together with a comment because then it is obviously a user command.


#### :fontawesome-solid-gear: `parent`

__Required.__
Fully-qualified name of the parent of the project space.
Defaults to `#` but could be e.g. `⎕SE` or `#.MyNamespace1.MyNamespace2`.

If the namespace does not exist when the project is opened, Cider signals an error.

Example settings:

```json
{
  CIDER: {
    …
    parent: "#",
    projectSpace: "myproj",
    …
    source: "APLSource",
  },
  …
}
```

The user command and API function can override this setting, e.g.

	]CIDER.OpenProject {path} -parent=#.MyProjects


#### :fontawesome-solid-gear: `projectSpace`

__Required.__
Name of the namespace that will contain the project.

The user command and API function can override this setting, e.g.

	]CIDER.OpenProject {path} -projectspace=Foo


#### :fontawesome-solid-gear: `project_url`

Empty, or the URL of, say, a GitHub project. For information only.

Cider includes the [`APLGit2`](https://github.com/aplteam/APLGit2) package, an interface between Dyalog and Git, although some of its commands work only when the project is hosted on GitHub.

Some functions of `APLGit2` must know the `owner` of a project on GitHub. 
Those functions will investigate `project_url`. 
If it points to GitHub, the owner is established from its contents.


#### :fontawesome-solid-gear: `source`

Path (relative to the project folder) of the folder that contains all its APL code.
Defaults to `APLSource`.

This could be empty, for example, if the project is a single script (class or namespace) in the project root.

Note that this might differ from the Tatin `source` parameter, which could point to a child folder of Cider's `source` containing just the code that is a package. Cider’s `source` could also contain test cases, development tools, and other things.


#### :fontawesome-solid-gear: `tatinVars`

Optional. Either `⎕THIS` or the name of a child of the project space.

-   `⎕THIS` has the same effect as if the property were undefined.
-   A subnamespace has Cider inject a reference `TatinVars` into it, pointing to `TatinVars` in the project root.

See [Injecting a namespace `TatinVars`](open-project.md#inject-a-tatinvars-namespace).


#### :fontawesome-solid-gear: `tests`

Empty, or an expression (relative to the project) that would execute the test cases of the project.

See how to execute the test cases, e.g.

```
      ]Cider.RunTests
#.Cider.TestCases.RunTests 
```
Above, execute `#.Cider.TestCases.RunTests` to run the test suite.

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.tests`, and the comment added.

However, if the first non-white space character of `tests` is a `]` (making it a user command rather than a function call), its definition would just be printed to the session together with a comment.


### `LINK`

These parameters are passed to Link when Cider uses it to define APL objects in the workspace.

Since Version 4.0.0, Link has its own config file, but, until all supported versions of Link deal with it, Cider saves non-default values in a Cider project config.

Cider looks for `.linkconfig` at the path specified in [`source`](#source);
if `source` is empty, then the root of the project.

As of Cider version 0.46.0,
if Cider finds a Link config file, it ignores the `LINK` section of its config
and reminds you to delete it.

But if the Link config file contains only stop and trace vectors and the Link version number,
then Cider will use its `LINK` section settings, and recommend you

-   reconcile the two sources of Link options
-   delete the `LINK` section from the Cider config file.


#### :fontawesome-solid-gear: `watch`

Which source/s to watch for changes to linked APL definitions. Changes in one environment (workspace or file) can be synchronised with the other according to this setting.

	ns   - watch the active workspace
	dir  - watch the file definitions
	both - watch both (default)
	none - watch neither

<!-- 
Irrelevant: we assume Link is installed
Note that for "both" and "dir," .NET or .NET Core is required. Under Windows, this is a given, but not so on Linux and Mac-OS: it may or may not be available. If it is not, the default for "watch" will be "ns".
 -->

The `watch` setting is very important, so Cider always reports it. 
Other Link settings are reported only when they diverge from the default.

The `watch` setting is ignored when a project is opened with the `import` option.

:fontawesome-solid-book:
[`Link.Create`](https://dyalog.github.io/link/4.0/API/Link.Create/#watch)


### `SYSVARS`

This section lets set system variables. 
`⎕IO` and `⎕ML` should always be set explicitly.
(They default to 1.)

You can set other system variables here like, say, `⎕CT` as `ct`, and so on.

System variable names are case-insensitive.


### `USER`

In this section you can set your own project-specific values. 
Cider ignores them.

For example

```json
USER: {
   "Foo": 1,
},
```

After opening the project into, say, `#.MyProject`, the setting is accessible:

	#.MyProject.CiderConfig.USER.Foo




