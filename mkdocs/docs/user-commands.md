# User commands


!!! tip "All the user commands have help built in"

	For example

		]CIDER -?
		]CIDER -??
		]CIDER.AddNuGetDependencies -?

User commands and their options are case-insensitive.


## Command options

Each command’s options are tabulated below its definition.

Specify all the command’s arguments _before_ any options.
Prefix options with dashes, e.g.

	]CIDER.CreateProject path/to/foo path/to/bar -noEdit 

Options affect only the current command. 
They override settings in the [project](configuration.md#project) and [global](configuration.md#global) configurations and leave them unchanged.

---

## :fontawesome-solid-terminal: Add NuGet dependencies

_Add one or more NuGet packages as dependencies_

```
]CIDER.AddNuGetDependencies pkglist [project]
```

Where

-   `pkglist` is a comma-separated list of NuGet packages to be installed
-   `project` (optional) is an alias or project path


Cider registers the listed dependencies in the project.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.

If the project config does not specify a NuGet dependency folder, Cider asks you to edit it.

---|---
`target=` | Name of a namespace to be created and added to the project config’s `dependencies` or the `dependencies_dev` setting.<br><br>If it exists, Cider signals an error. You then need to edit the project’s config file.


## :fontawesome-solid-terminal: Add Tatin dependencies

_Add one or more Tatin packages as dependencies_

	]CIDER.AddTatinDependency pkglist [project]

Where

-   `pkglist` is a comma-separated list of Tatin packages to be installed
-   `project` (optional) is an alias or project path

Cider registers the listed dependencies in the project.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.

If the project config does not specify a Tatin dependency folder, Cider asks you to edit it.

---|---                                                                                 
`development` | By default the packages are added as project dependencies. This option makes them development dependencies instead.
`target=` | Name of a namespace to be created and added to the `dependencies` or the `dependencies_dev` parameter.<br><br>If the namespace exists, Cider signals an error. You then need to edit the project’s config file.


## :fontawesome-solid-terminal: Close project

_Break the link between the workspace and the files on disk_

	]CIDER.CloseProject [projects]

Where `projects` is one or more projects, Cider breaks the link between their namespaces and the associated files on disk.

If you omit `project` Cider uses the one open project or, if you have more than one open, asks you which.

You can specify a project as

-   a fully qualified namespace
-   an alias
-   a project path

Separate multiple projects with spaces or commas.

Where a particular project is specified, success or failure is reported as a flag.
Otherwise attempts to close projects are reported in detail.

---|---
`fast` | Close project without [checking for Dropbox conflicts](configuration.md#checkfordropboxconflicts "CheckForDropboxConflicts").


## :fontawesome-solid-terminal: Config

_Display or edit Cider’s global configuration_

	]CIDER.Config
                                                                                           
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
	   // ReportGitStatus: 1,
	   // verbose: 1,
	 }
	```



## :fontawesome-solid-terminal: Create project

_Initialise a folder as a project_

	]CIDER.CreateProject [projectpath [projectspace] ]

Where

-   `projectpath` (optional) is a path to the project folder.
    (If you omit it, Cider proposes using the current working directory.)
-   `projectspace` (optional) is a namespace in the active workspace to be linked to the project.
    (If you omit it, Cider uses the name of the project folder.)

If the project folder already contains a file `cider.config` Cider signals an error, unless the `acceptConfig` option is used.

Cider initialises the project folder, links it to the project space, and offers the project config for editing, checking required settings are specified correctly.

Finally Cider offers to open the new project.                                                         

-----------------|------------------------
`acceptConfig`   | Accept an already existing config file.
`alias=`         | Remember this alias for the project. Aliases are not case sensitive.
`batch`          | Open the new project without asking me for confirmation.
`ignoreUserExec` | Open the project without executing the global config’s [initialisation](configuration.md#executeafterprojectopen) function.
`noEdit`         | Do not offer me the configuration for editing.

!!! tip "Keep the workspace root empty"

	Good practice keeps the active workspace root empty. So Cider is designed to associate each project with a namespace.

	To create a root project (NOT recommended) specify `#` as the project space.
                                                                                                       

