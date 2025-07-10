---
title: Cider’s API functions
description: Complete reference to the Cider API, which lets you call the Dyalog APL project manager from your own code.
keywords: api, apl, cider, dyalog, link, nuget, parameter, source, tatin
---

# API functions

!!! abstract "With the Cider API you can write DevOps scripts in APL."

The API functions are similar to the [user-commands](user-commands.md), but not identical.
Not all have equivalent user commands.


[AddAlias](#add-alias)                            [GetMyUCMDsFolder](#get-ucmds-folder)
[AddNuGetDependencies](#add-nuget-dependencies)                [GetNuGetDependencies](#get-nuget-dependencies)
[AddTatinDependencies](#add-tatin-dependencies)                [GetProgramFilesFolder](#get-program-files-folder)
[CloseProject](#close-project)                        [GetTatinDependencies](#get-tatin-dependencies)
[CreateCreateProjectParms](#create-createproject-parms)            [HasDotNet](#has-dotnet)
[CreateOpenParms](#create-open-parms)                     [ListNuGetDependencies](#list-nuget-dependencies)
[CreateProject](#create-project)                       [ListOpenProjects](#list-open-projects)
[DropAlias](#drop-alias)                           [ListTatinDependencies](#list-tatin-dependencies)
[GetCiderAliasFileContent](#get-alias-file-content)            [OpenProject](#open-project)
[GetCiderAliasFilename](#get-alias-filename)               [ProjectConfig](#project-config)
[GetCiderGlobalConfigFileContent](#get-global-config-file-content)     [ReadProjectConfigFile](#read-project-config-file)
[GetCiderGlobalConfigFilename](#get-global-config-filename)        [WriteProjectConfigFile](#write-project-config-file)
[GetCiderGlobalConfigHomeFolder](#get-global-config-home-folder)      [Version](#version)
{: .typewriter}

Unlike user commands, API function names are case-sensitive.

The API is exposed in `⎕SE.Cider` so, for example, call `AddAlias` as `⎕SE.Cider.AddAlias`.

??? warning "API code cache"

    The Cider code package is loaded into `⎕SE._Cider`, but the API is exposed via `⎕SE.Cider`.

    Do not call functions in `⎕SE._Cider`.


---

## :fontawesome-solid-code: Add alias

    {r}←AddAlias(projectpath alias)

Where

-   `projectpath` is a project path
-   `alias` is a string with no punctuation or spaces

if the project folder exists the alias is registered in the file returned by [`GetCiderAliasFilename`](#get-alias-filename).
The shy result is an error message, empty if successful.

If the alias is already in use Cider asks you to confirm the change.


## :fontawesome-solid-code: Add NuGet dependencies

    list←AddNuGetDependencies(packages project)

Where

-   `packages`is one or more NuGet packages
-   `project` is an alias or project path

Cider installs NuGet packages in the (single) NuGet dependency folder defined in the project config and returns their names as a list of strings.

Specify `packages` as either a list of strings or a comma-separated string.

!!! warning "NuGet package names"

    NuGet package names are not case sensitive when they are loaded so, for example, you can load `Clock` by the name `clock`.

    However, the correct name is returned, and is required for using a package.

:fontawesome-solid-terminal:
[`]CIDER.AddNugetDependencies`](user-commands.md#add-nuget-dependencies)


## :fontawesome-solid-code: Add Tatin dependencies

    r←AddTatinDependencies(packages project dev)

Where

-   `packages` is one or more Tatin packages
-   `project` is a project path
-   `dev` is a flag
<!-- ISSUE #99:
-  `project` is a project path or alias
-->

Cider installs the packages in one of the Tatin dependency folders
and returns as a list of strings the names of the packages installed.

Specify `packages` as either a list of strings or a comma-separated string.

Any errors are reported to the session.

Setting the `dev` flag switches the installation folder from `dependencies` (default) to`dependencies_dev`.


```apl
      pkgs←'rikedyp-TinyTest,boobly-boo'
      proj←'/Users/sjt/Projects/dyalog/examples/stat'
      ⍴⎕←⎕SE.Cider.AddTatinDependencies pkgs proj 1
Not found: boobly-boo
┌──────────────────────┐
│rikedyp-TinyTest-1.0.1│
└──────────────────────┘
1

```

??? detail "Dependency folders"

    The dependency folders are defined in the project’s configuration file.

    The default project configuration file name is `dependencies.tatin`.

:fontawesome-solid-terminal:
[`]CIDER.AddTatinDependencies`](user-commands.md#add-tatin-dependencies).



## :fontawesome-solid-code: Close project

    r←{performChecks} CloseProject projects

Where

<!-- -   `x` (optional) is a list of projects and/or a flag -->
-   `performChecks` (optional) is whether to check for Dropbox conflicts (default is 1)
-   `projects` is
    -   one or more open projects
    -   an empty vector (all open projects)

Cider closes the projects (unlinks the source files) and returns the number of projects closed.

Identify projects as (any of)

-   fully qualified namespace names
-   aliases
-   project paths

<!-- see Issue #100
The __optional left argument__ can be either or both (in any order) of

-   a list of projects as returned by [`ListOpenProjects`](#list-open-projects)
-   a flag (defaults to 1): whether Dropbox conflict checks are made.

 -->
Example: close all open projects.
```apl
⎕SE.Cider.CloseProject ⍬
```
Example: close three projects without checking for Dropbox conflicts.
```apl
0 ⎕SE.Cider.CloseProject 'path/to/project' #.util '[test]'
```

:fontawesome-solid-gear:
[`CheckForDropboxConflicts`](configuration.md#checkfordropboxconflicts)<br>
:fontawesome-solid-terminal:
[`]CIDER.CloseProject`](user-commands.md#close-project)


## :fontawesome-solid-code: Create `CreateProject` parms

    parms←{parms} CreateCreateProjectParms folder

Where

-   `parms` (optional) is a namespace of parameters
-   `folder` is a project path

Cider returns a namespace with parameters required by [`CreateProject`](#create-project), by default:

    acceptConfig   - 0
    folder         - project path
    ignoreUserExec - 0
    namespace      - name of the project folder

Defaults are overwritten by any specified in the `parms` argument.

:fontawesome-solid-terminal:
[`]CIDER.CreateProject`](user-commands.md#create-project)


## :fontawesome-solid-code: Create Open parms

    parms←CreateOpenParms y

Where `y` is either an empty vector or a namespace of parameters, returns a namespace of parameters required by the `OpenProject` function.

Parameters in `y` overwrite the defaults, which are:

    alias                 ''
    batch                 0
    checkPackageVersions  ⍬
    folder                ''
    ignoreUserExec        0
    importFlag            0
    noPkgLoad             0
    parent                ''
    projectSpace          ''
    suppressInit          0
    verbose               0
    watch                 0

!!! detail "Setting `watch` to 0 shows Cider you have not set it. Eventually 0 becomes `both`, the default."


## :fontawesome-solid-code: Create project

    r←CreateProject parms

Where `parms` is a namespace of parameter values, typically the result of [`CreateCreateProjectParms`](#create-createproject-parms), Cider creates a project.

:fontawesome-solid-terminal:
[`]CIDER.CreateProject`](user-commands.md#create-project)


## :fontawesome-solid-code: Drop alias

    {flag}←DropAlias alias

Where `alias` is a project alias, Cider removes it from the file named by `GetCiderAliasFilename` and returns a flag indicating success.


## :fontawesome-solid-code: Get alias file content

    r←{filename} GetCiderAliasFileContent dummy

Cider ignores `dummy` and returns as a matrix of strings the contents of the file named by `GetCiderAliasFilename`.

```
      ⍴⎕←⎕SE.Cider.GetCiderAliasFileContent 'blah'
┌───┬──────────────────┐
│bar│/Users/sjt/tmp/foo│
└───┴──────────────────┘
1 2
```

If the file is empty the result has zero rows.

:fontawesome-solid-terminal:
[`]CIDER.ListAliases`](user-commands.md#list-aliases)



## :fontawesome-solid-code: Get alias filename

    filename←GetCiderAliasFilename

Returns the path to the file used to record alias names and their paths.



## :fontawesome-solid-code: Get global config file content

    parms←GetCiderGlobalConfigFileContent

Cider returns the [global config](configuration.md#global) – if found – as a parameter namespace; otherwise the result is `⍬`.

:fontawesome-solid-terminal:
[`]CIDER.Config`](user-commands.md#config)


## :fontawesome-solid-code: Get global config filename

    path←GetCiderGlobalConfigFilename

Returns the path to Cider’s global config file.


## :fontawesome-solid-code: Get global config home folder

    path←GetCiderGlobalConfigHomeFolder

Returns the path to the parent folder of Cider’s global config file.

On Windows, this is typically `C:/Users/<⎕AN>/.cider/config.json`



## :fontawesome-solid-code: Get MyUCMDs folder

    path←GetMyUCMDsFolder

Returns the path to the `MyUCMDs/` folder.

!!! warning "The folder might not exist :fontawesome-brands-linux: :fontawesome-brands-apple:"

    On Windows, this folder is created by the installer.
    Not so on other platforms.


## :fontawesome-solid-code: Get NuGet dependencies

    r←name GetNuGetDependencies config

Where

-   `name` is `'development'` or `'development_dev'`
-   `config` is a parameter namespace

returns either the value of `nuget` in the given branch or an empty vector if `nuget` is not defined.

The `config` argument is typically derived from a project’s configuration file.

:fontawesome-solid-terminal:
[`]CIDER.ListNuGetDependencies`](user-commands.md#list-nuget-dependencies)



## :fontawesome-solid-code: Get Program Files folder

    path←{current}GetProgramFilesFolder suffix

Where

-   `current` (optional) is a flag
-   `suffix` is a suffix to the folder filepath

returns the path to the Dyalog files folder with any `suffix` specified.

The `current` flag (default 0) specifies whether the result is specific to the currently running version of Dyalog.


```
      ⍝ Version agnostic
      ⎕SE.Cider.GetProgramFilesFolder ''
C:\Users\kai\Documents\Dyalog APL Files
      Cider.GetProgramFilesFolder 'CiderTatin'
C:\Users\kai\Documents\Dyalog APL Files/CiderTatin

      ⍝ Version specific
      1 ⎕SE.Cider.GetProgramFilesFolder ''
C:\Users\kai\Documents\Dyalog APL-64 18.2 Unicode Files
```


## :fontawesome-solid-code: Get TatinD dependencies

    r←name GetTatinDependencies config

Where

-   `name` is `'development'` or `'development_dev'`
-   `config` is a parameter namespace

returns either the value of `tatin` in the given branch or an empty vector if `tatin` is not defined.

The `config` argument is typically derived from the project config.



## :fontawesome-solid-code: Has DotNet

    flag←HasDotNet

Result indicates whether .NET Core or .NET is available and the bridge DLL was successfully loaded.


## :fontawesome-solid-code: List NuGet dependencies

    r←ListNuGetDependencies projectPath

Where `projectPath` is a project path, returns a matrix of names and versions of its NuGet dependencies.


## :fontawesome-solid-code: List open projects

    r←ListOpenProjects verbose

Where `verbose` is a flag, returns the open projects as a matrix of 2 or 4 columns:

1. Fully qualified project namespace
1. Path the project was loaded from
1. Number of objects belonging to the project
1. Alias (if any)

```
      ⎕SE.Cider.ListOpenProjects 0
 #.Cider  /path/to/Cider

      ⎕SE.Cider.ListOpenProjects 1
 #.Cider  /path/to/Cider  32  cider
```

:fontawesome-solid-terminal:
[`]CIDER.ListOpenProjects`](user-commands.md#list-open-projects).


## :fontawesome-solid-code: List Tatin dependencies

    r←ListTatinDependencies projectpath

Where `projectpath` is a project path, returns as a 5-column matrix the dependencies installed in the Tatin installation folders.

1. dependency folder
1. full package ID
1. flag: whether the package is a principal or a dependency
1. URL from which the package was loaded
1. (reserved)

```apl
      ⍉r←⎕SE.Cider.ListTatinDependencies '[stat]'
┌───────────────────┬───────────────────────┐
│tatin-dependencies/│tatin-dependencies_dev/│
├───────────────────┼───────────────────────┤
│ davin-Tester-1.1.0│ rikedyp-TinyTest-1.0.1│
├───────────────────┼───────────────────────┤
│1                  │1                      │
├───────────────────┼───────────────────────┤
│https://tatin.dev/ │https://tatin.dev/     │
├───────────────────┼───────────────────────┤
│                   │                       │
└───────────────────┴───────────────────────┘
      r[;5]≡' ' ' '
1
```

!!! detail "Until Cider version 0.34.0 this was named `ListTatinPackages`"

:fontawesome-solid-terminal:
[`]CIDER.ListTatinDependencies`](user-commands.md#list-tatin-dependencies).



## :fontawesome-solid-code: Open project

    (flag log)←OpenProject y

Where `y` is either

-   an alias or project path
-   a parameter namespace (typically created by  `CreateOpenParms`)

Cider [opens the project](open-project.md), and returns a 2-item result: a flag for success, and a log string as printed to the session.

```apl
      (flag log)←⎕SE.Cider.OpenProject '[stat]'
The current directory is now ...
      flag
1
      (≡log)(≢log)
1 388
```

If `y` is a parameter space, all parameters are optional except `folder`.


`folder`

: String. Alias or project path. May not be empty, but could be `./` indicating the current directory.

`alias`

: String. An alias by which you can refer to the project.

    !!! detail "Special syntax for alias"

        If `alias` is just a dot, the name of the project folder becomes the alias.
        Example:

        ```apl
        p←⎕SE.Cider.CreateOpenParms
        p.folder←'/path/2/projects/foo'
        p.alias←'.'  ⍝ `foo` becomes the (new) alias
        ```

    **Side effect**
    Cider will register the new alias for the project.

    Example: Open project aliased as `foo` and reregister its alias as `bar`:
    ```apl
    p←⎕SE.Cider.CreateOpenParms
    p.folder←'[foo]'
    p.alias←'bar'
    ```

`checkPackageVersions`

: By default Cider proposes to check principal packages for later versions and, if found, to update them.

        ⍬ - Ask me whether to check (default)
        0 - Do not check at all
        1 - Check and report findings but prompt for updating
        2 - Check and update without consulting me

    This parameter is ignored if the project has no Tatin installation folder, or if `importFlag` is set.


`ignoreUserExec`

: Flag to stop Cider executing at the end of opening a project a function named in the global  [`ExecuteAfterProjectOpen`](configuration.md#executeafterprojectopen) setting. Defaults to 0.


`importFlag`

: Flag to stop Cider from linking APL objects to their source files. Defaults to 0.

    :fontawesome-solid-gear:
    [`watch`](configuration.md#watch)

    !!! warning "Setting this flag has implications for how Cider deals with Tatin packages."
<!-- Explain.
, see there.
 -->

`noPkgLoad`

: Flag to stop Cider from loading Tatin dependencies as specifed in the config file’s `dependencies` and `dependencies_dev` settings. Defaults to 0.


`parent`

: String. Defaults to `#` but could be something like `⎕SE` or `#.Foo.Goo.Boo`. All namespaces listed must exist.

    :fontawesome-solid-gear:
    [`parent`](configuration.md#parent)


`projectSpace`

: String. The name of the namespace the project is injected into. If this is empty it is going to be `#` or `⎕SE`, depending from where the function was called from.

    :fontawesome-solid-gear:
    [`projectSpace`](configuration.md#projectspace)

`suppressInit`

: Flag to stop Cider executing the project’s [initialisation](configuration.md#init) function. Defaults to 0.

: For example, an automated build process might open a project without initialising it.

`watch`

: String. See [`watch`](configuration.md#watch) in the project config for setting values.

    :fontawesome-solid-bomb:
    [How Link watches for changes](troubleshooting.md#how-link-watches-for-changes)

:fontawesome-solid-terminal:
[`]CIDER.OpenProject`](user-commands.md#open-project)


## :fontawesome-solid-code: Project config

    {r}←ProjectConfig projectpath

Where `projectpath` is a project path, Cider displays the project config for editing.

Asks your permission before writing changes back to file, and performs checks before doing so.


## :fontawesome-solid-code: Read project config file

    config←ReadProjectConfigFile projectpath

Where `projectpath` is a project path, Cider returns its project config as a parameter namespace.

The path may or may not terminate in the filename `cider.config`.

__Side effect__ If the function does not find the sub-keys `dependency.tatin` and `dependency.nuget` in the file it creates them and writes them there.

:fontawesome-solid-terminal:
[`]CIDER.ProjectConfig`](user-commands.md#project-config).


## :fontawesome-solid-code: Write project config file

    {r}←config WriteProjectConfigFile project

Where

-   `config` is a parameter namespace
-   `project` is a project path

Cider writes the contents of `config` as the project’s configuration file.

The path may or may not terminate in the filename `cider.config`.


## :fontawesome-solid-code: Version

    r←Version

Returns a string with major and minor versions, patch number and timestamp, e.g.

          ⎕SE.Cider.Version
    0.44.0+835

This could be just e.g. `1.2.3`,  but might be something like `1.2.3-beta-1+113`.






