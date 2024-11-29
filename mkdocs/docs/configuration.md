# Configuration

## Global configuration

Cider’s global configuration settings affect _all_ your projects. 

Non-default settings can be saved in a folder `.cider` in your home folder. 

For example, for user JohnDoe:

	Linux     /home/JohnDoe/.cider
	macOS     /Users/JohnDoe/.cider
	Windows   C:\Users\JohnDoe\.cider

The default name for the global configuration is  `config.json`.

:fontawesome-solid-code:
[`GetCiderGlobalConfigFilename`](api.md#getciderglobalconfigfilename)<br>
:fontawesome-solid-code:
[`GetCiderGlobalConfigHomeFolder`](api.md#getciderglobalconfighomefolder)

This folder also contains

-   alias definitions in `aliases.txt`
-   project template in `cider.config.template`


### :fontawesome-solid-gear: `AskForDirChange`

On opening the first project in the current workspace

	0 - Take no action
	1 - Change the current directory to the project root (default)
	2 - Ask me if I want to change the directory



### :fontawesome-solid-gear: `CheckForDropboxConflicts`

If this flag is set, when opening and closing projects Cider will report files where the name contains the string "conflicted copy".

!!! detail "How Dropbox reports conflicts"

	If Dropbox cannot decide what the last version of a file is, it will create a file with "conflicted copy" in its name. Dropbox leaves it to you to compare such files and resolve the conflict. 

	Dropbox does not actually alert you to such conflicts, it just silently creates the files. So you can configure Cider to look for them.


:fontawesome-solid-terminal:
[`CIDER.CloseProject`](user-commands.md#close-project)<br>
:fontawesome-solid-terminal:
[`CIDER.OpenProject`](user-commands.md#open-project)<br>



### :fontawesome-solid-gear: `ExecuteAfterProjectOpen`

If defined and not empty, the fully qualified path to a monadic function. That function will be executed by Cider after you open any project.

<!-- FIXME filepath or fully qualified name? -->

The function’s argument is a namespace containing the project’s config.

Any result the function returns is ignored.


### :fontawesome-solid-gear: `ReportGitStatus`

On opening a Git-controlled project without a clean working tree Cider reports its status acccording to the `ReportGitStatus` setting:

	0 = Don't report
	1 = Report in a read-only edit window (default)
	2 = Print it to the session
	3 = Ask me what to do

If the project root contains no `.git/` folder or the `batch` flag is set, nothing is reported.


### :fontawesome-solid-gear: `verbose`

Setting this flag increases the information Cider prints.

:fontawesome-solid-terminal:
[`]CIDER.OpenProject`](user-commands.md#open-project) and the `-verbose` option.


## Project configuration

When a Cider project is created, a copy of the file `cider.config.template` in the [global configuration folder](#global-configuration) is copied into the project root as `cider.config`.


The Cider configuration file comes with four sections: `CIDER`, `LINK`, `SYSVARS`, `USER`.


### `CIDER`

#### :fontawesome-solid-gear: `distributionFolder`

The default destination for the ZIP file produced by Tatin’s `BuildPackage` function: either empty or the path to a folder, usually relative to the project root.
There is no default. 

If you always create your package ZIP files in the same  child folder of each project, define this in the project config template file.


#### :fontawesome-solid-gear: `parent`

Fully-qualified name of the project’s parent namespace: defaults to `#` but could be e.g. `⎕SE` or `#.MyNamespace1.MyNamespace2`.

If the namespace does not exist when the project is opened an error is signalled.

The user command can override this setting, e.g.

	]Cider.OpenProject {path} -parent=#.MyProjects


#### :fontawesome-solid-gear: `projectSpace`

Name of the namespace that will contain the project: must be in the project config file.

The user command can override this setting, e.g.

	]Cider.OpenProject {path} -projectspace=Foo


#### :fontawesome-solid-gear: `source`

Path (relative to the project root) of the folder that contains all its APL code.
Defaults to `APLSource`.

This could be empty, for example, if the project is a single script (class or namespace) in the project root.

Note that this might differ from the Tatin `source` parameter, which could point to a child folder of Cider's `source` containing just the code that is a package. Cider’s `source` could also contain test cases, development tools, and other things.


#### :fontawesome-solid-gear: `dependencies`

This has two subkeys: `tatin` and `nuget`:

```json
dependencies: {
    tatin: "tatin-packages",
    nuget: "nuget-packages",
},
```

The subkey `tatin` defaults to `"tatin-packages"`, which must be a folder in the project root the resulting package or application depends on. 

On opening a project Cider loads all Tatin and NuGet packages installed in the project’s subfolders `tatin-packages` and `nuget-packages` respectively into the project namespace.

To have the packages loaded into a child spaces of the project namespace, e.g. `Foo` and `Goo`:

```json
dependencies: {
    tatin: "tatin-packages=Foo",
    nuget: "nuget-packages=Goo",
}
```

Cider will ignore any other subkeys of `dependencies`.


#### :fontawesome-solid-gear: `dependencies_dev`

As for `dependencies`, but with dependencies required only for development and testing, not for producing the final package or application.

These dependencies are more often than not loaded into a sub-namespace of the project:

```json
dependencies_dev: {
    tatin: "tatin-packages_dev=Testcases",
}
```

All packages in the subfolder `tatin-packages_dev/` are loaded into the subnamespace `Testcases`.

!!! warning "No `nuget` subkey"

	You cannot have a subkey `nuget` in `dependencies_dev`.

	This restriction may be removed in a future release.


#### :fontawesome-solid-gear: `init`

Empty, or the name of a function in `projectSpace`. 

After the project is opened or imported, the function will be executed.

The function may be niladic, monadic or ambivalent:

-   A niladic function is just called
-   The right argument to an ambivalent or monadic function is the project configuration as a namespace

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


#### :fontawesome-solid-gear: `project_url`

Empty, or the URL of, say, a GitHub project. For information only.

Note that Cider includes the [`APLGit2`](https://github.com/aplteam/APLGit2) package. 
`APLGit2` is an interface between Dyalog and Git, although some of its commands will only work when the project is hosted on GitHub.

Some functions of `APLGit2` must know the `owner` of a project on GitHub. Those functions will investigate `project_url`: if that points to GitHub, the owner is established from its contents.


#### :fontawesome-solid-gear: `tatinVars`

Optional. If defined, either `⎕THIS` or the name of a subnamespace of the project.

-   `⎕THIS` has the same effect as if the property were undefined.
-   A subnamespace has Cider inject a reference `TatinVars` into it, pointing to `TatinVars` in the project root.

See [Injecting a namespace TatinVars](FIXME).


#### :fontawesome-solid-gear: `tests`

Empty, or an expression (relative to the project) that would execute the test cases of the project.

See how to execute the test cases, e.g.

```
      ]Cider.RunTests
#.Cider.TestCases.RunTests ⍝ Execute this for running the test suite
```

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.tests`, and the comment added.

However, if the first non-white space character of `tests` is a `]` (making it a user command rather than a function call), its definition would just be printed to the session together with a comment.


### `LINK`

These parameters are passed to Link when Cider uses it to define APL objects in the workspace.

??? info "Temporary solution"

	LINK should have its own config files for this, and will get them with Link 4.0. 

	However, until all supported versions of Link can deal with Link's own configuration file, Cider will save non-default values in a Cider project config file.

	If there is a Link config file by the name `.linkconfig`, then any definition in the `LINK` section of the Cider config file is ignored. A message will remind you to delete the `LINK` section from the Cider config file.

	Cider will look for the file in what [`source`](#) defines. If `source` is empty then it is the root of the project.

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

The `watch` setting is very important, so Cider always reports it. Other Link settings are reported only when they diverge from the default.

The `watch` setting is ignored when a project is opened with the `import` option.


### `SYSVARS`

This section lets you to set system variables. 
`⎕IO` and `⎕ML` should always be set explicitly.

You can set other system variables here like, say, `⎕CT` as `ct`, and so on.
(They default to 1.)


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






*[Dropbox]: A file-sharing service
