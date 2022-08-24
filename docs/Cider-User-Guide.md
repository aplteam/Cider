[parm]:title             = 'Cider User Guide'
[parm]:leanpubExtensions = 1
[parm]:numberHeaders     = 2 3 4 5 6




# Cider User Guide

## What is Cider for?

In this document we use the word "project" for an application or a tool that consists not only of what is  finally delivered, like an Installer EXE under Windows or a Tatin package or a workspace or whatnot, but also of stuff that is required only during development, like test cases and test data, tools, helpers and similar stuff.

While LINK is perfect for bringing stuff into the workspace, putting together an environment in which development can take place requires more than just that. There is something missing...

I> Note that in this document names stemming from the Cider configuration file are shown `like this`.

## The solution

Cider attempts to fill that gap. A Cider project requires a configuration file named `cider.config`. 

The two most important commands of Cider's user commands are `CreateProject` and `OpenProject`.

### CreateProject

With `]Cider.CreateProject` any folder that does not yet host a file `cider.config` can be transformed into a Cider project. (You may specify the `-acceptConfig` flag to override this default behaviour and make Cider accept an already existing file `cider.config`)

If the folder does not yet exist it will be created. In any case the folder will be populated with a file `cider.config`.

#### Configuration parameters

The Cider configuration file comes with four sections:

* CIDER
* LINK
* SYSVARS
* USER

We will discuss the settings in each section in detail.

##### CIDER

This section contains the Cider-specific parameters.

###### parent

Defaults to `#` but can be something like `⎕SE` or `#.MyNamespace1.MyNamespace2`. 

Note that any sub-namespaces must already exist.

###### projectSpace

The name of a namespace that will host the project. *Must* be set by the user.

This can be overwritten temporarily with  `]Cider.OpenProject {path} -target=#.foo`
        

###### source

Defaults to `APLSource`: a sub folder that hosts the code. Thats where the code lives, relative to the project folder. 

This might be empty, for example when the project is bascially just a script (class or namespace).

###### tatinFolder

Defaults to "packages".

Defines the folder(s) with installed Tatin packages required by the project. Must be relative to the folder where the project lives.

Accepts also something like this:

```
packages,packages_dev=TestCases
```

This is interpreted as follows:

1. Load all Tatin packages that are installed in the project's sub folder "packages" into the namespace that hosts the project

1. Load all Tatin packages that are installed in the project's sub folder "packages_dev" into the namespace `TestCases` which must be a child of the namespace that hosts the project

###### init

If not empty this must be an expression that would call a function within the project. It must be defined relative to `projectSpace`.

The expression will be executed when everything else is done. 


###### info_url

If not empty this is expected to be a URL pointing to, say, a GitHub project.

###### make

Empty or an expression that would create a new version of the project.

The purpose is to tell anybody not familiar with the project how to create a new version by entering

```
      ]Cider.Make
#.Cider.Admin.Make 1 ⍝ Execute this for creating a new version
```

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.make` and the comment is then added.

However, if the first non-white space character of `make` is a `]` its definition would just be printed to `⎕SE` together with a comment.

###### tests

Empty or an expression that would executes the test cases of the project.

The purpose is to tell anybody not familiar with the project how to execute the test cases by entering

```
      ]Cider.RunTests
#.Cider.TestCases.RunTests ⍝ Execute this for running the test suite
```
However, if the first non-white space character of `tests` is a `]` (making it a user command rather than a function call) its definition would just be printed to `⎕SE` together with a comment.

##### LINK

These are LINK parameters which are passed on to LINK when Cider brings the APL code into the WS with LINK.

You may add other settings like `caseCode` as well; refer to LINKs documentation for details.

###### arrays

This is  a Boolean that defaults to 0.

A 1 means that all variables are watched, 0 means that Cider does not care unless a variable is already saved in an `.apla` file.

###### beforeRead

Empty or a *fully qualified* function name.

###### beforeWrite

Empty or a *fully qualified* function name.

###### watch"

Defaults to "both" but can be "ns" or "dir" as well. 

Defines which source to track for changes, so the other can be synchronised.

##### SYSVARS

This section allows you to define system variables. `⎕IO` and `⎕ML` should always be defined here.

You may add other `⎕`-variables here like, say, `⎕CT` as "ct" etc.
            


###### io

Defaults to 1.

###### ml

Defaults to 1.


#####  USER

This section allows you to specify your own project-specific values; its contents (if any) is ignored by Cider.

This is an example:

```
USER: {                                   
   "Foo": 1,                 
    },
}
},
````

After opening the project into, say, `#.MyProject` the value is accessible via

```
#.MyProject.CiderConfig.USER.Foo
```

### OpenProject

Naturally `OpenProject` is the most important command Cider offers. We discuss all its actions in detail.

Note that the  contents of the file `cider.config` directs what exactly Cider is going to do when its principal method, `OpenProject`, is executed.

#### 1. Creating a project space

The first step carried out by `]Cider.OpenProject` is to create a namespace with the name `projectSpace` as a child of `parent`, when `parent` defaults to `#` but may be something like `⎕SE` or `#.Foo.Goo` etc.

The `parent` must exist while the `parentspace` may or may not exist. If it does not, it is created. If it already exists it must not contain a namespace `CiderConfig`.

#### 2. Setting system variables

In the next step `]Cider.OpenProject` is going to set at least two system variables defined in the config file in the `SYSVARS` section of the INI file: `⎕IO` and `⎕ML`.

