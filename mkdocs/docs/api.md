# API Reference

The API functions resemble their [user-command](user-commands.md) equivalents, but are not identical.
Some  do not have equivalent user commands.
Unlike user commands, API function names are case-sensitive.

The API is exposed in `⎕SE.Cider` so, for example, call `AddAlias` as `⎕SE.Cider.AddAlias`.

??? warning "API code cache"

    The Cider code package is loaded into `⎕SE._Cider`, but the API is exposed via `⎕SE.Cider`. 

    Do not call functions in `⎕SE.Cider_`. 


---

## AddAlias

    {r}←AddAlias(folder alias)

Where

--------|---------------------------------------------
`folder`|is a fully qualified path to a project folder
`alias` |is a string with no punctuation or spaces    

if the project folder exists the alias is registered in the file returned by `GetAliasFilename`.
The result is an error message, empty if successful.

If the alias is already in use you are asked to confirm the change.


## AddNuGetDependencies

    list←AddNuGetDependencies(packages project)

Where

---------|---------------------------------------------
`packages`|NuGet package/s
`project` |fully qualified path to a project folder or a Cider alias

Cider installs NuGet packages in the (single) NuGet dependency folder defined in the project’s configuration file and returns their names as a list of strings.
<!-- FIXME list of strings? -->

Specify `packages` as either a list of strings or a comma-separated string.

!!! warning "NuGet package names" 

    NuGet package names are not case sensitive when they are loaded so, for example, you can load `Clock` by the name `clock`. 

    However, the correct name is returned, and is required for using a package.

