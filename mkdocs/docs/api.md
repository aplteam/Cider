# API Reference

The API functions are similar to the [user-commands](user-commands.md), but are not identical.
Some  do not have equivalent user commands.

Unlike user commands, API function names are case-sensitive.

The API is exposed in `⎕SE.Cider` so, for example, call `AddAlias` as `⎕SE.Cider.AddAlias`.

??? warning "API code cache"

    The Cider code package is loaded into `⎕SE._Cider`, but the API is exposed via `⎕SE.Cider`. 

    Do not call functions in `⎕SE.Cider_`. 

A flag is 1 or 0. It is ‘set’ with a value of 1.


---

## :fontawesome-solid-code: AddAlias

    {r}←AddAlias(folder alias)

Where

-   `folder`  is a path to a project folder
-   `alias`   is a string with no punctuation or spaces

if the project folder exists the alias is registered in the file returned by [`GetCiderAliasFilename`](#GetCiderAliasFilename).
The result is an error message, empty if successful.

If the alias is already in use you are asked to confirm the change.


## :fontawesome-solid-code: AddNuGetDependencies

    list←AddNuGetDependencies(packages project)

Where

-   `packages`is one or more NuGet packages
-   `project` is a project alias or a path to a project folder 

Cider installs NuGet packages in the (single) NuGet dependency folder defined in the project’s configuration file and returns their names as a list of strings.
<!-- FIXME list of strings? -->

Specify `packages` as either a list of strings or a comma-separated string.

!!! warning "NuGet package names" 

    NuGet package names are not case sensitive when they are loaded so, for example, you can load `Clock` by the name `clock`. 

    However, the correct name is returned, and is required for using a package.

:fontawesome-solid-terminal: 
[`]CIDER.AddNugetDependencies`](user-commands.md#add-nuget-dependencies)


## :fontawesome-solid-code: AddTatinDependencies

    r←AddTatinDependencies(packages project dev)

Where

-   `packages` is one or more Tatin packages
-   `project` is a project alias or a path to a project folder 
-   `dev` is a flag

Cider installs the packages in one of the Tatin dependency folders defined in the project’s configuration file. (The default is `dependencies.tatin`.)

Specify packages as either a list of strings or a comma-separated string.

Setting the `dev` flag switches the installation folder from `dependencies` (default) to`dependencies_dev`.

<!-- FIXME Result? -->

:fontawesome-solid-terminal: 
[`]CIDER.AddTatinDependencies`](user-commands.md#add-tatin-dependencies).



## :fontawesome-solid-code: CloseProject

    r←{x} CloseProject projects

Where 

-   `x` (optional) is a list of projects and/or a flag
-   `projects` is one or more open projects

Cider closes the projects (unlinks the source files) and returns the number of projects closed.

Identify projects as (any of)

-   fully qualified namespace names
-   aliases
-   project paths

Specify `projects` as either a string or a list of strings.

The __optional left argument__ can be either or both (in any order) of

-   a list of projects as returned by [`ListOpenProjects`](#listopenprojects)
-   a flag (defaults to 1): whether Dropbox conflict checks are made.


<!-- FIXME specify effect of listing projects in `x`. -->

:fontawesome-solid-gear: 
[`CheckForDropboxConflicts`](configuration.md#checkfordropboxconflicts)<br>
:fontawesome-solid-terminal: 
[`]CIDER.CloseProject`](user-commands.md#close-project)


## :fontawesome-solid-code: CreateCreateProjectParms

    parms←{parms} CreateCreateProjectParms folder

Where

-   `parms` (optional) is a namespace of parameters
-   `folder` is the path of a project folder

Cider returns a namespace with parameters required by [`CreateProject`](#createproject), by default:

    acceptConfig   - 0
    folder         - folder argument filepath
    ignoreUserExec - 0
    namespace      - last part of the folder filepath

Defaults are overwritten by any specified in the `parms` argument.

:fontawesome-solid-terminal: 
[`]CIDER.CreatePoject`](user-commands.md#create-project)


## :fontawesome-solid-code: CreateOpenParms

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
    quietFlag             0 
    suppressInit          0
    verbose               0
    watch                 0

!!! detail "Setting `watch` to 0 shows Cider you have not set this. Eventually 0 becomes `both`, the default."

<!-- 
    watch                 ['ns'|'both']  ⍝ depending on the availability of .NET 

We assume the use of Link, so .NET must be available.

FIXME
Why is `#` not the default for `parent`?
 -->



## :fontawesome-solid-code: CreateProject

    r←CreateProject parms

Where `parms` is a namespace of parameter values, typically the result of [`CreateCreateProjectParms`](#createcreateprojectparms), Cider creates a project.

:fontawesome-solid-terminal: 
[`]CIDER.CreateProject`](user-commands.md#create-project)


## :fontawesome-solid-code: DropAlias

    {successFlag}←DropAlias alias

Where `alias` is a project alias, Cider removes it from the file named by `GetCiderAliasFilename` and returns a flag indicating success.


## :fontawesome-solid-code: GetCiderAliasFileContent

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



## :fontawesome-solid-code: GetCiderAliasFilename

    filename←GetCiderAliasFilename

Returns the path to the file used to record alias names and their paths.



## :fontawesome-solid-code: GetCiderGlobalConfigFileContent

    r←GetCiderGlobalConfigFileContent

Returns the contents of Cider’s (optional) global configuration file – if found – as a namespace of parameters.

If no global configuration file is found, the result is `⍬`.

<!-- 
FIXME 
Link to Global configuration

### :fontawesome-solid-code: ExecuteAfterProjectOpen

The user may specify a fully qualified function name, usually situated in `⎕SE`. This function will then be called after a project (any project!) was opened by Cider. 

This can be used to, say, check the status of the project on GitLab or a similar platform, since Cider considers only GitHub, and requires the package [APLGit2](https://github.com/aplteam/APLGit2 "Link to APLGit2 on GitHub") for this.

This setting defines the same function for all your Cider projects, which is why it is not part of the file `cider.config.template` but defined in Cider's global config file.
 -->

:fontawesome-solid-terminal: 
[`]CIDER.Config`](user-commands.md#config)


## :fontawesome-solid-code: GetCiderGlobalConfigFilename

    filename←GetCiderGlobalConfigFilename

Returns as a fully qualified filepath Cider’s global configuration file.


## :fontawesome-solid-code: GetCiderGlobalConfigHomeFolder

    folder←GetCiderGlobalConfigHomeFolder

Returns as a fully qualified filepath the folder that contains Cider’s global configuration file.

On Windows, this is typically `C:/Users/<⎕AN>/.cider/config.json`



## :fontawesome-solid-code: GetMyUCMDsFolder

    r←GetMyUCMDsFolder

Returns the fully qualified filepath to the `MyUCMDs/` folder.

!!! warning "The folder might not exist :fontawesome-brands-linux: :fontawesome-brands-apple:"

    This folder is created by the Windows installer; not so on other platforms.


## :fontawesome-solid-code: GetNuGetDependencies

    r←name GetNuGetDependencies config

Where 

-   `name` is `'development'` or `'development_dev'`
-   `config` is a namespace of parameters 

returns either the value of `nuget` in the given branch or an empty vector if `nuget` is not defined.

The `config` argument is typically derived from a project’s configuration file.

:fontawesome-solid-terminal: 
[`]CIDER.ListNuGetDependencies`](user-commands.md#list-nuget-dependencies)



## :fontawesome-solid-code: GetProgramFilesFolder

    r←{current}GetProgramFilesFolder suffix

Where

-   `current` (optional) is a flag
-   `suffix` is a suffix to the folder filepath

returns the path to the Dyalog files folder with any `suffix` specified.

The `current` flag (default 0) specifies whether the result is specific to the currently running version of Dyalog.


```
      ⍝ Version agnostic
      Cider.GetProgramFilesFolder ''
C:\Users\kai\Documents\Dyalog APL Files             
      Cider.GetProgramFilesFolder 'CiderTatin'
C:\Users\kai\Documents\Dyalog APL Files/CiderTatin

      ⍝ Version specific
      1 Cider.GetProgramFilesFolder ''              
C:\Users\kai\Documents\Dyalog APL-64 18.2 Unicode Files
```

## :fontawesome-solid-code: GetTatinDependencies

    r←name GetTatinDependencies config

Where

-   `name` is `'development'` or `'development_dev'`
-   `config` is a namespace of parameters 

returns either the value of `tatin` in the given branch or an empty vector if `tatin` is not defined.

The `config` argument is typically derived from a project’s configuration file.



## :fontawesome-solid-code: HasDotNet

    flag←HasDotNet

Returns a 1 if either .NET Core or .NET is available and the bridge DLL was successfully loaded; 0 otherwise.


## :fontawesome-solid-code: ListNuGetDependencies

    r←ListNuGetDependencies projectFolder

Where `projectFolder` is the fully qualified filepath of a project folder, returns a matrix of names and versions of its NuGet dependencies.

!!! detail "Single NuGet installation folder"

    There can be only one NuGet installation folder: currently you cannot have NuGet packages for development purposes. 

    This restriction may be lifted in a future release.


## :fontawesome-solid-code: ListOpenProjects

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


## :fontawesome-solid-code: ListTatinDependencies

    r←ListTatinDependencies project

Where `project` is a path to a project folder, returns as a 5-column matrix the dependencies installed in the Tatin installation folders.

1. The full package ID
1. A Boolean indicating whether the package is a principal one or just a dependency
1. A URL where the package was loaded from
2. ???
3. ???

<!-- 
FIXME
Describe the other two columns
 -->

!!! detail "Until version 0.34.0 this was named `ListTatinPackages`"

:fontawesome-solid-terminal:
[`]CIDER.ListTatinDependencies`](user-commands.md#list-tatin-dependencies).



## :fontawesome-solid-code: OpenProject

    (successFlag ∆LOG)←OpenProject y

Where `y` is either

-   a string specifying a project either as 
    -   the fully qualified filepath of a project folder containing a config file
    -   a registered project alias

-   a namespace of parameters (typically created by  `CreateOpenParms`) containing a variable `folder` that specifies the fully-qualified filepath of a project folder 

Cider opens the project as listed below, and returns a 2-item result:

    successFlag - 1 for success
    ∆LOG        - list of strings as printed to the session

### Actions

1.  Creates the `projectSpace` namespace in `parent` if it does not already exist. This is the __project root__.
1.  Sets the projects’s [system variables](configuration.md#system) (at least `⎕IO` and `⎕ML`) in the project root.
1.  Brings all APL code and variables into the project root, linked to their source files according to the project’s [`watch`](configuration.md#watch) setting unless the `importFlag` parameter is set.
1.  Loads all Tatin packages from the Tatin installation folders defined by [`dependencies:tatin`](configuration.md#dependencies) and [`dependencies_dev:tatin`](configuration.md#dependencies-dev).
1.  Loads all NuGet packages from the NuGet installation folder defined by [`dependencies:nuget`](configuration.md#dependencies).
1.  Injects a namespace `CiderConfig` into the project root and populates it with the contents of the configuration file.
1.  Injects a namespace `TatinVars` into the project root, and a ref pointing to that `TatinVars` (with the same name) if parameter [`tatinVars`](configuration.md#tatinvars) is defined in the project config `CIDER` section and points to a subnamespace of the project space.
1.  Changes the current directory as specified by [`AskForDirChange`](configuration.md#askfordirchange) in the global config.
1.  Adds a variable `HOME` to `CiderConfig` specifying the path from which the project was loaded.
1.  Executes the function specified in the project’s [`init`](configuration.md#init) setting.
1.  Executes the function specified in the global [`ExecuteAfterProjectOpen`](configuration.md#executeafterprojectopen) setting.
1. If it finds a variable `ToDo` in the project root, displays it for editing.
1. Reports the Git status of the project according to the global [`ReportGitStatus`](configuration.md#reportgitstatus) setting.

### Parameters

Parameter values affect the command.
They override the settings in the global and project configurations but do not change them. 

All parameters are optional except `folder`.


`folder` (required)

: String. Either the path of a folder containing a file `cider.config` or a project alias. (See also `alias`.) 
: May not be empty but could be `./` indicating the current directory.

`alias`

: String. An alias by which you can refer to the project.

    Special syntax: if `alias` is just a `.` (dot), then the last part of the path becomes the alias. Example:

    ```apl
    p←Cider.CreateOpenParms
    p.folder←'/path/2/projects/foo'
    p.alias←'.'  ⍝ `foo` becomes the (new) alias
    ```

    If you specify an alias on `folder` but also on `alias`, then Cider expects the alias on `folder` to be defined, and will use that one to open the project. It will then overwrite the former alias with the one defined on `alias`.

<!-- FIXME I don’t understand the preceding paragraph. -->

`checkPackageVersions`

: By default you will be asked if you want Cider to check all principal packages for later versions and, if any are found, if you want to update them. (If the project has multiple package folders the second question is asked for each Tatin installation folder.)

        ⍬ - Ask me whether to check (default)
        0 - Do not check at all
        1 - Check and report findings but prompt for updating
        2 - Check and update without consulting me

    This parameter is ignored if the project has no Tatin installation folder, or if `importFlag` is set.


`ignoreUserExec`

: Setting the flag stops Cider executing at the end of opening a project a function named in the global  [`ExecuteAfterProjectOpen`](configuration.md#executeafterprojectopen) setting. Defaults to 0.


`importFlag`

: Setting the flag stops Cider from linking APL objects to their source files. Defaults to 0.

    :fontawesome-solid-gear:
    [`watch`](configuration.md#watch)

    !!! warning "Setting this flag has implications for how Cider deals with Tatin packages."
<!-- 
, see there. 
FIXME Where? What implications?
 -->

`noPkgLoad`

: Setting the flag stops Cider from loading Tatin dependencies as specifed in the config file’s `dependencies` and `dependencies_dev` parameters. Defaults to 0.


`parent`

: String. Defaults to `#` but could be something like `⎕SE` or `#.Foo.Goo.Boo`. All namespaces listed must exist.

    :fontawesome-solid-gear:
    [`parent`](configuration.md#parent)


`projectSpace`

: String. The name of the namespace the project is injected into. If this is empty it is going to be `#` or `⎕SE`, depending from where the function was called from.

    :fontawesome-solid-gear:
    [`projectSpace`](configuration.md#projectspace)


`quietFlag`

: Setting the flag stops Cider printing messages to the session. (They are still returned in the function‘s result.)


`suppressLX`

: Setting the flag stops Cider executing the project’s [initialisation function](configuration.md#init). Defaults to 0.

: For example, an automated build process might open a project without actually initialising it.

`watch`

: String. The default of `both` means Link responds to changes to the definitions of APL objects in either the workspace or the source files: changes in one environment are mirrored in the other.

: Alternative values:

        ns     respond only to changes in the workspace
        dir    respond only to changes in the source files
        none   do not respond to changes


    !!! warning "How Link watches for changes"

        To detect changes on the file system, Link uses a File System Watcher, which requires .NET.

        To detect changes in the workspace, Link uses APL threads.

        When you trace through your code, or set a stop vector, and have _Pause on Error_ checked in the session’s _Threads_ menu, handlers associated with those threads will also stop.

        The Link handlers set a Hold under some circumstances. 
        Depending on your actions, this might result in a deadlock. Dyalog would appear to hang until you use the session’s _System_ menu to issue a strong interrupt.

    :fontawesome-solid-gear:
    [`watch`](configuration.md#watch)

:fontawesome-solid-terminal:
[`]CIDER.OpenProject`](user-commands.md#open-project).


## :fontawesome-solid-code: ProjectConfig

    {r}←ProjectConfig project

Where `project` is a path to a project folder, Cider displays the project’s config file for editing.

Asks your permission before writing changes back to file, and performs checks before doing so.




## :fontawesome-solid-code: ReadProjectConfigFile

    config←ReadProjectConfigFile project

Where `project` is a path to a project folder, Cider returns the contents of the project’s config file as a parameter namespace.

The path may or may not terminate in the filename `cider.config`.

__Side effect__ if the function does not find the sub-keys `dependency.tatin` and `dependency.nuget` in the file it creates them and writes them there.

:fontawesome-solid-terminal:
[`]CIDER.ProjectConfig`](user-commands.md#project-config).


## :fontawesome-solid-code: WriteProjectConfigFile

    {r}←config WriteProjectConfigFile project

Where 

-   `config` is a parameter namespace
-   `project` is a path to a project folder

Cider writes the contents of`config` as the project’s configuration file.

The path may or may not terminate in the filename `cider.config`.


## :fontawesome-solid-code: Version

    r←Version

Returns a string with major and minor versions, patch number and timestamp, e.g.

          ⎕SE.Cider.Version
    0.44.0+835

This could be just e.g. `1.2.3`,  but might be something like `1.2.3-beta-1+113`.





*[NuGet]: .NET package manager