It is important to set these variables before code is brought into the workspace because bringing class scripts or namespace scripts into the workspace implies the execution of some code, and that code might well rely on the correct setting of those system variables.

If you need other system variables to carry specific values then you may add them to the `SYSVARS` section. 

Note that the names are not case sensitive: whether the value for `⎕FR` is specified as  "fr" or "FR" or "Fr" or "fR" does not matter.

In case a setting in `SYSVARS` cannot be used for assigning a system variable a warning message will be printed to the session.

A> ### System variables
A>
A> Feel free to save system variables in files like `⎕IO.apla` in your source folder. 
A>
A> That's another way to make sure that system variables are set as early as possible because LINK will establish the values of system variables defined in files before it attempts to bring code into the workspace.


#### 3. Bringing the code into the workspace

In this step all files with supported file extensions (See LINK's documentation for details) found in `source` and any sub folder are established in the workspace in `{parent}.{projectSpace}`.

Note that from now on we will refer to:

`{parent}.{projectSpace}` as _the root of a project_.

In order to achieve this Cider uses LINK[^link]. 

By default a link is established between the root of the project and the folder. When your intention is to work on the project (read: change the code) then this is the obvious thing to do.

A> ### LINK's `watch` parameter
A>
A> By default Cider sets the `watch` parameter to "both", meaning that changes in the workspace via the editor are saved to disk, and any changes on disk are brought into the workspace[^winonly]. 
A>
A> You may set `watch` to "ns" or "dir" instead. Refer to the LINK documentation for details.


However, if you want to bring in the code as part of, say, an automated build process, then you don't want to establish a link, you just want to bring the code into the workspace. This can be achieved by specifying the `-import` flag.


#### 4. Check for later versions regarding Tatin packages

In case the project has Tatin packages installed in one or more folders the user will be asked whether she wants Cider to check for any later versions of any of the principal packages. This will only happen in case `importFlag` is 0.

However, note that this is only true if you've loaded the package(s) from a Registry that is in your config file _and_ has a priority greater than 0. Refer to the Tatin documentation for details.

If `]Cider.OpenProject` discovers later packages it will ask the user whether packages shall be re-installed with the `-update` flag set. This will happen independently for each package installation folder.


#### 5. Loading Tatin packages (optional)
 
Your application or tool might depend on one or more Tatin[^tatin] packages. By assigning `tatinFolder` one or more comma-separated folders hosting installed Tatin packages you can make sure that Cider will load[^load_tatin_pkgs] those installed packages into the root of your project.

In particular when you specify more than a single folder you are likely to want some packages to be loaded into a sub namespace of the root of your project.

For example, let's assume you want all packages installed in the folder `packages/` to be loaded into the root of your project. Let's also assume that you want to load all packages from a folder `packages_dev/` (for "development") into a namespace `TestCases` in the root of your project.

This will do the trick:

```
"tatinFolder": "packages,packages_development=TestCases",

```

Notes:
* For the first folder, `packages/`, no target namespace is specified, therefore the packages are loaded into the root of the project
* A namespace, if assigned to a folder, must be specified relative to the root of the project


#### 6. Injecting a namespace `CiderConfig`

In this step `]Cider.OpenProject` injects a namespace `CiderConfig` into the project space and...

* populates it with the contents of the configuration file as an APL array
* adds a variable `HOME` that remembers the path the project was loaded from


#### 7. Initialising a project (optional)

Now there might well be demand for executing some code in order to initialise your project.

This can be achieved by assigning the name of a function to `init`. This must again be relative to the root of your project.

Notes:

* The function should not return a result. If it does anyway it should be shy. Any result would be ignored.
* The function must be either monadic or niladic. If it is monadic then `⍬` is passed as right argument.

  What is passed as right argument might well change in a future release.

Note that you can access the configuration data of the project from within your initialisation function by questioning the `CiderConfig` namespace.

#### 8. Executing user-specific code

Finally you might want to execute some general code (as opposed to project-specific code) after a project was loaded. "General" means that this code is executed whenever a project (any project!) is opened. 

This can be achieved by specifying the fully qualified name of a function that must be monadic, most likely in `⎕SE`. A namespace with the configuration data of the project is passed as right argument.

The function may or may not return a result, but when it does the result will be discarded.

The fully qualified name of the function must go into the file that is returned by the function `GetCiderConfigFilename` which is available only via the API, not as a user command.

That file already contains a definition of the keyword `ExecuteAfterProjectOpen`, but it is empty:

```
{
    ExecuteAfterProjectOpen: "",
}
```

What is this good for you may ask? Well, let's assume that you are not using Git but a different version Control Software. With Git, Cider would execute the "status" command and print the result to the session window. With your Version Control Software it can't do something similar.

You can easily achieve that by yourself: just add the required code to a function you load early into `⎕SE`, and then make sure that `ExecuteAfterProjectOpen` is calling that function and you are done.

[^tatin]: _Tatin_ is a Dyalog APL package manager: <https://github.com/aplteam/Tatin>

[^link]: _LINK_ is a tool designed to bring APL code into the workspace and keep it in sync with the files the code came from: <https://github.com/dyalog/Link>

[^load_tatin_pkgs]: Strictly speaking only references to the packages are injected into your application or tool. The actual packages are loaded into either `#._tatin` or `⎕SE._tatin`

[^winonly]: At the time of writing (July 2022) this works under Windows but not on other operating systems. However, Dyalog plans to implement this feature on all platform.