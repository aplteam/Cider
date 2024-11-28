# User commands


!!! tip "All the user commands have help built in"

	For example

		]CIDER -?
		]CIDER -??
		]CIDER.AddNuGetDependencies -?

User commands and their options are case-insensitive.
Specify all a command’s arguments _before_ any options, e.g.

	]CIDER.CreateProject path/to/foo path/to/bar -noEdit 

---

## Add NuGet dependencies

_Add one or more NuGet packages as dependencies_

```
]CIDER.AddNuGetDependencies pkglist [project]
```

Where

`pkglist`
: is a comma-separated list of NuGet packages to be installed

`project` (optional)
: is either a project alias or the filepath of a project folder

Cider registers the listed dependencies in the project.

If `project` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.

If the project’s config file does not specify a NuGet dependency folder, you are offered the config file to edit.

**Options**

`-target=`
: Name of a namespace to be created and added to the `dependencies` or the `dependencies_dev` parameter. If it exists an error is signalled. (You then need to edit the project’s config file.)


## Add Tatin dependencies

_Add one or more Tatin packages as dependencies_

```
]CIDER.AddTatinDependency pkglist [project]
```

Where

`pkglist`
: is a comma-separated list of Tatin packages to be installed

`project` (optional)
: is either a project alias or the filepath of a project folder

Cider registers the listed dependencies in the project.

If `project` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.

If the project’s config file does not specify a Tatin dependency folder, you are offered the config file to edit.

__Options__
                                                                                                  
`-development`
: By default the packages are added as project dependencies. Use this flag to make them development dependencies instead.

`-target=`
: Name of a namespace to be created and added to the `dependencies` or the `dependencies_dev` parameter. If it exists an error is signalled. (You then need to edit the project’s config file.)


## Close project

_Break the link between the workspace and the files on disk_

	]CIDER.CloseProject [projects]

Where `projects` is one or more projects, Cider breaks the link between their namespaces and the associated files on disk.

If `projects` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.

You can specify a project as

-   a fully qualified namespace name
-   a project alias
-   a filepath

Separate multiple projects with spaces or commas.

Where a particular project is specified, success or failure is reported as a Boolean.
Otherwise attempts to close projects are reported in detail.

__Options__

`-fast`
: Use this to close without performing any checks. (See global config parameter `CheckForDropboxConflicts`.)


## Config

_Display or edit Cider’s global configuration_

	]CIDER.Config
                                                                                           
Cider prints the content of its global config file to the session.

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

__Options__
                                                                                           
-edit
: Display the config for editing.
                                                                                           
: Changes to the config are written to file but do not affect the currently running instance of Cider.
                                                                                           


## Create project

_Initialise a folder as a project_

	]CIDER.CreateProject [folder] [project-namespace]

Where

`folder` (optional)
: is a path to a folder that is empty or does not exist

`project-namespace` (optional)
: is a namespace in the active workspace to be linked to the project

Cider initialises `folder` as a project (creating it if necessary), links it to `project-namespace`, and offers the project configuration for editing.

Finally Cider attempts to open the new project.                                                         

__Project folder__

If `folder` is omitted, Cider asks you to confirm you want to use the current working directory.

If `folder` does not exist, Cider creates it.


__Project namespace__

If `project-namespace` is omitted, it is derived from the folder path.

!!! tip "Root projects"

	Good practice keeps the active workspace root empty. So Cider is designed to associate each project with a namespace.

	To create a root project (NOT recommended) specify `#` as the project namespace.
                                                                                                       
__Project configuration__

The command writes the project config in the project folder as `cider.config` and offers it for editing.

It checks required settings are specified correctly. 

If an alias (see below) is specified, Cider remembers it.

If the project folder already contains a file `cider.config` the command signals an error, unless the `acceptConfig` option is used.


__Options__

`-acceptConfig`
: Accept an already existing config file.

`-alias=`
: Remember the specified string as an alternative to the project folder filepath when opening the project. Aliases are not case sensitive.

`-batch`
: Open the newly created project without asking for confirmation.

`-ignoreUserExec`
: On this occasion, open the project without executing the user function defined in Cider’s config file.

`-noEdit`
: Do not offer the configuration for editing.


## Help

_Display the Cider User Guide_

	]CIDER.Help


## List aliases