See also [`]CIDER.AddNugetDependencies`](user-commands.md#add-nuget-dependencies).


## AddTatinDependencies

    r←AddTatinDependencies(packages project dev)

Where

--------|---------------------------------------------
`packages`|Tatin package/s
`project` |fully qualified path to a project folder or a Cider alias
`dev` | flag

Cider installs Tatin packages in one of the Tatin dependency folders defined in the project’s configuration file. (The default is `dependencies.tatin`.)

Specify packages as either a a list of strings or a comma-separated string.

The `dev` flag indicates which configuration parameter specifies the installation folder.

----|-------------------
0   | `dependencies`
1   | `dependencies_dev`

<!-- FIXME Result? -->

See also [`]CIDER.AddTatinDependencies`](user-commands.md#add-tatin-dependencies).



## CloseProject

    r←{x} CloseProject projects

Where 

----------|----------------------------
`x`       | (optional) list of projects and/or flag
`projects`| is one or more open projects

Cider closes the projects (unlinks the source files) and returns the number of projects closed.

Identify projects as (any of)

-   fully qualified namespace names
-   aliases
-   project paths

Specify `projects` as either a string or a list of strings.

The __optional left argument__ can be either or both (in any order) of

-   a list of projects as returned by `ListProjects`
-   a flag (defaults to 1): whether checks are performed.

    See `CheckForDropboxConflicts` in Cider's _User Guide > Global configuration > CheckForDropboxConflicts_ for an example. 
    <!-- FIXME Replace with link. -->

<!-- FIXME specify effect of listing projects in `x`. -->

See also [`]CIDER.ClosePoject`](user-commands.md#close-project).


## CreateCreateProjectParms

    parms←{parms} CreateCreateProjectParms folder

Where

---------|-----------------------------------------
`parms`  | (optional) namespace of parameters
`folder` | fully qualified path of a project folder


Cider returns a namespace with parameters required by [`CreateProject`](#createproject), by default:


-----------------|--------
`acceptConfig`   | 0
`folder`         | `folder` argument filepath
`ignoreUserExec` | 0
`namespace`      | last part of the `folder` filepath

Defaults are overwritten by any specified in the `parms` argument.

See also [`]CIDER.CreatePoject`](user-commands.md#create-project).


## CreateOpenParms

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

!!! detail "Setting to `watch` to 0 shows Cider you have not set this. Eventually 0 becomes `both`, the default."

<!-- 
    watch                 ['ns'|'both']  ⍝ depending on the availability of .NET 

We assume the use of Link, so .NET must be available.

FIXME
Why is `#` not the default for `parent`?
 -->



## CreateProject

    r←CreateProject parms

Where `parms` is a namespace of parameter values, typically the result of [`CreateCreateProjectParms`](#createcreateprojectparms), Cider creates a project.

See also [`]CIDER.CreateProject`](user-commands.md#create-project).


## DropAlias

    {successFlag}←DropAlias alias

Where `alias` is a project alias, Cider removes it from the file named by `GetCiderAliasFilename` and returns a flag indicating success.


## GetCiderAliasFileContent

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

See also [`]CIDER.ListAliases`](user-commands.md#list-aliases).



## GetCiderAliasFilename

    filename←GetCiderAliasFilename

Returns the path to the file used to record alias names and their paths.



## GetCiderGlobalConfigFileContent

    r←GetCiderGlobalConfigFileContent

Returns the contents of Cider’s (optional) global configuration file – if found – as a namespace of parameters.

If no global configuration file is found, the result is `⍬`.

<!-- 
FIXME 
Link to Global configuration

### ExecuteAfterProjectOpen

The user may specify a fully qualified function name, usually situated in `⎕SE`. This function will then be called after a project (any project!) was opened by Cider. 

This can be used to, say, check the status of the project on GitLab or a similar platform, since Cider considers only GitHub, and requires the package [APLGit2](https://github.com/aplteam/APLGit2 "Link to APLGit2 on GitHub") for this.

This setting defines the same function for all your Cider projects, which is why it is not part of the file `cider.config.template` but defined in Cider's global config file.
 -->

See also [`]CIDER.Config`](user-commands.md#config).


## GetCiderGlobalConfigFilename

    filename←GetCiderGlobalConfigFilename

Returns as a fully qualified filepath Cider’s global configuration file.


## GetCiderGlobalConfigHomeFolder

    folder←GetCiderGlobalConfigHomeFolder

Returns as a fully qualified filepath the folder that contains Cider’s global configuration file.

On Windows, this is typically `C:/Users/<⎕AN>/.cider/config.json`



## GetMyUCMDsFolder

    r←GetMyUCMDsFolder

Returns the fully qualified filepath to the `MyUCMDs/` folder.

!!! warning "The folder might not exist :fontawesome-brands-linux: :fontawesome-brands-apple:"

    This folder is created by the Windows installer; not so on other platforms.


## GetNuGetDependencies

    r←name GetNuGetDependencies config

Where 

---------|----------------------
`name`   | `'development'` or `'development_dev'`
`config` | is a namespace of parameters 

returns either the value of `nuget` in the given branch or an empty vector if `nuget` is not defined.

The `config` argument is typically derived from a project’s configuration file.

See also [`]CIDER.ListNuGetDependencies`](user-commands.md#list-nuget-dependencies).



## GetProgramFilesFolder

    r←{current}GetProgramFilesFolder suffix

Where

----------|-------------------
`current` | (optional) flag
`suffix`  | suffix to the folder filepath

Returns the fully qualified filepath to the Dyalog files folder with any `suffix` specified.

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

## GetTatinDependencies

    r←name GetTatinDependencies config

Where

---------|----------------------
`name`   | `'development'` or `'development_dev'`
`config` | is a namespace of parameters 

returns either the value of `tatin` in the given branch or an empty vector if `tatin` is not defined.

The `config` argument is typically derived from a project’s configuration file.



## HasDotNet

    flag←HasDotNet

Returns a 1 if either .NET Core or .NET is available and the bridge DLL was successfully loaded; 0 otherwise.


## ListNuGetDependencies

    r←ListNuGetDependencies projectFolder

Where `projectFolder` is the fully qualified filepath of a project folder, returns a matrix of names and versions of its NuGet dependencies.

!!! detail "Single NuGet installation folder"

    There can be only one NuGet installation folder: currently you cannot have NuGet packages for development purposes. 

    This restriction may be lifted in a future release.


## ListOpenProjects

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

See also [`]CIDER.ListOpenProjects`](user-commands.md#list-open-projects).


## ListTatinDependencies

    r←ListTatinDependencies project

Where `project` is a fully qualified path to a project folder, returns as a 5-column matrix the dependencies installed in the Tatin installation folders.

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

See also [`]CIDER.ListTatinDependencies`](user-commands.md#list-tatin-dependencies).



## OpenProject

    (successFlag ∆LOG)←OpenProject y

Where `y` is either

-   a string specifying a project either as 
    -   the fully qualified filepath of a project folder containing a config file
    -   a registered project alias

-   a namespace of parameters (typically created by  `CreateOpenParms`) containing a variable `folder` that specifies the fully-qualified filepath of a project folder 

Cider opens the project as listed below, and returns a 2-item result:

--------------|--------------------------
`successFlag` | flag, 1 for success
`∆LOG`        | list of strings as printed to the session

__Actions opening the project__

1.  Creates the `projectSpace` namespace in `parent` if it does not already exist. This is the __project root__.
1.  Sets the system variables `⎕IO` and `⎕ML` in the project root.
1.  Brings all code and variables into the project root.
1.  Loads all Tatin packages from the Tatin installation folders defined by `dependencies:tatin` and `dependencies_dev:tatin`.
1.  Loads all NuGet packages from the NuGet installation folder defined by `dependencies:nuget`.
1.  Injects a namespace `CiderConfig` into the project root and populates it with the contents of the configuration file.
1.  Injects a namespace `TatinVars` into the project root, and a ref pointing to that `TatinVars` (with the same name) if the optional parameter `tatinVars` in the Cider Config section `CIDER` is defined and points to a sub-namespace in the project root.
1.  Changes the current directory to the project path if this is the first and only Cider project.
1.  Adds a variable `HOME` to `CiderConfig` specifying the path from which the project was loaded.
1.  Executes the project-specific function noted on `init`, usually to initialise the project.
1.  Executes a non-project-specific function defined in Cider’s global configuration.
    Allows for carrying out user-specific actions as a project is opened.
1. Checks for a variable `ToDo` in the project root, and displays it for editing if it exists.
1. Checks the status of the project if it is managed by Git.

__Parameters__

Parameter values affect the command.
They override the project’s configuration but do not change it. 


`folder` (mandatory)

: String. Must be either the filepath of a folder containing a file `cider.config` or a Cider project alias. (See also `alias`.) 
: Cannot be empty but could be `./` indicating the current directory.

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

: Numeric scalar or empty vector (default). 

    The default means you will be asked if you want Cider to check all principal packages for later versions and, if any are found, if you want to update them. (If the project has multiple package folders the second question is asked for each Tatin installation folder.)

    Alternative values:

        0 | Do not check at all
        1 | Check and report findings but prompt for updating
        2 | Check and update without consulting me

    This parameter is ignored if the project has no Tatin installation folder, or if `importFlag` is set.


`ignoreUserExec`

: Flag[^flag]. Setting it stops Cider executing at the end of opening a project a function named in the global config’s `ExecuteAfterProjectOpen` parameter. Defaults to 0.


`importFlag`

: Flag. Setting it stops Cider from linking APL objects to their source files. Defaults to 0.

: !!! warning "Setting this flag has implications for how Cider deals with Tatin packages."
<!-- 
, see there. 
FIXME Where?
 -->

`noPkgLoad`

: Flag. Setting it stops Cider from loading Tatin dependencies as specifed in the config file’s `dependencies` and `dependencies_dev` parameters. Defaults to 0.


`parent`

: String. Defaults to `#` but could be something like `⎕SE` or `#.Foo.Goo.Boo`. All namespaces listed must exist.


`projectSpace`

: String. The name of the namespace the project is injected into. If this is empty it is going to be `#` or `⎕SE`, depending from where the function was called from.


`quietFlag`

: Flag. Setting it stops Cider printing messages to the session. (They are still returned in the function‘s result.)


`suppressLX`

: Flag. Setting it stops Cider executing the project’s initialisation function. Defaults to 0.

: For example, an automated build process might open a project without actually initialising it.

`watch`

: String. The default of `both` means Link responds to changes to the definitions of APL objects in either the workspace or the source files: changes in one environment are reflected in the other.

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

See also [`]CIDER.OpenProject`](user-commands.md#open-project).


## ProjectConfig

    {r}←ProjectConfig project

Where `project` is a fully qualified path to a project folder, Cider displays the project’s config file for editing.

Asks your permission before writing changes back to file, and performs checks before doing so.




## ReadProjectConfigFile

    config←ReadProjectConfigFile project

Where `project` is a fully qualified path to a project folder, Cider returns the contents of the project’s config file as a parameter namespace.

The path may or may not terminate in the filename `cider.config`.

Side effect: if the function does not find the sub-keys `dependency.tatin` and `dependency.nuget` in the file it creates them and writes them there.

See also [`]CIDER.ProjectConfig`](user-commands.md#project-config).


## WriteProjectConfigFile

    {r}←config WriteProjectConfigFile project

Where 

----------|-------------------------
`config`  | a parameter namespace
`project` | a fully qualified path to a project folder

Cider writes the contents of`config` as the project’s configuration file.

The path may or may not terminate in the filename `cider.config`.


## Version

    r←Version


Returns a string with major and minor versions, patch number and timestamp, e.g.

          ⎕SE.Cider.Version
    0.44.0+835

This could be just e.g. `1.2.3`,  but might be something like `1.2.3-beta-1+113`.





[^flag]: A flag is 1 or 0. It is ‘set’ with a value of 1.

*[string]: a character vector of depth 1
*[list of strings]: a nested vector of character vectors of depth 1
*[NuGet]: .NET package manager
