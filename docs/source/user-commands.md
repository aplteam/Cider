---
title: Cider user commands
description: Complete reference for the Cider user commands, most convenient way to use the Cider project manager for Dyalog APL.
keywords: api, apl, cider, dependency, dyalog, link, reference, source, tatin, ui
---
# User commands


!!! abstract "User commands are Cider’s user interface"

Cider user commands and their options are case-insensitive.
They all have help built in, for example

```
    ]CIDER -?
    ]CIDER -??
    ]CIDER.AddNuGetDependencies -?
```


## Identifying projects

You can always identify a project by its **project path**.

```
    ]CIDER.OpenProject path/to/project
```

If you have assigned it an **alias** (e.g. `foo`) you can use the alias,
embraced with square brackets to mark it as an alias.

```
    ]CIDER.OpenProject [foo]
```

If a project is open, you can identify it by its fully qualified **project space**.

```
    ]CIDER.ListTatinDependencies #.bar
```

!!! warning "Square brackets in the command syntax"

    Square brackets in the command sytaxes shown on this page indicate **optional command arguments**, not aliases.
    For example, the `ListTatinDependencies` command has syntax

    ```
        ]CIDER.ListTatinDependencies [project]
    ```

    If the project has alias `foo`, has been opened in `#.bar`,
    and is the only project open, then the following are equivalent:

    ```
        ]CIDER.ListTatinDependencies path/to/project
        ]CIDER.ListTatinDependencies [foo]
        ]CIDER.ListTatinDependencies #.bar
        ]CIDER.ListTatinDependencies
    ```



## Command options

Options are further optional arguments to the command.

Specify all the command’s arguments _before_ any options.
Prefix options with dashes, e.g.

```
    ]CIDER.CreateProject path/to/foo #.path.to.bar -noEdit
    ]CIDER.OpenProject path/to/foo -alias=ted
```