## :fontawesome-solid-terminal: Help

_Display the Cider User Guide_

	]CIDER.Help


## :fontawesome-solid-terminal: List aliases

_List all defined aliases with their folders_

	]CIDER.ListAliases

---|---
`batch`| With `prune` delete without asking me for confirmation.
`edit`| Let me edit the file of aliases.
`prune`| Delete aliases whose folders cannot be found. (Ask me first for confirmation.)
`scan=`| Scan the specified folder for projects and ask me which to add as aliases.

Only options `prune` and `batch` can be used together.


## :fontawesome-solid-terminal: List NuGet dependencies

_List NuGet packages installed as dependencies_

	]CIDER.ListNugetDependencies [projectpath

Where `projectpath` is the project path, Cider lists the project’s NuGet dependencies.

If you omit `projectpath` Cider uses the one open project or, if you have more than one open, asks you which.

<!-- 
FIXME
The user command help says project can be specified as an alias. Appears not to be true.
-->


## :fontawesome-solid-terminal: List open projects

_List all currently open projects_

	]CIDER.ListOpenProjects

Prints a list of all open projects.

Options:

---|---
`verbose` | Instead of a list, print a table.


## :fontawesome-solid-terminal: List Tatin dependencies

	]CIDER.ListTatinDependencies [projectpath]

Where `projectpath` is a project path, Cider lists Tatin packages installed as dependencies of the project.

If you omit `projectpath` Cider uses the one open project or, if you have more than one open, asks you which.

-------|--------
`full` | Print a hierarchical report on all dependencies.
`raw`  | Print dependency data unformatted.

The full report does not show what is actually used, but what the packages themselves require. 
(Due to minimum version selection they might end up using a later version.) 
This can help show why a particular (typically old) package is required.

## :fontawesome-solid-terminal: Make

_Print the expression that builds a new version of the project_

	]CIDER.Make [projectpath]

Where `projectpath` is a project path, Cider prints the project’s "make" expression.

If you omit `projectpath` Cider uses the one open project or, if you have more than one open, asks you which.



## :fontawesome-solid-terminal: Open project

_Build the project in the active workspace and keep it linked_

	]CIDER.OpenProject project

Where `project` is an alias or project path, Cider builds the project in the active workspace, linked to its source files.
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


## :fontawesome-solid-terminal: Project config

_Display or edit the project configuration_

	]CIDER.ProjectConfig [projectpath]

Where `projectpath` is the path to a project folder, prints the project configuration.

If you omit `projectpath` Cider uses the one open project or, if you have more than one open, asks you which.

---|---
`edit` | Display the config for editing.


## :fontawesome-solid-terminal: Run tests

_Print the expression that executes the project’s test suite_

	]CIDER.RunTests [projectpath]

Where `projectpath` is a project path, Cider prints the APL expression that executes its test suite.

If you omit `projectpath` Cider uses the one open project or, if you have more than one open, asks you which.


## :fontawesome-solid-terminal: Update Cider

_Tries to update Cider_

	]CIDER.UpdateCider

If a later version is available, Cider asks whether you want to update to it.

When the update is complete, restart Dyalog, rebuild the user commands, and print the current version.

	      ]UReset
	153 commands reloaded
	      ]CIDER.Version
	0.44.0+835

!!! danger "Do not use the command for versions prior to 0.37.3" 

	=== "Versions 0.37.1 and 0.37.2"

		These versions were installed into the new folder but with a level missing.


		[Reinstall Cider](get-started.md#install).

		The next time you use `]CIDER.UpdateCider` it will remove Cider from the wrong folder.

	=== "Versions prior to 0.37.0"

		Uninstall: delete the `Cider/` folder from your `MyUCMDs/` folder.

		[Reinstall Cider](get-started.md#install).

:fontawesome-solid-bomb:
Troubleshooting: [Updating Cider](troubleshooting.md#updating-cider)



## :fontawesome-solid-terminal: Version

	]CIDER.Version

Prints major, minor and patch numbers:

	      ]CIDER.Version
	0.44.0+835