_List all defined aliases with their folders_

	]CIDER.ListAliases

__Options__

Only options `-prune` and `-batch` can be used together.

`-batch`
: With `-prune` delete without asking me for confirmation.

`-edit`
: Let me edit the file of aliases.

`-prune`
: Delete aliases whose folders cannot be found. (Ask me first for confirmation.)

`-scan=`
: Scan the specified folder for projects and let me pick which I want added as aliases.


## List NuGet dependencies

_List NuGet packages installed as dependencies_

	]CIDER.ListNugetDependencies [project]

Where `project` is the filepath to a project folder, Cider lists the project’s NuGet dependencies.

If `project` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.

<!-- 
FIXME
The user command help says `folder` can be specified as an alias. Appears not to be true.
-->


## List open projects

_List all currently open projects_

	]CIDER.ListOpenProjects

Prints a list of all open projects.

__Options__

`-verbose`
: Instead of a list, print a table.


## List Tatin dependencies

	]CIDER.ListTatinDependencies [project]

Where `project` is the filepath to a project folder, Cider lists Tatin packages installed as dependencies of the project.

If `project` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.

__Options__

`-full`
: Print a hierarchical report on all dependencies. This does not give what is actually used, but what the packages themselves require. (Due to minimum version selection they might end up using a later version.) This can be useful to figure out why a particular (typically old) package is required.

`-raw`
: Print dependency data unformatted.


## Make

_Print the expression that builds a new version of the project_

	]CIDER.Make [project]

Where `project` is the filepath of a project folder, Cider prints the project’s "make" expression.

If `project` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.



## Open project

_Build the project in the active workspace and keep it linked_

	]CIDER.OpenProject project

Where `project` is the filepath of a project folder, or its alias, Cider builds the project in the active workspace, by default keeping the content linked to the source files.

!!! detail "Where the project is built"

	Example: the project configuration in `cider.config` includes

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
	the command defines in namespace `#.myproj` the APL objects described by files in the project’s `APLSource` folder, linked to their source files.

__Options__

Options affect only the command and leave the project configuration unchanged.

`-alias=`
: Remember this alias for the project.

`-batch`
: Do not seek confirmation from me, and print nothing to the session.

	!!! tip "This option is intended for test cases"

		Consider instead using the API function `⎕SE.Cider.OpenProject`.

`-ignoreUserExec`
: Do not execute the User Exec function specified in the project configuration.

`-import`
: Do not link the built APL objects to their source files. Any changes I make to the objects in the workspace will leave the source files unchanged.

`-noPkgLoad`
 : Do not load the project’s Tatin packages.
                
`-parent=`
: Override the project configuration’s `parent` property.

`-projectSpace=`
: Override the project configuration’s `projectSpace` property.

`-verbose`
: Report command actions in detail.

`-watch=`
: Where changes to object definitions cause Link to synchronise workspace objects with their source files. Options are `ns`, `dir`, `none`, or `both` (default).
                                         

## Project config

_Display or edit the project configuration_

	]CIDER.ProjectConfig [project]

Where `project` is the path to a project folder, prints the project configuration.

If `project` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.

__Options__

-edit
: Display the config for editing.


## Run tests

_Print the expression that executes the project’s test suite_

	]CIDER.RunTests [project]

Where `project` is the path to a project folder, Cider prints the APL expression that executes the project’s test suite.

If `project` is omitted, Cider uses the one open project or, if you have more than one open, asks you which.


## Update Cider

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

		These versions installed into the new folder but with one level missing.


		[Reinstall Cider](get-started.md#install).

		The next time you use `]CIDER.UpdateCider` it will remove Cider from the wrong folder.

	=== "Versions prior to 0.37.0"

		Uninstall: delete the `Cider/` folder from your `MyUCMDs/` folder.

		[Reinstall Cider](get-started.md#install).

__Troubleshooting__

If the update process fails, calling it again rarely helps. You need an escape route.

=== "Dyalog 19.0 and later"

	1. Execute `]DeActivate tatin` to remove Cider.
	1. Execute `]Activate cider` to restore the version of Cider your installation originally came with.
	1. Execute `]Cider.UpdateCider` to try to update to the latest version.

=== "Dyalog 18.2"

	Uninstall and then install Cider again.


## Version

	]CIDER.Version

Prints major, minor and patch numbers.