Options affect only the current command.
They override settings in the [project](configuration.md#project) and [global](configuration.md#global) configurations and leave them unchanged.

Each command’s options are tabulated below its definition.

---

## Add NuGet dependencies

```
    ]CIDER.AddNuGetDependencies pkglist [project]
```

Where `pkglist` is a comma-separated list of NuGet packages to be installed,
Cider registers the listed dependencies in the project.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.

If the project config does not specify a NuGet dependency folder, Cider asks you to edit it.

---|---
`target=` | Name of a namespace to create and add to the project config’s `dependencies` or the `dependencies_dev` setting.<br><br>If it is already configured, Cider signals an error. You then need to edit the project’s config.


## Add Tatin dependencies

```
    ]CIDER.AddTatinDependency pkglist [project]
```

Where `pkglist` is a comma-separated list of Tatin packages to be installed,
Cider registers the listed dependencies in the project.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.

If the project config does not specify a Tatin dependency folder, Cider asks you to edit it.

---|---
`development` | By default the packages are added as project dependencies. This option makes them development dependencies instead.
`target=` | Name of a namespace to be created and added to the `dependencies` or the `dependencies_dev` parameter.<br><br>If the namespace exists, Cider signals an error. You then need to edit the project’s config file.


## Close project

```
    ]CIDER.CloseProject [projects]
```

Where `projects` is one or more projects, Cider breaks the link between their namespaces and the associated files on disk.

If you omit `projects` Cider uses the one open project or, if you have more than one open, asks you which.

Separate multiple projects with spaces or commas.

Where a particular project is specified, success or failure is reported as a boolean.
Otherwise attempts to close projects are reported in detail.

---|---
`all`  | Close all open projects
`fast` | Close project without [checking for Dropbox conflicts](configuration.md#checkfordropboxconflicts "CheckForDropboxConflicts").


## Config

```
    ]CIDER.Config
```

Cider prints the content of its global config file to the session.

---|---
`edit` | Display the global config for editing. Changes are saved to file but do not affect the currently running instance of Cider.

!!! example "Example"

    ```
          ]CIDER.Config
     --- Cider Config File: /Users/sjt/.cider/config.json ---
     {
       // AskForDirChange: 1,
       // CheckForDropboxConflicts: 1,
       // ExecuteAfterProjectOpen: "⎕SE.Path.To.Function",
       // HandleLinkStops: 0,
       // ReportGitStatus: 1,
       // verbose: 1,
     }
    ```



## Create project

```
    ]CIDER.CreateProject [path [space] ]
```

Where

-   `path` (optional) is a path to the project folder
-   `space` (optional) is a namespace in the active workspace to be linked to the project

Cider initialises the project folder, links it to the project space, and offers the project config for editing, checking required settings are specified correctly.

Finally, Cider offers to open the new project.

If you omit `path`, Cider proposes the current working directory.
If you omit `space`, Cider uses the name of the project folder.

If the project folder already contains a file `cider.config` Cider signals an error, unless the `acceptConfig` flag is set.

-----------------|------------------------
`acceptConfig`   | Accept an already existing config file.
`alias=`         | Remember this alias for the project. Aliases are not case sensitive.
`batch`          | Open the new project without asking me for confirmation.
`ignoreUserExec` | Open the project without executing the global config’s [initialisation](configuration.md#executeafterprojectopen) function.
`noEdit`         | Do not offer me the configuration for editing.

??? tip "Encapsulate a project in its own namespace"

    Good practice keeps the active workspace root empty.
    Cider is designed to associate each project with a namespace.

    To create a root project (**_not_** recommended) specify `#` as the project space.


## Help

```
    ]CIDER.Help
```

Displays the Cider User Guide.




## How to make a new version

```
    ]CIDER.HowToMakeNewVersion [project]
```

Prints the project’s "Make" expression:
the expression that builds a new version of the project.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.



## How to run tests

```
    ]CIDER.HowToRunTests [project]
```

Prints the APL expression that executes the project’s test suite.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.



## List aliases

```
    ]CIDER.ListAliases
```

Lists all defined aliases with their folders.

---|---
`batch`| With `prune` delete without asking me for confirmation.
`edit`| Let me edit the file of aliases.
`prune`| Delete aliases whose folders cannot be found. (Ask me first for confirmation.)
`scan=`| Scan the specified folder for projects and ask me which to add as aliases.

Only options `prune` and `batch` can be used together.


## List NuGet dependencies

```
    ]CIDER.ListNuGetDependencies [project]
```

Lists the project’s NuGet dependencies.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.



## List open projects

```
    ]CIDER.ListOpenProjects
```

Prints a list of all open projects.

---|---
`verbose` | Instead of a list, print a table.


## List Tatin dependencies

```
    ]CIDER.ListTatinDependencies [project]
```

Lists Tatin packages installed as its dependencies.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which. When specified, `project` must be a project folder or an alias.

-------|--------
`latest`|  When this is specified, the version numbers of later versions are listed as well. Is ignored when specified with -full                                             

-------|--------
`full` | Print a hierarchical report on all dependencies.

Note that the full report does not show what is actually used, but what the packages themselves require. Due to minimum version selection the project might end up using a different (later) version.

This can help show why a particular (typically old) package is required.


## Make

    ]CIDER.HowToMakeNewVersion [project]

Prints the project’s Make expression:
the expression that builds a new version of the project.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.


## Open project

```
    ]CIDER.OpenProject project
```

Builds the project in the active workspace, linked to its source files.
[More detail…](open-project.md)

---|---
`alias=` | Remember this alias for the project.
`batch` | Do not ask me for confirmation; print nothing to the session.[^batch]
`ignoreUserExec` | Do not execute the global [initialisation](configuration.md#executeafterprojectopen) function.
`import` | Do not link APL objects to their source files. (Ignore the [`watch`](configuration.md#watch) setting in the project config.)
`noPkgLoad` | Do not load the project’s Tatin packages.
`parent=` | Override the [`parent`](configuration.md#parent) setting in the project config.
`projectSpace=` | Override the [`projectSpace`](configuration.md#projectspace) setting in the project config.
`suppressInit` | Do not execute the project’s [initialisation](configuration.md#init) function
`verbose` | Report command actions in more detail.
`watch=` | Override the [`watch`](configuration.md#watch) setting in the project config.

Options `import` and `watch=` cannot be used together.

The `batch` option is intended for test cases. Consider instead using the [`OpenProject`](api.md#open-project) API function.


## Project config

```
    ]CIDER.ProjectConfig [project]
```

Opens the project configuration in the Editor.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.

---|---
`edit` | Display the config for editing.



## Update Cider

```
    ]CIDER.UpdateCider [version]
```

Where `version` is `<major>.<minor>.<patch>`,
tries to update Cider to it.

If you omit `version` and a later version is available,
Cider asks whether you want to update to it.

The update is performed automatically,
but does not change Cider in the current workspace.
When the update is complete, restart Dyalog, rebuild the user commands, and print the current version.

```
          ]UReset
    153 commands reloaded
          ]CIDER.Version
    0.44.0+835
```

??? danger "Do not use the command for Cider versions prior to 0.37.3"

    === "Versions 0.37.1 and 0.37.2"

        These versions were installed into the new folder but with a level missing.


        [Reinstall Cider](get-started.md#install).

        The next time you use `]CIDER.UpdateCider` it will remove Cider from the wrong folder.

    === "Versions prior to 0.37.0"

        Uninstall: delete the `Cider/` folder from your `MyUCMDs/` folder.

        [Reinstall Cider](get-started.md#install).


:fontawesome-solid-bomb:
Troubleshooting: [Updating Cider](troubleshooting.md#updating-cider)



## Version

```
    ]CIDER.Version
```

Prints major, minor, patch and build numbers:

```
          ]CIDER.Version
    0.44.0+835
```



