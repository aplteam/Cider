[parm]:title = 'Cider User Guide'



# Cider User Guide

## What is Cider for?

In this document we use the word "project" for an application or a tool that consists not only of what is  finally delivered, like an Installer EXE under Windows or a Tatin package or a workspace or whatnot, but also of stuff that is required only during development, like test cases and test data, tools, helpers and similar stuff.

While Link is perfect for bringing stuff into the workspace, putting together an environment in which development can take place requires more than just getting the code into the workspace.

Note that in this document names stemming from the Cider configuration file are shown `like this`.

## The solution

Cider attempts to fill that gap. A Cider project requires a configuration file named `cider.config`. 

The two most important commands of the Cider user command group are `CreateProject` and `OpenProject`.

### CreateProject

With the user command `]Cider.CreateProject` any folder that does not yet host a file `cider.config` can be transformed into a Cider project. 

If the folder does not yet exist it will be created. In any case the folder will be populated with a file `cider.config`.

### OpenProject

Naturally `OpenProject` is the most important command the Cider user comman group offers. We discuss all its actions in detail.

Note that the  contents of the file `cider.config` directs what exactly Cider is going to do when its principal method, `OpenProject`, is executed.

#### 1. Creating a project space

The first step is to create a namespace with the name `projectSpace` as a child of `parent`, when `parent` defaults to `#` but may be something like `⎕SE` or `#.Foo.Goo`. 

The `parent` must exist while the `parentspace` may or may not exist. If it does not, it is created. If it already exists it must not contain a namespace `Cider.Config`.

#### 2. Setting system variables

In the next step Cider is going to set three system variables defined in the config file in the `SYSVARS` section: `⎕IO`, `⎕ML` and `⎕WX`.

It is important to set these three variables before code is brought into the workspace because bringing class scripts or namespace scripts into the workspace implies the execution of some code, and that code might well rely on the correct setting of those three system variables.

If you need other system variables to carry specific values then you may add them to the `SYSVARS` section. 

Note that the names are not case sensitive: wether the value for `⎕FR` is specified as  "fr" or "FR" or "Fr" or "fR" does not matter.

In case a setting in `SYSVARS` cannot be used for assigning a system variable a warning message will be printed to the session.


#### 3. Bringing in the code

In this step all files with supported file extensions[^extensions] found in `source` or any sub folder are established in the workspace in `{parent}.{projectSpace}`.

Note that from now on we will refer to:

`{parent}.{projectSpace}` as _the root of a project_.

In order to achieve this Cider uses Link[^link]. 

By default a link is established between the root of the project and the folder. When your intention is to work on the project (read: change the code) then this is the obvious thing to do.

However, if you want to bring in the code as part of, say, an automated build process, then you don't want to establish a link, you just want to bring the code into the workspace. This can be achieved by specifying the `-import` flag.


#### 4. Loading Tatin packages (optional)
 
Your application or tool might depend on one or more Tatin[^tatin] packages. By assigning `tatinFolder` one or more comma-separated folders hosting installed Tatin packages you can make sure that Cider will load[^load_tatin_pkgs] those installed packages into the root of your project.

In particular when you specify more than a single folder you are likely to want some packages to be loaded into a sub namespace of the root of your project.

For example, let's assume you want all packages installed in the folder `packages/` to be loaded into the root of your project. Let's also assume that you want to load all packages from a folder `packages_development/` into a namespace `TestCases` in the root of your project.

This will do the trick:

```
"tatinFolder": "packages,packages_development=TestCases",

```

Notes:
* For the first folder, `packages/`, no target namespace is specified, therefore the packages are loaded into the root of the project
* A namespace, if assigned to a folder, must be specified relative to the root of the project


#### 5. Injecting a namespace `CiderConfig`

In this step Cider injects a namespace `CiderConfig` into the project space and...

* populates it with the contents of the configuration file as an APL array
* adds a variable `HOME` that remembers the path the project was loaded from


#### 6. Initialising a project (optional)

Now there might well be demand for executing some code in order to initialise your project.

This can be achieved by assigning the name of a function to `lx`. This must again be relative to the root of your project.

Notes:

* The function should not return a result. If it does anyway it should be shy. Any result would be ignored.
* The function must be either monadic or niladic. If it is monadic then `⍬` is passed as right argument.

  What is passed as right argument might well change in a future release.

Note that you can access the configuration data of the project from within your initialisation function by questioning the `CiderConfig` namespace.

### 7. Executing user-specific code

Last not least you might want to execute some general code (as opposed to project-specific code) after a project was loaded.

This can be achieved by specifying the fully qualified name of a function that must be monadic, most likely in `⎕SE`. A namespace with the configuration data of the project is passed as right argument.

The function may or may not return a result, but when it does the result will be discarded.

The fully qualified name of that function must go into the file that is returned by the function `GetCiderConfigFilename` which is available only via the API, not as a user command.

That file already contains a definition of the keyword `ExecuteAfterProjectOpen`, but it is empty:

```
{
    ExecuteAfterProjectOpen: "",
}
```

[^tatin]: _Tatin_ is a Dyalog APL package manager: <https://github.com/aplteam/Tatin>

[^link]: _Link_ is a tool designed to bring APL code into the workspace and keep it in sync with the files the code came from: <https://github.com/dyalog/Link>

[^load_tatin_pkgs]: Strictly speaking only references to the packages are injected into your application or tool. The actual packages are loaded into either `#._tatin` or `⎕SE._tatin`

[^extensions]: Supported extensions are: `.aplf`, `.aplo`, `.aplc`, `.apln`, `.apli`, `.apla`, `.dyalog` 